import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'pages/dashboard/dashboard_page.dart';

import 'data/data_manager.dart';
import 'data/kerusakan_data.dart';
import 'data/symptom_data.dart';
import 'data/rule_data.dart';

import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 LOAD DARI STORAGE
  DataManager.gejala = await StorageService.loadGejala();
  DataManager.kerusakan = await StorageService.loadKerusakan();
  DataManager.rules = await StorageService.loadRule();

  // 🔥 FALLBACK
  if (DataManager.gejala.isEmpty) {
    DataManager.gejala = dataSymptom;
  }

  if (DataManager.kerusakan.isEmpty) {
    DataManager.kerusakan = dataKerusakan;
  }

  if (DataManager.rules.isEmpty) {
    DataManager.rules = dataRule;
  }

  runApp(const MyApp());
}

// 🔥 HARUS DI LUAR main()
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnosa Motor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardPage(),
    );
  }
}