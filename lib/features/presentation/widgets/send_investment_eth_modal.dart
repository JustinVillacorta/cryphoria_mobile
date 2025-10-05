import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/smart_invest_providers.dart';
import '../../domain/entities/smart_invest.dart';

class SendInvestmentEthModal extends ConsumerStatefulWidget {
  final String recipientName;
  final String recipientAddress;
  
  const SendInvestmentEthModal({
    Key? key,
    required this.recipientName,
    required this.recipientAddress,
  }) : super(key: key);

  @override
  ConsumerState<SendInvestmentEthModal> createState() => _SendInvestmentEthModalState();
}

class _SendInvestmentEthModalState extends ConsumerState<SendInvestmentEthModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String selectedCategory = 'Investment';
  bool isLoading = false;
  
  final List<String> categories = [
    'Investment',
    'Seed Funding',
    'Series A',
    'Series B',
    'Partnership',
    'Strategic Investment'
  ];

  @override
  void initState() {
    super.initState();
    _companyController.text = widget.recipientName;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            child: _buildForm(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Investment ETH',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sending to ${widget.recipientName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send Investment ETH to ${widget.recipientName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Recipient Address Field
          _buildFormField(
            label: 'Recipient Address',
            controller: TextEditingController(text: widget.recipientAddress),
            readOnly: true,
            suffixIcon: IconButton(
              onPressed: () => _copyToClipboard(widget.recipientAddress),
              icon: const Icon(Icons.copy, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          
          // Amount Field
          _buildFormField(
            label: 'Amount (ETH)',
            controller: _amountController,
            keyboardType: TextInputType.number,
            hintText: '0.0',
            prefixIcon: const Icon(Icons.currency_exchange, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          
          // Company Field
          _buildFormField(
            label: 'Investor Name / Company',
            controller: _companyController,
            hintText: 'Company name',
          ),
          const SizedBox(height: 20),
          
          // Category Dropdown
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Description Field
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Series A investment, Seed funding, etc.',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Investment Summary
          if (_amountController.text.isNotEmpty) _buildInvestmentSummary(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: readOnly,
              fillColor: readOnly ? Colors.grey[50] : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final equivalentUsd = amount * 2750; // Assuming 1 ETH = $2750
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount:', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('${amount.toStringAsFixed(4)} ETH', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Equivalent USD:', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('\$${equivalentUsd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recipient:', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(widget.recipientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Category:', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(selectedCategory, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Address Book',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: (isLoading || _amountController.text.isEmpty)
                    ? Colors.grey[300]
                    : Colors.purple[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: (isLoading || _amountController.text.isEmpty) ? null : _sendInvestment,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isLoading 
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, size: 18, color: Colors.white),
                label: Text(
                  isLoading ? 'Sending...' : 'Send Investment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    // In a real app, you'd use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendInvestment() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('🚀 _sendInvestment called with:');
      print('📋 Widget recipientAddress: ${widget.recipientAddress}');
      print('📋 Widget recipientName: ${widget.recipientName}');
      print('📋 Amount: ${_amountController.text.trim()}');
      print('📋 Investor: ${_companyController.text.trim()}');
      print('📋 Description: ${_descriptionController.text.trim()}');
      
      final request = SmartInvestRequest(
        toAddress: widget.recipientAddress,
        amount: _amountController.text.trim(),
        isInvesting: true,
        investorName: _companyController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      print('📤 Sending investment request');
      print('📋 Request toAddress: ${request.toAddress}');
      print('📋 Request amount: ${request.amount}');
      print('📋 Request investorName: ${request.investorName}');
      print('📋 Request description: ${request.description}');
      
      // Call the notifier and get the response directly
      final investment = await ref.read(smartInvestNotifierProvider.notifier).sendInvestment(request);
      
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      print('🎉 Success handling - Investment: ${investment?.data.transactionHash}');
      
      // Show detailed success message
      String successMessage = 'Investment sent successfully!';
      if (investment != null) {
        successMessage = 'Investment of ${investment.data.amountEth} ETH sent to ${widget.recipientName}!\n'
            'Transaction Hash: ${investment.data.transactionHash.substring(0, 10)}...\n'
            'Status: ${investment.data.status}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View Details',
            textColor: Colors.white,
            onPressed: () {
              // Show transaction details dialog
              _showTransactionDetails(investment);
            },
          ),
        ),
      );

      Navigator.pop(context, {
        'success': true,
        'amount': _amountController.text,
        'recipient': widget.recipientName,
        'transactionHash': investment?.data.transactionHash,
      });
    } catch (e) {
      print('❌ Error in _sendInvestment: $e');
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });

      // Show more detailed error information
      String errorMessage = 'Failed to send investment';
      if (e.toString().contains('500')) {
        errorMessage = 'Server error (500) - but transaction may have succeeded. Please check your wallet.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied. Please check your permissions.';
      } else {
        errorMessage = 'Failed to send investment: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showTransactionDetails(SmartInvestResponse? investment) {
    if (investment == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', investment.data.status, 
                investment.data.status == 'confirmed' ? Colors.green : Colors.orange),
              _buildDetailRow('Amount', '${investment.data.amountEth} ETH'),
              _buildDetailRow('To', investment.data.toAddress),
              _buildDetailRow('From', investment.data.fromAddress),
              _buildDetailRow('Transaction Hash', investment.data.transactionHash),
              _buildDetailRow('Gas Used', '${investment.data.gasUsed} / ${investment.data.gasLimit}'),
              _buildDetailRow('Gas Price', '${investment.data.gasPriceGwei} Gwei'),
              _buildDetailRow('Gas Cost', '${investment.data.gasCostEth} ETH'),
              _buildDetailRow('Total Cost', '${investment.data.totalCostEth} ETH'),
              _buildDetailRow('Chain ID', investment.data.chainId.toString()),
              _buildDetailRow('Nonce', investment.data.nonce.toString()),
              _buildDetailRow('Timestamp', investment.data.timestamp),
              if (investment.data.explorerUrl != null)
                _buildDetailRow('Explorer', investment.data.explorerUrl!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (investment.data.explorerUrl != null)
            TextButton(
              onPressed: () {
                // Open explorer URL
                // You can implement URL launcher here if needed
                Navigator.pop(context);
              },
              child: const Text('View on Explorer'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
