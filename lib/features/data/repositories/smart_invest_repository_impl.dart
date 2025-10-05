// lib/features/data/repositories/smart_invest_repository_impl.dart

import '../../domain/entities/smart_invest.dart';
import '../../domain/repositories/smart_invest_repository.dart';
import '../data_sources/smart_invest_remote_data_source.dart';

class SmartInvestRepositoryImpl implements SmartInvestRepository {
  final SmartInvestRemoteDataSource remoteDataSource;

  SmartInvestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SmartInvestResponse> sendInvestment(SmartInvestRequest request) async {
    try {
      return await remoteDataSource.sendInvestment(request);
    } catch (e) {
      throw Exception('Failed to send investment: $e');
    }
  }

  @override
  Future<AddressBookUpsertResponse> upsertAddressBookEntry(AddressBookUpsertRequest request) async {
    try {
      return await remoteDataSource.upsertAddressBookEntry(request);
    } catch (e) {
      throw Exception('Failed to upsert address book entry: $e');
    }
  }

  @override
  Future<AddressBookListResponse> getAddressBookList() async {
    try {
      return await remoteDataSource.getAddressBookList();
    } catch (e) {
      throw Exception('Failed to get address book list: $e');
    }
  }
}
