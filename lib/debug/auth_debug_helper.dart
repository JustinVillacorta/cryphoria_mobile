import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthDebugHelper {
  static Future<void> debugAuthStatus(AuthLocalDataSource authDataSource) async {
    print("🔍 AUTH DEBUG - Starting authentication status check");
    
    try {
      // Check secure storage directly
      const storage = FlutterSecureStorage();
      final authUserData = await storage.read(key: 'auth_user');
      print("🔍 AUTH DEBUG - Raw storage data: ${authUserData?.substring(0, (authUserData.length > 100) ? 100 : authUserData.length)}...");
      
      // Check through AuthLocalDataSource
      final authUser = await authDataSource.getAuthUser();
      
      if (authUser != null) {
        print("🔍 AUTH DEBUG - Found cached user:");
        print("  - Username: ${authUser.username}");
        print("  - Token exists: ${authUser.token.isNotEmpty}");
        print("  - Token length: ${authUser.token.length}");
        print("  - Approved: ${authUser.approved}");
        print("  - Active: ${authUser.isActive}");
      } else {
        print("🔍 AUTH DEBUG - No cached user found");
      }
      
      // Check all storage keys
      final allKeys = await storage.readAll();
      print("🔍 AUTH DEBUG - All storage keys: ${allKeys.keys.toList()}");
      
    } catch (e, stackTrace) {
      print("🔍 AUTH DEBUG - Error: $e");
      print("🔍 AUTH DEBUG - Stack trace: $stackTrace");
    }
  }

  static Future<void> debugStorageCapabilities() async {
    print("🔍 STORAGE DEBUG - Testing storage capabilities");
    
    try {
      const storage = FlutterSecureStorage();
      
      // Test write
      await storage.write(key: 'test_key', value: 'test_value');
      print("🔍 STORAGE DEBUG - Write successful");
      
      // Test read
      final testValue = await storage.read(key: 'test_key');
      print("🔍 STORAGE DEBUG - Read result: $testValue");
      
      // Test delete
      await storage.delete(key: 'test_key');
      print("🔍 STORAGE DEBUG - Delete successful");
      
      // Verify deletion
      final deletedValue = await storage.read(key: 'test_key');
      print("🔍 STORAGE DEBUG - After deletion: $deletedValue");
      
    } catch (e, stackTrace) {
      print("🔍 STORAGE DEBUG - Error: $e");
      print("🔍 STORAGE DEBUG - Stack trace: $stackTrace");
    }
  }
}
