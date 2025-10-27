import 'dart:io';

import 'package:cryphoria_mobile/features/data/data_sources/invoice_remote_data_source.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/invoice_repository_impl.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/domain/entities/invoice.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/ChangePassword/change_password_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Home/home_ViewModel/home_view_model.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/ChangePassword/change_password_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/dio_client.dart';
import '../features/data/data_sources/auth_local_data_source.dart';
import '../features/data/data_sources/auth_remote_data_source.dart';
import '../features/data/data_sources/audit_remote_data_source.dart';
import '../features/data/data_sources/eth_payment_remote_data_source.dart';
import '../features/data/data_sources/eth_transaction_data_source.dart';
import '../features/data/data_sources/fake_transactions_data.dart';
import '../features/data/data_sources/reports_remote_data_source.dart';
import '../features/data/data_sources/wallet_remote_data_source.dart';
import '../features/data/data_sources/document_upload_remote_data_source.dart';
import '../features/data/data_sources/support_remote_data_source.dart';
import '../features/data/repositories_impl/support_repository_impl.dart';
import '../features/domain/repositories/support_repository.dart';
import '../features/domain/usecases/Support/submit_support_ticket_usecase.dart';
import '../features/domain/usecases/Support/get_support_messages_usecase.dart';
import '../features/presentation/manager/UserProfile/HelpandSupport/support_viewmodel.dart';
import '../features/presentation/manager/UserProfile/HelpandSupport/support_state.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_upload_viewmodel.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_upload_state.dart';
import '../features/presentation/manager/Audit/ViewModels/audit_flow_viewmodel.dart';
import '../features/data/repositories_impl/auth_repository_impl.dart';
import '../features/data/repositories_impl/audit_repository_impl.dart';
import '../features/data/repositories_impl/employee_repository_impl.dart';
import '../features/data/repositories_impl/reports_repository_impl.dart';
import '../features/data/repositories_impl/document_upload_repository_impl.dart';
import '../features/data/services/currency_conversion_service.dart';

import '../features/data/services/eth_payment_service.dart';
import '../features/data/services/wallet_service.dart';
import '../features/domain/repositories/auth_repository.dart';
import '../features/domain/repositories/audit_repository.dart';
import '../features/domain/repositories/employee_repository.dart';
import '../features/domain/repositories/reports_repository.dart';
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
import '../features/presentation/manager/Authentication/LogIn/ViewModel/login_view_model.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/login_state.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/logout_viewmodel.dart';
import '../features/presentation/manager/Authentication/LogIn/ViewModel/logout_state.dart';
import '../features/presentation/manager/Reports/Reports_ViewModel/income_statement_viewmodel.dart';
import '../features/presentation/manager/Authentication/Register/ViewModel/register_view_model.dart';
import '../features/presentation/manager/Authentication/Register/ViewModel/register_state.dart';
import '../features/presentation/manager/Authentication/OTP_Verification/ViewModel/otp_verification_view_model.dart';
import '../features/presentation/manager/Authentication/OTP_Verification/ViewModel/otp_verification_state.dart';
import '../features/presentation/manager/Authentication/Forgot_Password/ViewModel/forgot_password_request_view_model.dart';
import '../features/presentation/manager/Authentication/Forgot_Password/ViewModel/forgot_password_request_state.dart';
import '../features/presentation/manager/Authentication/Forgot_Password/ViewModel/forgot_password_confirm_view_model.dart';
import '../features/presentation/manager/Authentication/Forgot_Password/ViewModel/forgot_password_confirm_state.dart';
import '../features/presentation/manager/Employee_Management(manager_screens)/employee_viewmodel/employee_viewmodel.dart';
import '../features/presentation/manager/Employee_Management(manager_screens)/employee_viewmodel/employee_state.dart';


import '../features/data/data_sources/employee_remote_data_source.dart'
    as manager_employee;
import '../features/data/data_sources/employee_remote_data_source.dart'
    as employee_dashboard;

import '../features/domain/repositories/invoice_repository.dart';
import '../features/domain/usecases/Invoice/get_invoice_by_id_usecase.dart';
import '../features/domain/usecases/Invoice/get_invoices_by_user_usecase.dart';
import '../features/domain/usecases/Profile/get_profile_usecase.dart';
import '../features/domain/usecases/Profile/update_profile_usecase.dart';





final baseUrlProvider = Provider<String>((ref) {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://192.168.5.53:8000';
});

final flutterSecureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final userProvider = StateProvider<AuthUser?>((ref) {
  ref.keepAlive();
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
      connectTimeout: const Duration(seconds: 480),
      receiveTimeout: const Duration(seconds: 480),
      sendTimeout: const Duration(seconds: 480),
    );

  return DioClient(
    dio: dio,
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});


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


final transactionsDataSourceProvider =
    Provider<TransactionsDataSource>((ref) {
  return TransactionsDataSource(
    ethPaymentService: ref.watch(ethPaymentServiceProvider),
  );
});

final ethTransactionDataSourceProvider =
    Provider<EthTransactionDataSource>((ref) {
  return EthTransactionDataSource(dioClient: ref.watch(dioClientProvider));
});


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


final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(
    remoteDataSource: ref.watch(walletRemoteDataSourceProvider),
    currencyService: ref.watch(currencyConversionServiceProvider),
  );
});


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

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

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(
    loginUseCase: ref.watch(loginUseCaseProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final registerViewModelProvider =
    StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
  return RegisterViewModel(
    registerUseCase: ref.watch(registerUseCaseProvider),
  );
});

final otpVerificationViewModelProvider =
    StateNotifierProvider<OTPVerificationViewModel, OTPVerificationState>((ref) {
  return OTPVerificationViewModel(
    verifyOTPUseCase: ref.watch(verifyOTPUseCaseProvider),
    resendOTPUseCase: ref.watch(resendOTPUseCaseProvider),
  );
});

final forgotPasswordRequestViewModelProvider =
    StateNotifierProvider<ForgotPasswordRequestViewModel, ForgotPasswordRequestState>((ref) {
  return ForgotPasswordRequestViewModel(
    requestPasswordResetUseCase: ref.watch(requestPasswordResetUseCaseProvider),
  );
});

final forgotPasswordConfirmViewModelProvider =
    StateNotifierProvider<ForgotPasswordConfirmViewModel, ForgotPasswordConfirmState>((ref) {
  return ForgotPasswordConfirmViewModel(
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    resendPasswordResetUseCase: ref.watch(resendPasswordResetUseCaseProvider),
  );
});

final logoutViewModelProvider =
    StateNotifierProvider<LogoutViewModel, LogoutState>((ref) {
  return LogoutViewModel(
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final homeEmployeeNotifierProvider =
    StateNotifierProvider<HomeEmployeeNotifier, HomeEmployeeState>((ref) {
  return HomeEmployeeNotifier(
    walletService: ref.watch(walletServiceProvider),
    transactionsDataSource: ref.watch(transactionsDataSourceProvider),
    getEmployeeDashboardData: ref.watch(getEmployeeDashboardDataProvider),
  );
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  ref.keepAlive();
  return WalletNotifier(
    walletService: ref.watch(walletServiceProvider),
    ethTransactionDataSource: ref.watch(ethTransactionDataSourceProvider),
  );
});

final auditUploadViewModelProvider =
    StateNotifierProvider<AuditUploadViewModel, AuditUploadState>((ref) {
  return AuditUploadViewModel(
    uploadContractUseCase: ref.watch(uploadContractUseCaseProvider),
  );
});

final auditFlowViewModelProvider =
    StateNotifierProvider<AuditFlowViewModel, AuditFlowState>((ref) {
  return AuditFlowViewModel();
});

final employeeViewModelProvider =
    StateNotifierProvider<EmployeeViewModel, EmployeeState>((ref) {
  return EmployeeViewModel(
    getAllEmployeesUseCase: ref.watch(getAllEmployeesUseCaseProvider),
    getManagerTeamUseCase: ref.watch(getManagerTeamUseCaseProvider),
    addEmployeeToTeamUseCase: ref.watch(addEmployeeToTeamUseCaseProvider),
    removeEmployeeFromTeamUseCase: ref.watch(removeEmployeeFromTeamUseCaseProvider),
  );
});



final selectedPageProvider = StateProvider<int>((ref) => 0);
final selectedEmployeePageProvider = StateProvider<int>((ref) => 0);

final payslipRemoteDataSourceProvider = Provider<PayslipRemoteDataSource>((ref) {
  return PayslipRemoteDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
    baseUrl: ref.watch(baseUrlProvider),
  );
});


final payslipRepositoryProvider = Provider<PayslipRepository>((ref) {
  return PayslipRepositoryImpl(
    remoteDataSource: ref.watch(payslipRemoteDataSourceProvider),
  );
});


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

final payslipListViewModelProvider = StateNotifierProvider<PayslipListViewModel, PayslipListState>((ref) {
  return PayslipListViewModel(ref.watch(getUserPayslipsUseCaseProvider));
});

final createPayslipViewModelProvider = StateNotifierProvider<CreatePayslipViewModel, CreatePayslipState>((ref) {
  return CreatePayslipViewModel(ref.watch(createPayslipUseCaseNewProvider));
});


final payrollRemoteDataSourceProvider = Provider<PayrollRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PayrollRemoteDataSourceImpl(dio: dioClient.dio);
});


final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepositoryImpl(
    remoteDataSource: ref.watch(payrollRemoteDataSourceProvider),
  );
});

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

final getInvoicesByUserUseCaseProvider = Provider<GetInvoicesByUser>((ref) {
  return GetInvoicesByUser(ref.read(invoiceRepositoryProvider));
});

final getInvoiceByIdUseCaseProvider = Provider<GetInvoiceById>((ref) {
  return GetInvoiceById(ref.read(invoiceRepositoryProvider));
});

final invoicesByUserProvider = FutureProvider.family<List<Invoice>, String>((ref, userId) async {
  ref.keepAlive();
  final getInvoices = ref.read(getInvoicesByUserUseCaseProvider);
  return await getInvoices(userId);
});

final invoiceByIdProvider = FutureProvider.family<Invoice, String>((ref, invoiceId) async {
  ref.keepAlive();
  final getInvoice = ref.read(getInvoiceByIdUseCaseProvider);
  return await getInvoice(invoiceId);
});


final managerChangePasswordVmProvider = StateNotifierProvider<
    ManagerChangePasswordViewModel, AsyncValue<void>>((ref) {
  ref.read(authRepositoryProvider);
  return ManagerChangePasswordViewModel(ref);
});

final employeeChangePasswordVmProvider = StateNotifierProvider<
    EmployeeChangePasswordViewModel, AsyncValue<void>>((ref) {
  ref.read(authRepositoryProvider);
  return EmployeeChangePasswordViewModel(ref);
});


final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  return SupportRemoteDataSourceImpl(dio: ref.watch(dioClientProvider).dio);
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl(
    remoteDataSource: ref.watch(supportRemoteDataSourceProvider),
  );
});


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


final supportViewModelProvider = StateNotifierProvider<SupportViewModel, SupportState>((ref) {
  return SupportViewModel(
    submitSupportTicketUseCase: ref.watch(submitSupportTicketUseCaseProvider),
    getSupportMessagesUseCase: ref.watch(getSupportMessagesUseCaseProvider),
  );
});
