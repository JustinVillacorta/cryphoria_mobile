import 'dart:io';
import '../../repositories/document_upload_repository.dart';
import '../../entities/document.dart';

class UploadBusinessDocumentsUseCase {
  final DocumentUploadRepository repository;

  UploadBusinessDocumentsUseCase({required this.repository});

  Future<Map<String, dynamic>> execute({
    required String businessName,
    required String businessType,
    required String businessRegistrationNumber,
    required String businessAddress,
    required String businessPhone,
    required String businessEmail,
    required File dtiDocument,
    required File birForm,
    required File managerId,
  }) async {

    if (!dtiDocument.existsSync()) {
      throw Exception('DTI document file not found');
    }
    if (!birForm.existsSync()) {
      throw Exception('BIR form file not found');
    }
    if (!managerId.existsSync()) {
      throw Exception('Manager ID file not found');
    }

        const maxFileSize = 5 * 1024 * 1024;

    if (dtiDocument.lengthSync() > maxFileSize) {
      throw Exception('DTI document exceeds 5MB limit');
    }
    if (birForm.lengthSync() > maxFileSize) {
      throw Exception('BIR form exceeds 5MB limit');
    }
    if (managerId.lengthSync() > maxFileSize) {
      throw Exception('Manager ID exceeds 5MB limit');
    }

    return await repository.uploadBusinessDocuments(
      businessName: businessName,
      businessType: businessType,
      businessRegistrationNumber: businessRegistrationNumber,
      businessAddress: businessAddress,
      businessPhone: businessPhone,
      businessEmail: businessEmail,
      dtiDocument: dtiDocument,
      birForm: birForm,
      managerId: managerId,
    );
  }

  Future<Map<String, dynamic>> submitDocumentsForApproval() async {
    return await repository.submitDocumentsForApproval();
  }

  Future<List<Document>> getMyDocuments() async {
    return await repository.getMyDocuments();
  }
}