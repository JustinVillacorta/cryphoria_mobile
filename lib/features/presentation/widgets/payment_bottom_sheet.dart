import 'package:flutter/material.dart';
import '../../data/services/eth_payment_service.dart';
import '../../domain/entities/eth_transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../../dependency_injection/di.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Wallet? wallet;
  
  const PaymentBottomSheet({Key? key, this.wallet}) : super(key: key);

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  int currentStep = 0;
  String selectedToken = 'ETH';
  String amount = '';
  String recipientName = '';
  String recipientAddress = '';
  String description = '';
  String category = 'Office Expenses';
  
  // Service dependencies
  late EthPaymentService _ethPaymentService;
  
  // Gas estimation
  GasEstimate? _gasEstimate;
  bool _isEstimatingGas = false;
  bool _isSendingPayment = false;

  final List<String> tokens = ['ETH', 'BTC', 'USDT', 'USDC'];
  final List<String> categories = [
    'Office Expenses',
    'Travel',
    'Marketing',
    'Equipment',
    'Software',
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  void _initializeService() {
    _ethPaymentService = sl<EthPaymentService>();
  }

  Future<void> _estimateGas() async {
    if (widget.wallet == null || amount.isEmpty || recipientAddress.isEmpty) {
      return;
    }

    setState(() {
      _isEstimatingGas = true;
    });

    try {
      print("🔄 Starting gas estimation...");
      print("📋 From: ${widget.wallet!.address}");
      print("📋 To: $recipientAddress");
      print("📋 Amount: $amount");
      
      // First check server health
      print("🏥 Checking server connectivity...");
      final isServerHealthy = await _ethPaymentService.remoteDataSource.checkServerHealth();
      
      if (!isServerHealthy) {
        print("⚠️ Server health check failed, using default gas estimate");
        setState(() {
          _isEstimatingGas = false;
          _gasEstimate = GasEstimate(
            estimatedCostEth: 0.001,
            gasPriceGwei: 20.0,
            gasLimit: 21000,
            slowGasPrice: 10.0,
            standardGasPrice: 20.0,
            fastGasPrice: 30.0,
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server not reachable. Using default gas fee (0.001 ETH). Please check if backend server is running.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
        return;
      }
      
      final gasEstimate = await _ethPaymentService.estimateGas(
        fromAddress: widget.wallet!.address,
        toAddress: recipientAddress,
        amount: double.parse(amount),
      );

      print("✅ Gas estimation successful: ${gasEstimate.toString()}");
      setState(() {
        _gasEstimate = gasEstimate;
        _isEstimatingGas = false;
      });
    } catch (e) {
      print("❌ Gas estimation failed: $e");
      setState(() {
        _isEstimatingGas = false;
        // Set a default gas estimate so transaction can still proceed
        _gasEstimate = GasEstimate(
          estimatedCostEth: 0.001, // Default gas fee
          gasPriceGwei: 20.0, // Default gas price
          gasLimit: 21000, // Default gas limit for ETH transfer
          slowGasPrice: 10.0,
          standardGasPrice: 20.0,
          fastGasPrice: 30.0,
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gas estimation failed. Using default gas fee (0.001 ETH). You can still proceed.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendPayment() async {
    if (widget.wallet == null || amount.isEmpty || recipientAddress.isEmpty) {
      return;
    }

    setState(() {
      _isSendingPayment = true;
    });

    try {
      final result = await _ethPaymentService.sendEthTransaction(
        fromWallet: widget.wallet!,
        toAddress: recipientAddress,
        amount: double.parse(amount),
        company: recipientName.isNotEmpty ? recipientName : null,
        category: category,
        description: description.isNotEmpty ? description : null,
      );

      setState(() {
        _isSendingPayment = false;
      });

      if (mounted) {
        Navigator.pop(context, result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment sent! TX: ${result.transactionHash.substring(0, 10)}...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSendingPayment = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _calculateTotal() {
    final amountValue = double.tryParse(amount) ?? 0.0;
    final gasValue = _gasEstimate?.estimatedCostEth ?? 0.0;
    return '${(amountValue + gasValue).toStringAsFixed(6)} ETH';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressIndicator(),
          Expanded(
            child: _buildCurrentStep(),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (currentStep > 0) {
                setState(() {
                  currentStep--;
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const Expanded(
            child: Text(
              'Send Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          _buildStepIndicator('Recipient', 0),
          _buildProgressLine(0),
          _buildStepIndicator('Token/Asset', 1),
          _buildProgressLine(1),
          _buildStepIndicator('Confirm', 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label, int step) {
    final isActive = step <= currentStep;
    final isCurrent = step == currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[300],
            border: isCurrent
                ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
                : null,
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = step < currentStep;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? const Color(0xFF8B5CF6) : Colors.grey[300],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildRecipientStep();
      case 1:
        return _buildTokenStep();
      case 2:
        return _buildConfirmStep();
      default:
        return _buildRecipientStep();
    }
  }

  Widget _buildRecipientStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company/Recipient Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: (value) => recipientName = value,
            decoration: InputDecoration(
              hintText: 'Enter company or recipient name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recipient Address / Company Wallet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: (value) => recipientAddress = value,
            decoration: InputDecoration(
              hintText: 'Enter wallet address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: category,
            onChanged: (value) => setState(() => category = value!),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            ),
            icon: const SizedBox.shrink(),
            items: categories.map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: (value) => amount = value,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '23',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Token',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: tokens.map((token) => _buildTokenChip(token)).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equivalent in USD:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Text(
                      '\$72800.00',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Network Gas Fee:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Text(
                      '0.007 ETH',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildAddressPreviewRow(
              'To:', recipientName.isEmpty ? _formatAddress(recipientAddress) : recipientName, 
              recipientName.isEmpty ? recipientAddress : null),
          _buildPreviewRow(
              'Amount:', '${amount.isEmpty ? '0' : amount} $selectedToken'),
          _buildPreviewRow(
              'Description:', description.isEmpty ? 'No description' : description),
          _buildPreviewRow('Category:', category),
          _buildPreviewRow(
            'Gas Fee:', 
            _isEstimatingGas 
              ? 'Estimating...' 
              : _gasEstimate != null 
                ? '${_gasEstimate!.estimatedCostEth.toStringAsFixed(6)} ETH'
                : 'Not estimated'
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _calculateTotal(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (_gasEstimate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Gas Price: ${_gasEstimate!.gasPriceGwei.toStringAsFixed(1)} Gwei',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B82F6), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By proceeding, you will be automatically redirected once the payment is completed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPreviewRow(String label, String displayValue, String? fullAddress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenChip(String token) {
    final isSelected = selectedToken == token;
    return GestureDetector(
      onTap: () => setState(() => selectedToken = token),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          token,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (currentStep > 0) {
                    setState(() {
                      currentStep--;
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isSendingPayment ? null : () async {
                if (currentStep < 2) {
                  // If moving to confirmation step (step 2), estimate gas
                  if (currentStep == 1 && widget.wallet != null && amount.isNotEmpty && recipientAddress.isNotEmpty) {
                    await _estimateGas();
                  }
                  setState(() {
                    currentStep++;
                  });
                } else {
                  // Handle payment confirmation
                  if (widget.wallet != null) {
                    await _sendPayment();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No wallet connected'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSendingPayment 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    currentStep == 2 ? 'Send Payment' : 'Continue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}