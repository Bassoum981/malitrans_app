import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/login_driver.dart';
import '../features/auth/presentation/controllers/login_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'theme/app_theme.dart';

class MaliTransApp extends StatelessWidget {
  MaliTransApp({super.key})
    : _loginController = LoginController(
        LoginDriver(
          AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSource(ApiClient()),
            tokenStorage: TokenStorage(),
          ),
        ),
      );

  final LoginController _loginController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaliTrans Chauffeur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: LoginPage(controller: _loginController),
    );
  }
}
