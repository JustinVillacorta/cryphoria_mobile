// lib/features/domain/repositories/smart_invest_repository.dart

import '../entities/smart_invest.dart';

abstract class SmartInvestRepository {
  /// Send investment transaction with investment details
  Future<SmartInvestResponse> sendInvestment(SmartInvestRequest request);
  
  /// Add or update address book entry
  Future<AddressBookUpsertResponse> upsertAddressBookEntry(AddressBookUpsertRequest request);
  
  /// Get list of address book entries
  Future<AddressBookListResponse> getAddressBookList();
}
