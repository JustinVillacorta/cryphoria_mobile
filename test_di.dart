// Quick test to verify GetIt registration
import 'package:flutter/material.dart';
import 'lib/dependency_injection/di.dart';
import 'lib/features/presentation/pages/Audit/ViewModels/audit_main_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize DI
    await init();
    print("✅ DI initialization successful");
    
    // Test AuditMainViewModel registration
    final mainViewModel1 = sl<AuditMainViewModel>();
    final mainViewModel2 = sl<AuditMainViewModel>();
    
    print("✅ AuditMainViewModel retrieved successfully");
    print("🔍 Are instances the same? ${identical(mainViewModel1, mainViewModel2)}");
    
    if (identical(mainViewModel1, mainViewModel2)) {
      print("🎉 SUCCESS: Singleton behavior working correctly!");
    } else {
      print("❌ ERROR: Expected singleton behavior but got different instances");
    }
    
  } catch (e) {
    print("❌ DI Error: $e");
  }
}
