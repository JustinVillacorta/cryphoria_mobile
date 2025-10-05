// lib/features/data/services/smart_invest_service.dart

import 'wallet_service.dart';
import '../../domain/entities/smart_invest.dart';

class SmartInvestService {
  final WalletService walletService;

  SmartInvestService({required this.walletService});

  /// Send investment using the existing sendEth method with investment parameters
  Future<SmartInvestResponse> sendInvestment({
    required String recipientAddress,
    required String amount,
    required String investorName,
    required String description,
    String? category,
  }) async {
    try {
      print('🌐 SmartInvestService.sendInvestment called');
      print('📋 Recipient: $recipientAddress');
      print('📋 Amount: $amount');
      print('📋 Investor: $investorName');
      print('📋 Description: $description');
      print('📋 Category: $category');
      print('📋 Recipient address length: ${recipientAddress.length}');
      print('📋 Recipient address starts with 0x: ${recipientAddress.startsWith('0x')}');

      // Parse amount to double
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null) {
        throw Exception('Invalid amount format: $amount');
      }

      // Use the existing sendEth method with investment parameters
      print('📤 SmartInvestService calling walletService.sendEth with:');
      print('📋 toAddress: $recipientAddress');
      print('📋 amount: $parsedAmount');
      print('📋 company: $investorName');
      print('📋 category: ${category ?? 'Investment'}');
      print('📋 description: $description');
      print('📋 isInvesting: true');
      print('📋 investorName: $investorName');
      
      final result = await walletService.sendEth(
        toAddress: recipientAddress,
        amount: parsedAmount,
        company: investorName, // Use investor name as company
        category: category ?? 'Investment', // Default to 'Investment' if not provided
        description: description,
        isInvesting: true, // Always true for smart investments
        investorName: investorName, // Pass investor name separately
      );

      print('📥 Send investment result: $result');

      // Convert the result to SmartInvestResponse format
      return SmartInvestResponse(
        success: true,
        message: 'Investment sent successfully',
        data: SmartInvestData(
          transactionHash: result['transaction_hash']?.toString() ?? '',
          fromAddress: result['from_address']?.toString() ?? '',
          fromWalletName: result['from_wallet_name']?.toString() ?? '',
          toAddress: result['to_address']?.toString() ?? '',
          amountEth: result['amount_eth']?.toString() ?? amount,
          gasPriceGwei: result['gas_price_gwei']?.toString() ?? '',
          gasLimit: result['gas_limit'] as int? ?? 0,
          gasUsed: result['gas_used'] as int? ?? 0,
          gasCostEth: result['gas_cost_eth']?.toString() ?? '',
          totalCostEth: result['total_cost_eth']?.toString() ?? '',
          status: result['status']?.toString() ?? '',
          chainId: result['chain_id'] as int? ?? 0,
          nonce: result['nonce'] as int? ?? 0,
          company: result['company']?.toString() ?? investorName,
          category: result['category']?.toString() ?? category ?? 'Investment',
          description: result['description']?.toString() ?? description,
          timestamp: result['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
          explorerUrl: result['explorer_url']?.toString(),
          usedConnectedWallet: result['used_connected_wallet'] as bool? ?? true,
          userRole: result['user_role']?.toString() ?? '',
          walletType: result['wallet_type']?.toString() ?? '',
          llmAnalysis: result['llm_analysis'] as Map<String, dynamic>? ?? {},
        ),
      );
    } catch (e) {
      print('❌ SmartInvestService.sendInvestment failed: $e');
      rethrow;
    }
  }
}
