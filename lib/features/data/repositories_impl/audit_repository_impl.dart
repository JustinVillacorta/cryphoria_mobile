import 'dart:io';
import '../../domain/entities/audit_report.dart';
import '../../domain/repositories/audit_repository.dart';
import '../data_sources/audit_remote_data_source.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;

  AuditRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuditReport> uploadContract(File contractFile) async {
    return await remoteDataSource.uploadContract(contractFile);
  }
}
