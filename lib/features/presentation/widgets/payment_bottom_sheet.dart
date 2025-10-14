import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/eth_payment_service.dart';
import '../../domain/entities/eth_transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../../dependency_injection/riverpod_providers.dart';

class PaymentBottomSheet extends ConsumerStatefulWidget {
  final Wallet? wallet;
 
  const PaymentBottomSheet({Key? key, this.wallet}) : super(key: key);

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  int currentStep = 0;
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
  bool _isDisposed = false;

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
    _ethPaymentService = ref.read(ethPaymentServiceProvider);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _estimateGas() async {
    if (widget.wallet == null || amount.isEmpty || recipientAddress.isEmpty) {
      return;
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isEstimatingGas = true;
      });
    }

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
        if (mounted && !_isDisposed) {
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
      if (mounted && !_isDisposed) {
        setState(() {
          _gasEstimate = gasEstimate;
          _isEstimatingGas = false;
        });
      }
    } catch (e) {
      print("❌ Gas estimation failed: $e");
      if (mounted && !_isDisposed) {
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

    if (mounted && !_isDisposed) {
      setState(() {
        _isSendingPayment = true;
      });
    }

    try {
      print('🚀 Starting ETH payment...');
      print('📋 From: ${widget.wallet!.address}');
      print('📋 To: $recipientAddress');
      print('📋 Amount: $amount');
      print('📋 Company: $recipientName');
      print('📋 Category: $category');
      print('📋 Description: $description');

      final result = await _ethPaymentService.sendEthTransaction(
        fromWallet: widget.wallet!,
        toAddress: recipientAddress,
        amount: double.parse(amount),
        company: recipientName.isNotEmpty ? recipientName : null,
        category: category,
        description: description.isNotEmpty ? description : null,
      );

      print('✅ Payment successful! Transaction hash: ${result.transactionHash}');

      if (mounted && !_isDisposed) {
        setState(() {
          _isSendingPayment = false;
        });

        Navigator.pop(context, result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment sent successfully! TX: ${result.transactionHash.substring(0, 10)}...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('🚨 Payment failed with error: $e');
      print('🚨 Error type: ${e.runtimeType}');
      
      if (mounted && !_isDisposed) {
        setState(() {
          _isSendingPayment = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
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

  String _calculateUSDEquivalent() {
    final amountValue = double.tryParse(amount) ?? 0.0;
    // ETH to USD conversion - in real app, this would use current exchange rates
    const double ethUsdRate = 3200.0; // Example ETH price
    final usdAmount = amountValue * ethUsdRate;
    return '\$${usdAmount.toStringAsFixed(2)}';
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
          _buildStepIndicator('Details', 0),
          _buildProgressLine(0),
          _buildStepIndicator('Confirm', 1),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String label, int step) {
    final isCompleted = step < currentStep;
    final isCurrent = step == currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? const Color(0xFF8B5CF6) : Colors.grey[300],
            border: isCurrent
                ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isCompleted ? const Color(0xFF8B5CF6) : Colors.grey[600],
            fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
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
        return _buildDetailsStep();
      case 1:
        return _buildConfirmStep();
      default:
        return _buildDetailsStep();
    }
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient Information Section
            const Text(
              'Recipient Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
              onChanged: (value) {
                print('🔍 Category changed from $category to $value');
                setState(() => category = value!);
              },
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
            
            const SizedBox(height: 16),
            
            // Description Field
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (value) {
                print('🔍 Description changed to: $value');
                description = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter description (optional)',
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
              maxLines: 2,
            ),
            
            const SizedBox(height: 32),
            
            // Amount Section
            const Text(
              'Payment Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Amount (ETH)',
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
                hintText: 'Enter amount',
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
          ],
        ),
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
              'Amount:', '${amount.isEmpty ? '0' : amount} ETH'),
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


  Widget _buildBottomActions() {
    // Form validity: require connected wallet, recipient address, and a positive numeric amount.
    final double amountValue = double.tryParse(amount) ?? 0.0;
    final bool isFormValid = widget.wallet != null && recipientAddress.trim().isNotEmpty && amountValue > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (currentStep > 0) {
                  setState(() {
                    currentStep--;
                  });
                } else {
                  Navigator.pop(context);
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
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              // Disable button when sending, or when on step 0 and form is invalid.
              onPressed: (_isSendingPayment || (currentStep == 0 && !isFormValid))
                  ? null
                  : () async {
                      if (currentStep < 1) {
                        // If moving to confirmation step (step 1), estimate gas
                        if (widget.wallet != null && amount.isNotEmpty && recipientAddress.isNotEmpty) {
                          await _estimateGas();
                        }
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        // Handle payment confirmation
                        if (widget.wallet != null && isFormValid) {
                          await _sendPayment();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please complete recipient information and enter a valid amount'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isSendingPayment || (currentStep == 0 && !isFormValid))
                    ? Colors.grey // visually indicate disabled state
                    : const Color(0xFF8B5CF6),
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
                      currentStep == 1 ? 'Send Payment' : 'Continue',
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

