// lib/features/domain/usecases/smart_invest/delete_address_book_usecase.dart

import '../../entities/smart_invest.dart';
import '../../repositories/smart_invest_repository.dart';

class DeleteAddressBookUseCase {
  final SmartInvestRepository repository;

  DeleteAddressBookUseCase({required this.repository});

  Future<AddressBookDeleteResponse> execute(String address) async {
    // Validate input
    if (address.isEmpty) {
      throw Exception('Address is required');
    }

    return await repository.deleteAddressBookEntry(address);
  }
}
