import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'data/data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nsunwuftxebwktfyzjtm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zdW53dWZ0eGVid2t0Znl6anRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzMTc2MDAsImV4cCI6MjA5NDg5MzYwMH0.BupOYnRrj0avYgyg73NdiPPOySzJDczfoNJFzFnv2Qg',
  );

  await DataManager.loadAll();

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motrix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardPage(),
    );
  }
}