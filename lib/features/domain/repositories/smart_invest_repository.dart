
import '../entities/smart_invest.dart';

abstract class SmartInvestRepository {
  Future<SmartInvestResponse> sendInvestment(SmartInvestRequest request);

  Future<AddressBookUpsertResponse> upsertAddressBookEntry(AddressBookUpsertRequest request);

  Future<AddressBookListResponse> getAddressBookList();

  Future<AddressBookDeleteResponse> deleteAddressBookEntry(String address);
}