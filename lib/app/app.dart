import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/login_page.dart';
import 'theme/app_theme.dart';

class MaliTransApp extends StatelessWidget {
  const MaliTransApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaliTrans Chauffeur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
