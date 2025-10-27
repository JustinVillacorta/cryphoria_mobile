
import '../../entities/smart_invest.dart';
import '../../repositories/smart_invest_repository.dart';

class SendInvestmentUseCase {
  final SmartInvestRepository repository;

  SendInvestmentUseCase({required this.repository});

  Future<SmartInvestResponse> execute(SmartInvestRequest request) async {
    if (request.toAddress.isEmpty) {
      throw Exception('Recipient address is required');
    }

    if (request.amount.isEmpty || double.tryParse(request.amount) == null) {
      throw Exception('Valid amount is required');
    }

    if (double.parse(request.amount) <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    if (request.investorName.isEmpty) {
      throw Exception('Investor name is required');
    }

    if (request.description.isEmpty) {
      throw Exception('Description is required');
    }

    return await repository.sendInvestment(request);
  }
}