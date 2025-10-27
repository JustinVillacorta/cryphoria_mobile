import 'dart:io';
import '../../domain/repositories/document_upload_repository.dart';
import '../../domain/entities/document.dart';
import '../data_sources/document_upload_remote_data_source.dart';

class DocumentUploadRepositoryImpl implements DocumentUploadRepository {
  final DocumentUploadRemoteDataSource remoteDataSource;

  DocumentUploadRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.uploadBusinessDocuments(
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

      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitDocumentsForApproval() async {
    try {
      final result = await remoteDataSource.submitDocumentsForApproval();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Document>> getMyDocuments() async {
    try {
      final result = await remoteDataSource.getMyDocuments();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}