import 'dart:io';

import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/audit_remote_data_source.dart';
import 'package:cryphoria_mobile/features/data/data_sources/employee_remote_data_source.dart';
import 'package:cryphoria_mobile/features/data/data_sources/eth_payment_remote_data_source.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/AuthRepositoryImpl.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/audit_repository_impl.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/employee_repository_impl.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/data/services/private_key_storage.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';
import 'package:cryphoria_mobile/features/data/services/device_approval_cache.dart';
import 'package:cryphoria_mobile/features/data/services/currency_conversion_service.dart';
import 'package:cryphoria_mobile/features/data/services/eth_payment_service.dart';
import 'package:cryphoria_mobile/features/data/notifiers/audit_notifier.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';
import 'package:cryphoria_mobile/features/domain/repositories/audit_repository.dart';
import 'package:cryphoria_mobile/features/domain/repositories/employee_repository.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_check_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_force_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Register/register_use_case.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/get_sessions_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/get_transferable_sessions_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/transfer_main_device_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/approve_session_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/revoke_session_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/revoke_other_sessions_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/confirm_password_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/validate_session_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Audit/submit_audit_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Audit/get_audit_report_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Audit/get_audit_status_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Audit/upload_contract_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Employee_management/get_all_employees_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Employee_management/get_manager_team_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Employee_management/add_employee_to_team_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Employee_management/create_payslip_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Employee_management/get_payslips_usecase.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/Register/ViewModel/register_view_model.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/ViewModel/logout_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/SessionManagement/session_management_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/SessionManagement/session_management_controller.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_ViewModel/home_Viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Employee_Management(manager_screens)/employee_viewmodel/employee_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/ViewModels/audit_contract_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/ViewModels/audit_analysis_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/ViewModels/audit_results_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/ViewModels/audit_main_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';
import 'package:cryphoria_mobile/features/data/data_sources/eth_transaction_data_source.dart';


import '../core/network/dio_client.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  // Services
  sl.registerLazySingleton<DeviceInfoService>(
      () => DeviceInfoServiceImpl());
  sl.registerLazySingleton<DeviceApprovalCache>(
      () => DeviceApprovalCache(storage: sl()));
  sl.registerLazySingleton<CurrencyConversionService>(
      () => CurrencyConversionService(dio: sl<DioClient>().dio));
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(secureStorage: sl()));
  sl.registerLazySingleton(() => DioClient(
    localDataSource: sl(), 
    deviceInfoService: sl(),
    dio: Dio()
  ));

  // Wallet services
  sl.registerLazySingleton<PrivateKeyStorage>(
      () => PrivateKeyStorage(storage: sl()));

  String _baseUrl() {
    if (Platform.isAndroid) {
      return 'http://192.168.5.59:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      baseUrl: _baseUrl(),
    ),
  );
  
  // ETH Payment Services - registered first so FakeTransactionsDataSource can use it
  sl.registerLazySingleton<EthPaymentRemoteDataSource>(
    () => EthPaymentRemoteDataSourceImpl(
      dio: sl<DioClient>().dio..options.baseUrl = _baseUrl(),
    ),
  );
  sl.registerLazySingleton<EthPaymentService>(
    () => EthPaymentService(remoteDataSource: sl<EthPaymentRemoteDataSource>()),
  );
  
  // Register the new ETH transaction data source instead of fake one
  sl.registerLazySingleton<EthTransactionDataSource>(
        () => EthTransactionDataSource(),
  );

  // Keep FakeTransactionsDataSource for backward compatibility (if needed)
  sl.registerLazySingleton<FakeTransactionsDataSource>(
        () => FakeTransactionsDataSource(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<AuthLocalDataSource>()),
  );

  // Use cases - aligned with backend API
  sl.registerLazySingleton(() => Login(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Register(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutCheck(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutForce(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetSessions(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetTransferableSessions(sl<AuthRepository>()));
  sl.registerLazySingleton(() => TransferMainDevice(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ApproveSession(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RevokeSession(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RevokeOtherSessions(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ConfirmPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ValidateSession(sl<AuthRepository>()));

  // ViewModels
  sl.registerFactory(() => LoginViewModel(
    loginUseCase: sl(),
    deviceInfoService: sl(),
    deviceApprovalCache: sl(),
  ));
  sl.registerFactory(() => RegisterViewModel(
    registerUseCase: sl(),
    deviceInfoService: sl(),
  ));
  sl.registerFactory(() => LogoutViewModel(
    logoutUseCase: sl(),
    logoutForceUseCase: sl(),
    logoutCheckUseCase: sl(),
    authLocalDataSource: sl(),
  ));
  sl.registerFactory(() => SessionManagementViewModel());
  sl.registerFactory(() => SessionManagementController(
    getSessions: sl(),
    approveSession: sl(),
    revokeSession: sl(),
    revokeOtherSessions: sl(),
    viewModel: sl(),
  ));

  // Wallet feature
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSource(
      baseUrl: '${_baseUrl()}/api/wallets/',
      dio: sl<DioClient>().dio,
    ),
  );

    // Wallet service depends on remote data source and storage
    sl.registerLazySingleton<WalletService>(() => WalletService(
          remoteDataSource: sl(),
          storage: sl(),
          currencyService: sl(),
        ));


  // Wallet ViewModel
  sl.registerFactory<WalletViewModel>(
        () => WalletViewModel(
      walletService: sl<WalletService>(),
      ethTransactionDataSource: sl<EthTransactionDataSource>(),
    ),
  );

  // Employee ViewModel (Legacy - compatible with existing UI)
  sl.registerFactory<EmployeeViewModel>(() => EmployeeViewModel(
    getAllEmployeesUseCase: sl<GetAllEmployeesUseCase>(),
    getManagerTeamUseCase: sl<GetManagerTeamUseCase>(),
    addEmployeeToTeamUseCase: sl<AddEmployeeToTeamUseCase>(),
  ));

  // Employee Management feature (Backend-integrated)
  // Data Sources
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(
      dio: sl<DioClient>().dio..options.baseUrl = _baseUrl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllEmployeesUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetManagerTeamUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddEmployeeToTeamUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreatePayslipUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetPayslipsUseCase(repository: sl()));

  // Enhanced Employee ViewModel (Backend-integrated) - uncomment when UI is updated
  // sl.registerFactory(() => EmployeeViewModelEnhanced(
  //   getAllEmployeesUseCase: sl(),
  //   registerEmployeeUseCase: sl(),
  //   createPayrollEntryUseCase: sl(),
  //   createPayslipUseCase: sl(),
  //   getPayslipsUseCase: sl(),
  // ));

  // Audit feature
  // Data Sources
  sl.registerLazySingleton<AuditRemoteDataSource>(
    () => AuditRemoteDataSourceImpl(
      dio: sl<DioClient>().dio..options.baseUrl = _baseUrl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuditRepository>(
    () => AuditRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SubmitAuditUseCase(sl<AuditRepository>()));
  sl.registerLazySingleton(() => GetAuditReportUseCase(sl<AuditRepository>()));
  sl.registerLazySingleton(() => GetAuditStatusUseCase(sl<AuditRepository>()));
  sl.registerLazySingleton(() => UploadContractUseCase(sl<AuditRepository>()));

  // Audit ViewModels (proper MVVM)
  sl.registerFactory(() => AuditContractViewModel(
    uploadContractUseCase: sl(),
  ));
  
  sl.registerFactory(() => AuditAnalysisViewModel(
    submitAuditUseCase: sl(),
    getAuditStatusUseCase: sl(),
  ));
  
  sl.registerFactory(() => AuditResultsViewModel(
    getAuditReportUseCase: sl(),
  ));
  
  // Main ViewModel as lazy singleton for shared state across audit flow
  sl.registerLazySingleton(() => AuditMainViewModel());

  // Legacy Notifier (to be deprecated)
  sl.registerFactory(() => AuditNotifier(
    submitAuditUseCase: sl(),
    getAuditReportUseCase: sl(),
    getAuditStatusUseCase: sl(),
    uploadContractUseCase: sl(),
  ));
}





