import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/dio_client.dart';
import '../features/data/data_sources/AuthLocalDataSource.dart';
import '../features/data/data_sources/AuthRemoteDataSource.dart';
import '../features/data/data_sources/audit_remote_data_source.dart';
import '../features/data/data_sources/eth_payment_remote_data_source.dart';
import '../features/data/data_sources/eth_transaction_data_source.dart';
import '../features/data/data_sources/fake_transactions_data.dart';
import '../features/data/data_sources/walletRemoteDataSource.dart';
import '../features/data/notifiers/audit_notifier.dart';
import '../features/data/repositories_impl/AuthRepositoryImpl.dart';
import '../features/data/repositories_impl/audit_repository_impl.dart';
import '../features/data/repositories_impl/employee_repository_impl.dart';
import '../features/data/services/currency_conversion_service.dart';

import '../features/data/services/eth_payment_service.dart';
import '../features/data/services/private_key_storage.dart';
import '../features/data/services/wallet_service.dart';
import '../features/domain/repositories/auth_repository.dart';
import '../features/domain/repositories/audit_repository.dart';
import '../features/domain/repositories/employee_repository.dart';
import '../features/domain/usecases/Audit/get_audit_report_usecase.dart';
import '../features/domain/usecases/Audit/get_audit_status_usecase.dart';
import '../features/domain/usecases/Audit/submit_audit_usecase.dart';
import '../features/domain/usecases/Audit/upload_contract_usecase.dart';
import '../features/domain/usecases/EmployeeHome/employee_home_usecase.dart';
import '../features/domain/usecases/Employee_management/add_employee_to_team_usecase.dart';
import '../features/domain/usecases/Employee_management/create_payslip_usecase.dart';
import '../features/domain/usecases/Employee_management/get_all_employees_usecase.dart';
import '../features/domain/usecases/Employee_management/get_manager_team_usecase.dart';
import '../features/domain/usecases/Employee_management/get_manager_team_with_wallets_usecase.dart';
import '../features/domain/usecases/Employee_management/get_payslips_usecase.dart';

// Payslip imports
import '../features/data/data_sources/payslip_remote_data_source.dart';
import '../features/data/repositories_impl/payslip_repository_impl.dart';
import '../features/domain/repositories/payslip_repository.dart';
import '../features/domain/usecases/get_user_payslips_use_case.dart';
import '../features/domain/usecases/create_payslip_use_case.dart' as payslip_uc;
import '../features/domain/usecases/generate_payslip_pdf_use_case.dart';
import '../features/domain/usecases/process_payslip_payment_use_case.dart';
import '../features/presentation/manager/Payslip/ViewModels/payslip_list_viewmodel.dart';
import '../features/presentation/manager/Payslip/ViewModels/payslip_list_state.dart';
import '../features/presentation/manager/Payslip/ViewModels/create_payslip_viewmodel.dart';
import '../features/presentation/manager/Payslip/ViewModels/create_payslip_state.dart';

// Payroll imports
import '../features/data/data_sources/payroll_remote_data_source.dart';
import '../features/data/repositories/payroll_repository_impl.dart';
import '../features/domain/repositories/payroll_repository.dart';
import '../features/domain/usecases/payroll/create_payroll_period_usecase.dart';
import '../features/domain/usecases/payroll/get_payroll_periods_usecase.dart';
import '../features/domain/usecases/payroll/process_payroll_period_usecase.dart';
import '../features/domain/usecases/payroll/update_payroll_entry_usecase.dart';
import '../features/domain/usecases/payroll/get_payroll_analytics_usecase.dart';
import '../features/presentation/manager/Payroll/ViewModel/payroll_view_model.dart';
import '../features/domain/usecases/Login/login_usecase.dart';
import '../features/domain/usecases/Logout/logout_usecase.dart';
import '../features/domain/usecases/Register/register_use_case.dart';

import '../features/presentation/employee/HomeEmployee/home_employee_viewmodel/home_employee_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_analysis_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_contract_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_main_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_results_viewmodel.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/logout_viewmodel.dart';
import '../features/presentation/manager/Authentication/Register/ViewModel/register_view_model.dart';
import '../features/presentation/manager/Employee_Management(manager_screens)/employee_viewmodel/employee_viewmodel.dart';
import '../features/presentation/manager/Home/home_ViewModel/home_Viewmodel.dart';


import '../features/data/data_sources/employee_remote_data_source.dart'
    as manager_employee;
import '../features/data/data_sources/EmployeeRemoteDataSource.dart'
    as employee_dashboard;

// -----------------------------------------------------------------------------
// Core configuration providers
// -----------------------------------------------------------------------------

final baseUrlProvider = Provider<String>((ref) {
  if (Platform.isAndroid) {
    return 'http://192.168.0.12:8000';
  }
  return 'http://127.0.0.1:8000';
});

final flutterSecureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());


final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(secureStorage: ref.watch(flutterSecureStorageProvider));
});

final dioClientProvider = Provider<DioClient>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  final dio = Dio()
    ..options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 90000),
    );

  return DioClient(
    dio: dio,
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// -----------------------------------------------------------------------------
// Data sources
// -----------------------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
    baseUrl: ref.watch(baseUrlProvider),
  );
});

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return WalletRemoteDataSource(
    baseUrl: '$baseUrl/api/wallets/',
    dio: ref.watch(dioClientProvider).dio,
  );
});

final privateKeyStorageProvider = Provider<PrivateKeyStorage>((ref) {
  return PrivateKeyStorage(storage: ref.watch(flutterSecureStorageProvider));
});

final currencyConversionServiceProvider = Provider<CurrencyConversionService>((ref) {
  return CurrencyConversionService(dio: ref.watch(dioClientProvider).dio);
});

final ethPaymentRemoteDataSourceProvider =
    Provider<EthPaymentRemoteDataSource>((ref) {
  return EthPaymentRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

final ethPaymentServiceProvider = Provider<EthPaymentService>((ref) {
  return EthPaymentService(remoteDataSource: ref.watch(ethPaymentRemoteDataSourceProvider));
});


final fakeTransactionsDataSourceProvider =
    Provider<FakeTransactionsDataSource>((ref) {
  return FakeTransactionsDataSource(
    ethPaymentService: ref.watch(ethPaymentServiceProvider),
  );
});

final ethTransactionDataSourceProvider =
    Provider<EthTransactionDataSource>((ref) {
  return EthTransactionDataSource(dioClient: ref.watch(dioClientProvider));
});

final managerEmployeeRemoteDataSourceProvider = Provider<
    manager_employee.EmployeeRemoteDataSource>((ref) {
  return manager_employee.EmployeeRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
  );
});

final employeeDashboardRemoteDataSourceProvider =
    Provider<employee_dashboard.EmployeeRemoteDataSource>((ref) {
  return employee_dashboard.EmployeeRemoteDataSourceImpl();
});

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>((ref) {
  return AuditRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

// -----------------------------------------------------------------------------
// Services
// -----------------------------------------------------------------------------

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(
    remoteDataSource: ref.watch(walletRemoteDataSourceProvider),
    storage: ref.watch(privateKeyStorageProvider),
    currencyService: ref.watch(currencyConversionServiceProvider),
  );
});

// -----------------------------------------------------------------------------
// Repositories
// -----------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(
    remoteDataSource: ref.watch(managerEmployeeRemoteDataSourceProvider),
  );
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(remoteDataSource: ref.watch(auditRemoteDataSourceProvider));
});

// -----------------------------------------------------------------------------
// Use cases
// -----------------------------------------------------------------------------

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<Register>((ref) {
  return Register(ref.watch(authRepositoryProvider));
});


final getAllEmployeesUseCaseProvider = Provider<GetAllEmployeesUseCase>((ref) {
  return GetAllEmployeesUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final getManagerTeamUseCaseProvider = Provider<GetManagerTeamUseCase>((ref) {
  return GetManagerTeamUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final getManagerTeamWithWalletsUseCaseProvider = Provider<GetManagerTeamWithWalletsUseCase>((ref) {
  return GetManagerTeamWithWalletsUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final addEmployeeToTeamUseCaseProvider =
    Provider<AddEmployeeToTeamUseCase>((ref) {
  return AddEmployeeToTeamUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final createPayslipUseCaseProvider = Provider<CreatePayslipUseCase>((ref) {
  return CreatePayslipUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final getPayslipsUseCaseProvider = Provider<GetPayslipsUseCase>((ref) {
  return GetPayslipsUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final getEmployeeDashboardDataProvider =
    Provider<GetEmployeeDashboardData>((ref) {
  return GetEmployeeDashboardData(
    dataSource: ref.watch(employeeDashboardRemoteDataSourceProvider),
  );
});

final submitAuditUseCaseProvider = Provider<SubmitAuditUseCase>((ref) {
  return SubmitAuditUseCase(ref.watch(auditRepositoryProvider));
});

final getAuditReportUseCaseProvider = Provider<GetAuditReportUseCase>((ref) {
  return GetAuditReportUseCase(ref.watch(auditRepositoryProvider));
});

final getAuditStatusUseCaseProvider = Provider<GetAuditStatusUseCase>((ref) {
  return GetAuditStatusUseCase(ref.watch(auditRepositoryProvider));
});

final uploadContractUseCaseProvider = Provider<UploadContractUseCase>((ref) {
  return UploadContractUseCase(ref.watch(auditRepositoryProvider));
});

// -----------------------------------------------------------------------------
// ViewModels / Controllers / Notifiers
// -----------------------------------------------------------------------------

final loginViewModelProvider =
    ChangeNotifierProvider<LoginViewModel>((ref) {
  return LoginViewModel(
    loginUseCase: ref.watch(loginUseCaseProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final registerViewModelProvider =
    ChangeNotifierProvider<RegisterViewModel>((ref) {
  return RegisterViewModel(
    registerUseCase: ref.watch(registerUseCaseProvider),
  );
});

final logoutViewModelProvider =
    ChangeNotifierProvider<LogoutViewModel>((ref) {
  return LogoutViewModel(
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final homeEmployeeNotifierProvider =
    StateNotifierProvider<HomeEmployeeNotifier, HomeEmployeeState>((ref) {
  return HomeEmployeeNotifier(
    walletService: ref.watch(walletServiceProvider),
    transactionsDataSource: ref.watch(fakeTransactionsDataSourceProvider),
    getEmployeeDashboardData: ref.watch(getEmployeeDashboardDataProvider),
  );
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(
    walletService: ref.watch(walletServiceProvider),
    ethTransactionDataSource: ref.watch(ethTransactionDataSourceProvider),
  );
});

final auditNotifierProvider = ChangeNotifierProvider<AuditNotifier>((ref) {
  final notifier = AuditNotifier(
    submitAuditUseCase: ref.watch(submitAuditUseCaseProvider),
    getAuditReportUseCase: ref.watch(getAuditReportUseCaseProvider),
    getAuditStatusUseCase: ref.watch(getAuditStatusUseCaseProvider),
    uploadContractUseCase: ref.watch(uploadContractUseCaseProvider),
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

final auditContractViewModelProvider =
    ChangeNotifierProvider<AuditContractViewModel>((ref) {
  final viewModel = AuditContractViewModel(
    uploadContractUseCase: ref.watch(uploadContractUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditAnalysisViewModelProvider =
    ChangeNotifierProvider<AuditAnalysisViewModel>((ref) {
  final viewModel = AuditAnalysisViewModel(
    submitAuditUseCase: ref.watch(submitAuditUseCaseProvider),
    getAuditStatusUseCase: ref.watch(getAuditStatusUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditResultsViewModelProvider =
    ChangeNotifierProvider<AuditResultsViewModel>((ref) {
  final viewModel = AuditResultsViewModel(
    getAuditReportUseCase: ref.watch(getAuditReportUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditMainViewModelProvider =
    ChangeNotifierProvider<AuditMainViewModel>((ref) {
  final viewModel = AuditMainViewModel();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final employeeViewModelProvider =
    ChangeNotifierProvider<EmployeeViewModel>((ref) {
  final viewModel = EmployeeViewModel(
    getAllEmployeesUseCase: ref.watch(getAllEmployeesUseCaseProvider),
    getManagerTeamUseCase: ref.watch(getManagerTeamUseCaseProvider),
    addEmployeeToTeamUseCase: ref.watch(addEmployeeToTeamUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

// -----------------------------------------------------------------------------
// Navigation State Providers (replaces global ValueNotifiers)
// -----------------------------------------------------------------------------

/// Provider for managing the selected page index in the manager navigation
final selectedPageProvider = StateProvider<int>((ref) => 0);

/// Provider for managing the selected page index in the employee navigation
final selectedEmployeePageProvider = StateProvider<int>((ref) => 0);

// -----------------------------------------------------------------------------
// Payslip Providers
// -----------------------------------------------------------------------------

// Data Sources
final payslipRemoteDataSourceProvider = Provider<PayslipRemoteDataSource>((ref) {
  return PayslipRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
    baseUrl: ref.watch(baseUrlProvider),
  );
});

// Repositories
final payslipRepositoryProvider = Provider<PayslipRepository>((ref) {
  return PayslipRepositoryImpl(
    remoteDataSource: ref.watch(payslipRemoteDataSourceProvider),
  );
});

// Use Cases
final getUserPayslipsUseCaseProvider = Provider<GetUserPayslipsUseCase>((ref) {
  return GetUserPayslipsUseCase(ref.watch(payslipRepositoryProvider));
});

final createPayslipUseCaseNewProvider = Provider<payslip_uc.CreatePayslipUseCase>((ref) {
  return payslip_uc.CreatePayslipUseCase(ref.watch(payslipRepositoryProvider));
});

final generatePayslipPdfUseCaseProvider = Provider<GeneratePayslipPdfUseCase>((ref) {
  return GeneratePayslipPdfUseCase(ref.watch(payslipRepositoryProvider));
});

final processPayslipPaymentUseCaseProvider = Provider<ProcessPayslipPaymentUseCase>((ref) {
  return ProcessPayslipPaymentUseCase(ref.watch(payslipRepositoryProvider));
});

// ViewModels
final payslipListViewModelProvider = StateNotifierProvider<PayslipListViewModel, PayslipListState>((ref) {
  return PayslipListViewModel(ref.watch(getUserPayslipsUseCaseProvider));
});

final createPayslipViewModelProvider = StateNotifierProvider<CreatePayslipViewModel, CreatePayslipState>((ref) {
  return CreatePayslipViewModel(ref.watch(createPayslipUseCaseNewProvider));
});

// -----------------------------------------------------------------------------
// Payroll Providers
// -----------------------------------------------------------------------------

// Data Sources
final payrollRemoteDataSourceProvider = Provider<PayrollRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PayrollRemoteDataSourceImpl(dio: dioClient.dio);
});

// Repository
final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepositoryImpl(
    remoteDataSource: ref.watch(payrollRemoteDataSourceProvider),
  );
});

// Use Cases
final createPayrollPeriodUseCaseProvider = Provider<CreatePayrollPeriodUseCase>((ref) {
  return CreatePayrollPeriodUseCase(repository: ref.watch(payrollRepositoryProvider));
});

final getPayrollPeriodsUseCaseProvider = Provider<GetPayrollPeriodsUseCase>((ref) {
  return GetPayrollPeriodsUseCase(repository: ref.watch(payrollRepositoryProvider));
});

final processPayrollPeriodUseCaseProvider = Provider<ProcessPayrollPeriodUseCase>((ref) {
  return ProcessPayrollPeriodUseCase(repository: ref.watch(payrollRepositoryProvider));
});

final updatePayrollEntryUseCaseProvider = Provider<UpdatePayrollEntryUseCase>((ref) {
  return UpdatePayrollEntryUseCase(repository: ref.watch(payrollRepositoryProvider));
});

final getPayrollAnalyticsUseCaseProvider = Provider<GetPayrollAnalyticsUseCase>((ref) {
  return GetPayrollAnalyticsUseCase(repository: ref.watch(payrollRepositoryProvider));
});

// ViewModel
final payrollViewModelProvider = StateNotifierProvider<PayrollViewModel, PayrollState>((ref) {
  return PayrollViewModel(
    getPayrollPeriodsUseCase: ref.watch(getPayrollPeriodsUseCaseProvider),
    createPayrollPeriodUseCase: ref.watch(createPayrollPeriodUseCaseProvider),
    processPayrollPeriodUseCase: ref.watch(processPayrollPeriodUseCaseProvider),
    updatePayrollEntryUseCase: ref.watch(updatePayrollEntryUseCaseProvider),
    getPayrollAnalyticsUseCase: ref.watch(getPayrollAnalyticsUseCaseProvider),
  );
});
