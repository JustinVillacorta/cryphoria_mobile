// lib/features/domain/usecases/smart_invest/upsert_address_book_usecase.dart

import '../../entities/smart_invest.dart';
import '../../repositories/smart_invest_repository.dart';

class UpsertAddressBookUseCase {
  final SmartInvestRepository repository;

  UpsertAddressBookUseCase({required this.repository});

  Future<AddressBookUpsertResponse> execute(AddressBookUpsertRequest request) async {
    // Validate input
    if (request.address.isEmpty) {
      throw Exception('Address is required');
    }
    
    if (request.name.isEmpty) {
      throw Exception('Name is required');
    }
    
    if (request.role.isEmpty) {
      throw Exception('Role is required');
    }

    return await repository.upsertAddressBookEntry(request);
  }
}
