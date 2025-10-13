import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/document.dart';

abstract class DocumentUploadRemoteDataSource {
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

class DocumentUploadRemoteDataSourceImpl implements DocumentUploadRemoteDataSource {
  final Dio dio;

  DocumentUploadRemoteDataSourceImpl({required this.dio});

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
      print("📤 Uploading business documents - making 3 separate requests");

      final results = <String, dynamic>{};
      
      // Upload DTI Document
      print("📤 Uploading DTI Document...");
      final dtiFormData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          dtiDocument.path,
          filename: dtiDocument.path.split('/').last,
        ),
        'document_type': 'business_registration',
      });
      
      final dtiResponse = await dio.post(
        '/api/documents/upload/',
        data: dtiFormData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );
      
      if (dtiResponse.statusCode == 200 || dtiResponse.statusCode == 201) {
        results['dti_document'] = dtiResponse.data;
        print("✅ DTI Document uploaded successfully");
      } else {
        throw Exception('Failed to upload DTI document: ${dtiResponse.statusMessage}');
      }

      // Upload BIR Form
      print("📤 Uploading BIR Form...");
      final birFormData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          birForm.path,
          filename: birForm.path.split('/').last,
        ),
        'document_type': 'tax_id',
      });
      
      final birResponse = await dio.post(
        '/api/documents/upload/',
        data: birFormData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );
      
      if (birResponse.statusCode == 200 || birResponse.statusCode == 201) {
        results['bir_form'] = birResponse.data;
        print("✅ BIR Form uploaded successfully");
      } else {
        throw Exception('Failed to upload BIR form: ${birResponse.statusMessage}');
      }

      // Upload Manager Government ID
      print("📤 Uploading Manager Government ID...");
      final managerIdFormData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          managerId.path,
          filename: managerId.path.split('/').last,
        ),
        'document_type': 'company_license',
      });
      
      final managerIdResponse = await dio.post(
        '/api/documents/upload/',
        data: managerIdFormData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );
      
      if (managerIdResponse.statusCode == 200 || managerIdResponse.statusCode == 201) {
        results['manager_government_id'] = managerIdResponse.data;
        print("✅ Manager Government ID uploaded successfully");
      } else {
        throw Exception('Failed to upload Manager Government ID: ${managerIdResponse.statusMessage}');
      }

      print("✅ All documents uploaded successfully");
      return results;
    } on DioException catch (e) {
      print("❌ Upload failed: ${e.message}");
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Upload timeout. The files might be too large.');
      } else if (e.response?.statusCode == 413) {
        throw Exception('File too large. Please ensure files are under 5MB.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Invalid request';
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid request. Please check your data.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. You do not have permission to upload documents. Please check if you are logged in and have the correct permissions.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message ?? 'Unknown error occurred'}');
      }
    } catch (e) {
      print("❌ Unexpected error uploading documents: $e");
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> submitDocumentsForApproval() async {
    try {
      print("📤 Submitting documents for approval...");

      final response = await dio.post(
        '/api/documents/submit/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      print("✅ Submit successful: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to submit documents: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Submit failed: ${e.message}");
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Submit timeout. Please try again.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Invalid request';
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid request. Please check your data.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. You do not have permission to submit documents.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message ?? 'Unknown error occurred'}');
      }
    } catch (e) {
      print("❌ Unexpected error submitting documents: $e");
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<Document>> getMyDocuments() async {
    try {
      print("📥 Fetching user documents...");

      final response = await dio.get(
        '/api/documents/my-documents/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      print("✅ Get documents successful: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          // Handle response with 'documents' key (the actual API format)
          if (responseData.containsKey('documents') && responseData['documents'] is List) {
            final List<dynamic> documentsJson = responseData['documents'];
            return documentsJson.map((json) => Document.fromJson(json)).toList();
          }
          
          // Handle single document response
          if (responseData.containsKey('id')) {
            return [Document.fromJson(responseData)];
          }
          
          // Handle list response with 'results' key
          if (responseData.containsKey('results') && responseData['results'] is List) {
            final List<dynamic> documentsJson = responseData['results'];
            return documentsJson.map((json) => Document.fromJson(json)).toList();
          }
        }
        
        if (responseData is List) {
          return responseData.map((json) => Document.fromJson(json)).toList();
        }
        
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to fetch documents: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ Get documents failed: ${e.message}");
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please try again.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Invalid request';
          throw Exception('Validation error: $errorMessage');
        }
        throw Exception('Invalid request. Please check your data.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. You do not have permission to view documents.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('No documents found.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error: ${e.message ?? 'Unknown error occurred'}');
      }
    } catch (e) {
      print("❌ Unexpected error fetching documents: $e");
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
