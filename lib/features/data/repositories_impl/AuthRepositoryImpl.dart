import 'package:cryphoria_mobile/features/data/data_sources/AuthRemoteDataSource.dart';
import 'package:cryphoria_mobile/features/domain/repositories/auth_repository.dart';

import '../../domain/entities/auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthUser> login(String username, String password) async {
    final token = await remoteDataSource.login(username, password);
    return AuthUser(token: token);
  }

  @override
  Future<AuthUser> register(String username, String password, String email) async {
    final token = await remoteDataSource.register(username, password, email);
    return AuthUser(token: token);
  }
}