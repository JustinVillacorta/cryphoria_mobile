// lib/features/domain/usecases/smart_invest/get_address_book_list_usecase.dart

import '../../entities/smart_invest.dart';
import '../../repositories/smart_invest_repository.dart';

class GetAddressBookListUseCase {
  final SmartInvestRepository repository;

  GetAddressBookListUseCase({required this.repository});

  Future<AddressBookListResponse> execute() async {
    return await repository.getAddressBookList();
  }
}
