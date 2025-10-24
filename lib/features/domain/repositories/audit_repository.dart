import 'dart:io';
import '../entities/audit_report.dart';

abstract class AuditRepository {
  /// Upload smart contract file and get immediate audit report
  Future<AuditReport> uploadContract(File contractFile);
}
