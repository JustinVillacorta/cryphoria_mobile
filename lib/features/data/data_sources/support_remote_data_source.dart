import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/support_ticket.dart';
import '../models/support_ticket_model.dart';

abstract class SupportRemoteDataSource {
  Future<SupportTicket> submitSupportTicket({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<File>? attachments,
  });

  Future<List<SupportMessage>> getSupportMessages();
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final Dio dio;

  SupportRemoteDataSourceImpl({required this.dio});

  @override
  Future<SupportTicket> submitSupportTicket({
    required String subject,
    required String message,
    required String category,
    required String priority,
    List<File>? attachments,
  }) async {
    print("🌐 SupportRemoteDataSource.submitSupportTicket called");
    print("📋 Support ticket: subject=$subject, category=$category, priority=$priority");
    
    try {
      print("📤 Making POST request to /api/support/submit/");
      
      // Build FormData for multipart request
      final formData = FormData.fromMap({
        'subject': subject,
        'message': message,
        'category': category,
        'priority': priority,
      });

      // Add attachments if provided
      if (attachments != null && attachments.isNotEmpty) {
        print("📎 Adding ${attachments.length} attachment(s)");
        for (int i = 0; i < attachments.length; i++) {
          final file = attachments[i];
          if (file.existsSync()) {
            formData.files.add(MapEntry(
              'attachments',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ));
          }
        }
      }

      final response = await dio.post(
        '/api/support/submit/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print("📥 Submit support ticket response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        return SupportTicketModel.fromJson(responseData);
      } else {
        throw Exception('Failed to submit support ticket: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in submitSupportTicket: $e");
      if (e.response != null) {
        print("❌ Response data: ${e.response?.data}");
        print("❌ Response status: ${e.response?.statusCode}");
        
        // Parse API error response format
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            final message = responseData['message'] as String;
            
            // Parse validation errors if they exist
            if (responseData.containsKey('errors') && responseData['errors'] is Map<String, dynamic>) {
              final errors = responseData['errors'] as Map<String, dynamic>;
              final errorMessages = <String>[];
              
              errors.forEach((field, fieldErrors) {
                if (fieldErrors is List) {
                  for (final error in fieldErrors) {
                    errorMessages.add('$field: $error');
                  }
                } else {
                  errorMessages.add('$field: $fieldErrors');
                }
              });
              
              if (errorMessages.isNotEmpty) {
                throw Exception('${message}: ${errorMessages.join(', ')}');
              }
            }
            
            throw Exception(message);
          }
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<SupportMessage>> getSupportMessages() async {
    print("🌐 SupportRemoteDataSource.getSupportMessages called");
    
    try {
      print("📤 Making GET request to /api/support/messages/");
      
      final response = await dio.get(
        '/api/support/messages/',
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print("📥 Get support messages response:");
      print("📊 Status code: ${response.statusCode}");
      print("📄 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          // Handle the actual API response format: {success: true, data: {messages: [...], total: 1, offset: 0, limit: 50}}
          if (responseData.containsKey('success') && responseData.containsKey('data')) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('messages')) {
              final messages = data['messages'] as List;
              return messages
                  .map((json) => SupportMessageModel.fromJson(json))
                  .toList();
            }
          }
          // Handle paginated response format
          else if (responseData.containsKey('results')) {
            final results = responseData['results'] as List;
            return results
                .map((json) => SupportMessageModel.fromJson(json))
                .toList();
          }
        } else if (responseData is List) {
          return responseData
              .map((json) => SupportMessageModel.fromJson(json))
              .toList();
        }
        throw Exception('Unexpected response format');
      } else {
        throw Exception('Failed to get support messages: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("❌ DioException in getSupportMessages: $e");
      if (e.response != null) {
        print("❌ Response data: ${e.response?.data}");
        print("❌ Response status: ${e.response?.statusCode}");
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
