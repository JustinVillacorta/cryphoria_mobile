import 'dart:io';

import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/data/data_sources/walletRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/AuthRepositoryImpl.dart';
import 'package:cryphoria_mobile/features/data/repositories_impl/walletRepositoryimpl.dart';
import 'package:cryphoria_mobile/features/data/services/wallet_connector_service.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';
import 'package:cryphoria_mobile/features/domain/repositories/wallet_repository.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Login/login_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Register/register_use_case.dart';
import 'package:cryphoria_mobile/features/domain/usecases/wallet/wallet_usecase.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/ViewModel/login_ViewModel.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/Register/ViewModel/register_view_model.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_ViewModel/home_Viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton(() => DioClient(localDataSource: sl(), dio: Dio()));

  // Wallet connector service
  sl.registerLazySingleton(
    () => WalletConnectorService(projectId: 'YOUR_PROJECT_ID'),
  );

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

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<AuthLocalDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => Login(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Register(sl<AuthRepository>()));

  // ViewModels
  sl.registerFactory(() => LoginViewModel(loginUseCase: sl()));
  sl.registerFactory(() => RegisterViewModel(registerUseCase: sl()));

  // Wallet feature
 final token = await sl<AuthLocalDataSource>().getToken() ?? "";

  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSource(
      baseUrl: '${_baseUrl()}/api/wallets/',
      token: token,
      dio: sl<DioClient>().dio,
    ),
  );

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );

  // Wallet use-cases
  sl.registerLazySingleton(() => GetWalletsUseCase(sl()));
  sl.registerLazySingleton(() => ConnectWalletUseCase(sl()));  // <-- add this

  // Wallet ViewModel now takes two use-cases
  sl.registerLazySingleton(
    () => WalletViewModel(
      getWalletsUseCase: sl(),
      connectWalletUseCase: sl(), // <-- updated
    ),
  );
}





