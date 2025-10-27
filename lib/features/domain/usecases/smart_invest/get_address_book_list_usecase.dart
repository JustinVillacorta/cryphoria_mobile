
import '../../entities/smart_invest.dart';
import '../../repositories/smart_invest_repository.dart';

class GetAddressBookListUseCase {
  final SmartInvestRepository repository;

  GetAddressBookListUseCase({required this.repository});

  Future<AddressBookListResponse> execute() async {
    return await repository.getAddressBookList();
  }
}