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
import '../features/data/services/device_approval_cache.dart';
import '../features/data/services/device_info_service.dart';
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
import '../features/domain/usecases/Employee_management/get_payslips_usecase.dart';
import '../features/domain/usecases/Login/login_usecase.dart';
import '../features/domain/usecases/Logout/logout_check_usecase.dart';
import '../features/domain/usecases/Logout/logout_force_usecase.dart';
import '../features/domain/usecases/Logout/logout_usecase.dart';
import '../features/domain/usecases/Register/register_use_case.dart';
import '../features/domain/usecases/Session/approve_session_usecase.dart';
import '../features/domain/usecases/Session/confirm_password_usecase.dart';
import '../features/domain/usecases/Session/get_sessions_usecase.dart';
import '../features/domain/usecases/Session/get_transferable_sessions_usecase.dart';
import '../features/domain/usecases/Session/revoke_other_sessions_usecase.dart';
import '../features/domain/usecases/Session/revoke_session_usecase.dart';
import '../features/domain/usecases/Session/transfer_main_device_usecase.dart';
import '../features/domain/usecases/Session/validate_session_usecase.dart';
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
import '../features/presentation/manager/SessionManagement/session_management_controller.dart';
import '../features/presentation/manager/SessionManagement/session_management_viewmodel.dart';

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

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoServiceImpl();
});

final deviceApprovalCacheProvider = Provider<DeviceApprovalCache>((ref) {
  return DeviceApprovalCache(storage: ref.watch(flutterSecureStorageProvider));
});

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
    deviceInfoService: ref.watch(deviceInfoServiceProvider),
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

final logoutCheckUseCaseProvider = Provider<LogoutCheck>((ref) {
  return LogoutCheck(ref.watch(authRepositoryProvider));
});

final logoutForceUseCaseProvider = Provider<LogoutForce>((ref) {
  return LogoutForce(ref.watch(authRepositoryProvider));
});

final getSessionsUseCaseProvider = Provider<GetSessions>((ref) {
  return GetSessions(ref.watch(authRepositoryProvider));
});

final getTransferableSessionsUseCaseProvider =
    Provider<GetTransferableSessions>((ref) {
  return GetTransferableSessions(ref.watch(authRepositoryProvider));
});

final transferMainDeviceUseCaseProvider =
    Provider<TransferMainDevice>((ref) {
  return TransferMainDevice(ref.watch(authRepositoryProvider));
});

final approveSessionUseCaseProvider = Provider<ApproveSession>((ref) {
  return ApproveSession(ref.watch(authRepositoryProvider));
});

final revokeSessionUseCaseProvider = Provider<RevokeSession>((ref) {
  return RevokeSession(ref.watch(authRepositoryProvider));
});

final revokeOtherSessionsUseCaseProvider = Provider<RevokeOtherSessions>((ref) {
  return RevokeOtherSessions(ref.watch(authRepositoryProvider));
});

final confirmPasswordUseCaseProvider = Provider<ConfirmPassword>((ref) {
  return ConfirmPassword(ref.watch(authRepositoryProvider));
});

final validateSessionUseCaseProvider = Provider<ValidateSession>((ref) {
  return ValidateSession(ref.watch(authRepositoryProvider));
});

final getAllEmployeesUseCaseProvider = Provider<GetAllEmployeesUseCase>((ref) {
  return GetAllEmployeesUseCase(repository: ref.watch(employeeRepositoryProvider));
});

final getManagerTeamUseCaseProvider = Provider<GetManagerTeamUseCase>((ref) {
  return GetManagerTeamUseCase(repository: ref.watch(employeeRepositoryProvider));
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
    deviceInfoService: ref.watch(deviceInfoServiceProvider),
    deviceApprovalCache: ref.watch(deviceApprovalCacheProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final registerViewModelProvider =
    ChangeNotifierProvider<RegisterViewModel>((ref) {
  return RegisterViewModel(
    registerUseCase: ref.watch(registerUseCaseProvider),
    deviceInfoService: ref.watch(deviceInfoServiceProvider),
  );
});

final logoutViewModelProvider =
    ChangeNotifierProvider<LogoutViewModel>((ref) {
  return LogoutViewModel(
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    logoutForceUseCase: ref.watch(logoutForceUseCaseProvider),
    logoutCheckUseCase: ref.watch(logoutCheckUseCaseProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final sessionManagementViewModelProvider =
    ChangeNotifierProvider<SessionManagementViewModel>((ref) {
  return SessionManagementViewModel();
});

final sessionManagementControllerProvider =
    Provider<SessionManagementController>((ref) {
  return SessionManagementController(
    getSessions: ref.watch(getSessionsUseCaseProvider),
    approveSession: ref.watch(approveSessionUseCaseProvider),
    revokeSession: ref.watch(revokeSessionUseCaseProvider),
    revokeOtherSessions: ref.watch(revokeOtherSessionsUseCaseProvider),
    viewModel: ref.watch(sessionManagementViewModelProvider),
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
    getAllEmployeesUseCase: ref.read(getAllEmployeesUseCaseProvider),
    getManagerTeamUseCase: ref.read(getManagerTeamUseCaseProvider),
    addEmployeeToTeamUseCase: ref.read(addEmployeeToTeamUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
