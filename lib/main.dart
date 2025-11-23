import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/connection_screen.dart';
import 'services/robot_api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CuchauApp());
}

class CuchauApp extends StatelessWidget {
  const CuchauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RobotApiService(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'LineBot Pro - CUCHAU',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const ConnectionScreen(),
      ),
    );
  }
}

