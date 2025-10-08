import 'dart:io';
import '../entities/document.dart';

abstract class DocumentUploadRepository {
  Future<Map<String, dynamic>> uploadBusinessDocuments({
    required String businessName,
    required String businessType,
    required String businessRegistrationNumber,
    required String businessAddress,
    required String businessPhone,
    required String businessEmail,
    required File dtiDocument,
    required File birForm,
    required File managerId,
  });
  
  Future<Map<String, dynamic>> submitDocumentsForApproval();
  
  Future<List<Document>> getMyDocuments();
}
