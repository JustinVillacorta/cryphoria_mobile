import 'dart:io';

import 'package:cryphoria_mobile/features/data/data_sources/invoice_remote_data_source.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/invoice_repository_impl.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/ChangePassword/change_password_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/ChangePassword/change_password_viewmodel.dart';
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
import '../features/data/data_sources/reports_remote_data_source.dart';
import '../features/data/data_sources/walletRemoteDataSource.dart';
import '../features/data/data_sources/document_upload_remote_data_source.dart';
import '../features/data/data_sources/support_remote_data_source.dart';
import '../features/data/repositories_impl/support_repository_impl.dart';
import '../features/domain/repositories/support_repository.dart';
import '../features/domain/usecases/Support/submit_support_ticket_usecase.dart';
import '../features/domain/usecases/Support/get_support_messages_usecase.dart';
import '../features/presentation/manager/UserProfile/HelpandSupport/support_viewmodel.dart';
import '../features/data/notifiers/audit_notifier.dart';
import '../features/data/repositories_impl/AuthRepositoryImpl.dart';
import '../features/data/repositories_impl/audit_repository_impl.dart';
import '../features/data/repositories_impl/employee_repository_impl.dart';
import '../features/data/repositories_impl/reports_repository_impl.dart';
import '../features/data/repositories_impl/document_upload_repository_impl.dart';
import '../features/data/services/currency_conversion_service.dart';

import '../features/data/services/eth_payment_service.dart';
// private_key_storage.dart removed - private keys now stored on backend
import '../features/data/services/wallet_service.dart';
import '../features/domain/repositories/auth_repository.dart';
import '../features/domain/repositories/audit_repository.dart';
import '../features/domain/repositories/employee_repository.dart';
import '../features/domain/repositories/reports_repository.dart';
import '../features/domain/usecases/Audit/get_audit_report_usecase.dart';
import '../features/domain/usecases/Audit/get_audit_status_usecase.dart';
import '../features/domain/usecases/Audit/submit_audit_usecase.dart';
import '../features/domain/usecases/Audit/upload_contract_usecase.dart';
import '../features/domain/usecases/DocumentUpload/upload_business_documents_usecase.dart';
import '../features/domain/repositories/document_upload_repository.dart';
import '../features/domain/usecases/EmployeeHome/employee_home_usecase.dart';
import '../features/domain/usecases/Employee_management/add_employee_to_team_usecase.dart';
import '../features/domain/usecases/Employee_management/remove_employee_from_team_usecase.dart';
import '../features/domain/usecases/Employee_management/create_payslip_usecase.dart';
import '../features/domain/usecases/Employee_management/get_all_employees_usecase.dart';
import '../features/domain/usecases/Employee_management/get_manager_team_usecase.dart';
import '../features/domain/usecases/Employee_management/get_manager_team_with_wallets_usecase.dart';
import '../features/domain/usecases/Employee_management/get_payslips_usecase.dart';

// Payslip imports
import '../features/data/data_sources/payslip_remote_data_source.dart';
import '../features/data/repositories_impl/payslip_repository_impl.dart';
import '../features/domain/repositories/payslip_repository.dart';
import '../features/domain/usecases/payslip/get_user_payslips_use_case.dart';
import '../features/domain/usecases/payslip/create_payslip_use_case.dart' as payslip_uc;
import '../features/domain/usecases/payslip/generate_payslip_pdf_use_case.dart';
import '../features/domain/usecases/payslip/process_payslip_payment_use_case.dart';
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
import '../features/domain/usecases/OTP_Verification/verify_otp_use_case.dart';
import '../features/domain/usecases/OTP_Verification/resend_otp_use_case.dart';
import '../features/domain/usecases/Forgot_Password/request_password_reset_use_case.dart';
import '../features/domain/usecases/Forgot_Password/reset_password_use_case.dart';
import '../features/domain/usecases/Forgot_Password/resend_password_reset_use_case.dart';
import '../features/domain/usecases/Reports/generate_report_usecase.dart';
import '../features/domain/usecases/Reports/get_report_status_usecase.dart';
import '../features/domain/usecases/Reports/get_user_reports_usecase.dart';

import '../features/presentation/employee/HomeEmployee/home_employee_viewmodel/home_employee_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_analysis_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_contract_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_main_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_results_viewmodel.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/logout_viewmodel.dart';
import '../features/presentation/manager/Reports/Reports_ViewModel/income_statement_viewmodel.dart';
import '../features/presentation/manager/Reports/Reports_ViewModel/investment_report_viewmodel.dart';
import '../features/presentation/manager/Authentication/Register/ViewModel/register_view_model.dart';
import '../features/presentation/manager/Authentication/OTP_Verification/ViewModel/otp_verification_view_model.dart';
import '../features/presentation/manager/Authentication/Forgot_Password/ViewModel/forgot_password_request_view_model.dart';
import '../features/presentation/manager/Authentication/Forgot_Password/ViewModel/forgot_password_confirm_view_model.dart';
import '../features/presentation/manager/Employee_Management(manager_screens)/employee_viewmodel/employee_viewmodel.dart';
import '../features/presentation/manager/Home/home_ViewModel/home_Viewmodel.dart';


import '../features/data/data_sources/employee_remote_data_source.dart'
    as manager_employee;
import '../features/data/data_sources/employee_remote_data_source.dart'
    as employee_dashboard;

import '../features/domain/repositories/invoice_repository.dart';
import '../features/domain/usecases/Invoice/get_invoice_by_id_usecase.dart';
import '../features/domain/usecases/Invoice/get_invoices_by_user_usecase.dart';
import '../features/domain/usecases/Profile/get_profile_usecase.dart';
import '../features/domain/usecases/Profile/update_profile_usecase.dart';






// -----------------------------------------------------------------------------
// Core configuration providers
// -----------------------------------------------------------------------------


final baseUrlProvider = Provider<String>((ref) {
  if (Platform.isAndroid) {
    return 'http://10.250.148.205:8000';
  }
  return 'http://192.168.5.53:8000';
});

final flutterSecureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

// for username fetching
final userProvider = StateProvider<AuthUser?>((ref) {
  ref.keepAlive(); // Cache user state to prevent recreation on navigation
  return null;
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

// PrivateKeyStorage removed - private keys now stored on backend

final currencyConversionServiceProvider = Provider<CurrencyConversionService>((ref) {
  return CurrencyConversionService(dio: ref.watch(dioClientProvider).dio);
});

final ethPaymentRemoteDataSourceProvider =
    Provider<EthPaymentRemoteDataSource>((ref) {
  return EthPaymentRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

final ethPaymentServiceProvider = Provider<EthPaymentService>((ref) {
  return EthPaymentService(
    remoteDataSource: ref.watch(ethPaymentRemoteDataSourceProvider),
    walletService: ref.watch(walletServiceProvider),
  );
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

// Document Upload Providers
final documentUploadRemoteDataSourceProvider = Provider<DocumentUploadRemoteDataSource>((ref) {
  return DocumentUploadRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

final documentUploadRepositoryProvider = Provider<DocumentUploadRepository>((ref) {
  return DocumentUploadRepositoryImpl(
    remoteDataSource: ref.watch(documentUploadRemoteDataSourceProvider),
  );
});

final uploadBusinessDocumentsUseCaseProvider = Provider<UploadBusinessDocumentsUseCase>((ref) {
  return UploadBusinessDocumentsUseCase(
    repository: ref.watch(documentUploadRepositoryProvider),
  );
});

final managerEmployeeRemoteDataSourceProvider = Provider<
    manager_employee.EmployeeRemoteDataSource>((ref) {
  return manager_employee.EmployeeRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
  );
});

final employeeDashboardRemoteDataSourceProvider =
    Provider<employee_dashboard.EmployeeRemoteDataSource>((ref) {
  return employee_dashboard.EmployeeRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
  );
});

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>((ref) {
  return AuditRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

final reportsRemoteDataSourceProvider = Provider<ReportsRemoteDataSource>((ref) {
  return ReportsRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

// -----------------------------------------------------------------------------
// Services
// -----------------------------------------------------------------------------

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(
    remoteDataSource: ref.watch(walletRemoteDataSourceProvider),
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

// Profile use cases
final getProfileUseCaseProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.watch(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(authRepositoryProvider));
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(
    remoteDataSource: ref.watch(managerEmployeeRemoteDataSourceProvider),
  );
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(remoteDataSource: ref.watch(auditRemoteDataSourceProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(
    remoteDataSource: ref.watch(reportsRemoteDataSourceProvider),
    auditRemoteDataSource: ref.watch(auditRemoteDataSourceProvider),
  );
});

final incomeStatementViewModelProvider = StateNotifierProvider<IncomeStatementViewModel, IncomeStatementState>((ref) {
  return IncomeStatementViewModel(ref.watch(reportsRepositoryProvider));
});

final investmentReportViewModelProvider = StateNotifierProvider<InvestmentReportViewModel, InvestmentReportState>((ref) {
  return InvestmentReportViewModel(ref.watch(reportsRepositoryProvider));
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

final verifyOTPUseCaseProvider = Provider<VerifyOTP>((ref) {
  return VerifyOTP(ref.watch(authRepositoryProvider));
});

final resendOTPUseCaseProvider = Provider<ResendOTP>((ref) {
  return ResendOTP(ref.watch(authRepositoryProvider));
});

final requestPasswordResetUseCaseProvider = Provider<RequestPasswordReset>((ref) {
  return RequestPasswordReset(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPassword>((ref) {
  return ResetPassword(ref.watch(authRepositoryProvider));
});

final resendPasswordResetUseCaseProvider = Provider<ResendPasswordReset>((ref) {
  return ResendPasswordReset(ref.watch(authRepositoryProvider));
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

final removeEmployeeFromTeamUseCaseProvider =
    Provider<RemoveEmployeeFromTeamUseCase>((ref) {
  return RemoveEmployeeFromTeamUseCase(repository: ref.watch(employeeRepositoryProvider));
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

final generateReportUseCaseProvider = Provider<GenerateReportUseCase>((ref) {
  return GenerateReportUseCase(ref.watch(reportsRepositoryProvider));
});

final getReportStatusUseCaseProvider = Provider<GetReportStatusUseCase>((ref) {
  return GetReportStatusUseCase(ref.watch(reportsRepositoryProvider));
});

final getUserReportsUseCaseProvider = Provider<GetUserReportsUseCase>((ref) {
  return GetUserReportsUseCase(ref.watch(reportsRepositoryProvider));
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

final otpVerificationViewModelProvider =
    ChangeNotifierProvider<OTPVerificationViewModel>((ref) {
  return OTPVerificationViewModel(
    verifyOTPUseCase: ref.watch(verifyOTPUseCaseProvider),
    resendOTPUseCase: ref.watch(resendOTPUseCaseProvider),
  );
});

final forgotPasswordRequestViewModelProvider =
    ChangeNotifierProvider<ForgotPasswordRequestViewModel>((ref) {
  return ForgotPasswordRequestViewModel(
    requestPasswordResetUseCase: ref.watch(requestPasswordResetUseCaseProvider),
  );
});

final forgotPasswordConfirmViewModelProvider =
    ChangeNotifierProvider<ForgotPasswordConfirmViewModel>((ref) {
  return ForgotPasswordConfirmViewModel(
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    resendPasswordResetUseCase: ref.watch(resendPasswordResetUseCaseProvider),
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
  // Home employee provider refreshes to get real-time data
  return HomeEmployeeNotifier(
    walletService: ref.watch(walletServiceProvider),
    transactionsDataSource: ref.watch(fakeTransactionsDataSourceProvider),
    getEmployeeDashboardData: ref.watch(getEmployeeDashboardDataProvider),
  );
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  ref.keepAlive(); // Keep wallet provider alive to prevent recreation
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
  ref.keepAlive(); // Cache ViewModel to prevent recreation on navigation
  final viewModel = AuditResultsViewModel(
    getAuditReportUseCase: ref.watch(getAuditReportUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final auditMainViewModelProvider =
    ChangeNotifierProvider<AuditMainViewModel>((ref) {
  ref.keepAlive(); // Cache ViewModel to prevent recreation on navigation
  final viewModel = AuditMainViewModel();
  ref.onDispose(viewModel.dispose);
  return viewModel;
});

final employeeViewModelProvider =
    ChangeNotifierProvider<EmployeeViewModel>((ref) {
  ref.keepAlive(); // Cache ViewModel to prevent recreation on navigation
  final viewModel = EmployeeViewModel(
    getAllEmployeesUseCase: ref.watch(getAllEmployeesUseCaseProvider),
    getManagerTeamUseCase: ref.watch(getManagerTeamUseCaseProvider),
    addEmployeeToTeamUseCase: ref.watch(addEmployeeToTeamUseCaseProvider),
    removeEmployeeFromTeamUseCase: ref.watch(removeEmployeeFromTeamUseCaseProvider),
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

final invoiceRemoteDataSourceProvider = Provider<InvoiceRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return InvoiceRemoteDataSource(dio: dioClient.dio);
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(
    remoteDataSource: ref.watch(invoiceRemoteDataSourceProvider),
  );
});

// --- UseCase providers ---
final getInvoicesByUserUseCaseProvider = Provider<GetInvoicesByUser>((ref) {
  return GetInvoicesByUser(ref.read(invoiceRepositoryProvider));
});

final getInvoiceByIdUseCaseProvider = Provider<GetInvoiceById>((ref) {  // Renamed
  return GetInvoiceById(ref.read(invoiceRepositoryProvider));
});

// --- Async providers used by the UI ---
// Fetch invoices for a given userId
final invoicesByUserProvider = FutureProvider.family<List<Invoice>, String>((ref, userId) async {
  ref.keepAlive(); // Cache data to prevent unnecessary refetches on navigation
  final getInvoices = ref.read(getInvoicesByUserUseCaseProvider);
  return await getInvoices(userId);
});

// Fetch a single invoice by invoiceId
final invoiceByIdProvider = FutureProvider.family<Invoice, String>((ref, invoiceId) async {
  ref.keepAlive(); // Cache data to prevent unnecessary refetches on navigation
  final getInvoice = ref.read(getInvoiceByIdUseCaseProvider);  // Now references the correct provider
  return await getInvoice(invoiceId);
});


final managerChangePasswordVmProvider = StateNotifierProvider<
    ManagerChangePasswordViewModel, AsyncValue<void>>((ref) {
  // Ensures an AuthRepository is available via authRepositoryProvider
  ref.read(authRepositoryProvider);
  return ManagerChangePasswordViewModel(ref);
});

final employeeChangePasswordVmProvider = StateNotifierProvider<
    EmployeeChangePasswordViewModel, AsyncValue<void>>((ref) {
  ref.read(authRepositoryProvider);
  return EmployeeChangePasswordViewModel(ref);
});

// -----------------------------------------------------------------------------
// Support Providers
// -----------------------------------------------------------------------------

// Data Sources
final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  return SupportRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

// Repository
final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl(
    remoteDataSource: ref.watch(supportRemoteDataSourceProvider),
  );
});

// Use Cases
final submitSupportTicketUseCaseProvider = Provider<SubmitSupportTicketUseCase>((ref) {
  return SubmitSupportTicketUseCase(
    repository: ref.watch(supportRepositoryProvider),
  );
});

final getSupportMessagesUseCaseProvider = Provider<GetSupportMessagesUseCase>((ref) {
  return GetSupportMessagesUseCase(
    repository: ref.watch(supportRepositoryProvider),
  );
});

// ViewModel
final supportViewModelProvider = ChangeNotifierProvider<SupportViewModel>((ref) {
  final viewModel = SupportViewModel(
    submitSupportTicketUseCase: ref.watch(submitSupportTicketUseCaseProvider),
    getSupportMessagesUseCase: ref.watch(getSupportMessagesUseCaseProvider),
  );
  ref.onDispose(viewModel.dispose);
  return viewModel;
});
