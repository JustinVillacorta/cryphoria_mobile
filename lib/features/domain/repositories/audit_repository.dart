import 'dart:io';
import '../entities/audit_report.dart';

abstract class AuditRepository {
  Future<AuditReport> uploadContract(File contractFile);
}