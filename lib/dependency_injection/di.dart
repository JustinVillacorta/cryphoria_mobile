import 'dart:io';

import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/AuthRepositoryImpl.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_service.dart';
import 'package:cryphoria_mobile/features/data/services/private_key_storage.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';
import 'package:cryphoria_mobile/features/data/services/device_approval_cache.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';
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
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/Register/ViewModel/register_view_model.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_ViewModel/home_Viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/SessionManagement/session_management_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/SessionManagement/session_management_controller.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryphoria_mobile/features/data/data_sources/fake_transactions_data.dart';


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
      return 'http://10.0.2.2:8000';
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
        ));


  // Wallet ViewModel
  sl.registerFactory<WalletViewModel>(
        () => WalletViewModel(
      walletService: sl<WalletService>(),
      transactionsDataSource: sl<FakeTransactionsDataSource>(),
    ),
  );
}





