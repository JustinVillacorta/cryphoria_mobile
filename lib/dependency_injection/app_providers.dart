import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/di.dart' as di;
import 'package:cryphoria_mobile/features/data/notifiers/audit_notifier.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_viewmodel/home_employee_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/ViewModels/audit_analysis_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/ViewModels/audit_contract_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/ViewModels/audit_main_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/ViewModels/audit_results_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Employee_Management(manager_screens)/employee_viewmodel/employee_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Home/home_ViewModel/home_Viewmodel.dart';

// Shared Riverpod providers for ChangeNotifier-based view models and notifiers.

final auditNotifierProvider = ChangeNotifierProvider<AuditNotifier>((ref) {
  final notifier = di.sl<AuditNotifier>();
  ref.onDispose(notifier.dispose);
  return notifier;
});

final homeEmployeeNotifierProvider =
    StateNotifierProvider<HomeEmployeeNotifier, HomeEmployeeState>((ref) {
  return di.sl<HomeEmployeeNotifier>();
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return di.sl<WalletNotifier>();
});

final auditContractViewModelProvider = ChangeNotifierProvider<AuditContractViewModel>((ref) {
  final viewModel = di.sl<AuditContractViewModel>();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditAnalysisViewModelProvider = ChangeNotifierProvider<AuditAnalysisViewModel>((ref) {
  final viewModel = di.sl<AuditAnalysisViewModel>();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditResultsViewModelProvider = ChangeNotifierProvider<AuditResultsViewModel>((ref) {
  final viewModel = di.sl<AuditResultsViewModel>();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditMainViewModelProvider = ChangeNotifierProvider<AuditMainViewModel>((ref) {
  final viewModel = di.sl<AuditMainViewModel>();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final employeeViewModelProvider = ChangeNotifierProvider<EmployeeViewModel>((ref) {
  final viewModel = di.sl<EmployeeViewModel>();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
