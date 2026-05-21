import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/data_manager.dart';
import '../auth/login_page.dart';
import '../diagnose/diagnose_page.dart';
import '../kerusakan/kerusakan_page.dart';
import '../riwayat/riwayat_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryPurple = Color(0xFF6D5DF6);
  static const Color bgColor = Color(0xFFF4F7FE);
  static const Color textColor = Color(0xFF1E293B);

  final SupabaseClient supabase = Supabase.instance.client;

  RealtimeChannel? gejalaChannel;
  RealtimeChannel? kerusakanChannel;
  RealtimeChannel? rulesChannel;

  Timer? debounceTimer;
  Timer? reconnectTimer;

  bool isSyncing = false;
  bool isRealtimeConnected = false;

  DateTime? lastSyncAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    setupRealtimeSync();

    Future.microtask(() {
      refreshMasterData(showLoading: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debounceTimer?.cancel();
    reconnectTimer?.cancel();
    removeRealtimeChannels();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reconnectRealtimeSafe();
      refreshMasterData(showLoading: false);
    }
  }

  Future<void> refreshMasterData({bool showLoading = true}) async {
    if (isSyncing) return;

    if (mounted && showLoading) {
      setState(() => isSyncing = true);
    }

    try {
      await DataManager.refreshFromSupabase();
      if (!mounted) return;
      setState(() {
        lastSyncAt = DateTime.now();
      });
    } catch (_) {
      try {
        await DataManager.loadMasterData();
      } catch (_) {}
    } finally {
      if (!mounted) return;
      setState(() => isSyncing = false);
    }
  }

  void setupRealtimeSync() {
    removeRealtimeChannels();

    gejalaChannel = supabase
        .channel('motrix_gejala_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'gejala',
          callback: (_) => scheduleRealtimeRefresh(),
        )
        .subscribe();

    kerusakanChannel = supabase
        .channel('motrix_kerusakan_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kerusakan',
          callback: (_) => scheduleRealtimeRefresh(),
        )
        .subscribe();

    rulesChannel = supabase
        .channel('motrix_rules_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rules',
          callback: (_) => scheduleRealtimeRefresh(),
        )
        .subscribe();

    if (mounted) {
      setState(() => isRealtimeConnected = true);
    }

    scheduleReconnectCheck();
  }

  void removeRealtimeChannels() {
    if (gejalaChannel != null) {
      supabase.removeChannel(gejalaChannel!);
      gejalaChannel = null;
    }
    if (kerusakanChannel != null) {
      supabase.removeChannel(kerusakanChannel!);
      kerusakanChannel = null;
    }
    if (rulesChannel != null) {
      supabase.removeChannel(rulesChannel!);
      rulesChannel = null;
    }
  }

  void scheduleRealtimeRefresh() {
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 700), () {
      refreshMasterData(showLoading: false);
    });
  }

  void scheduleReconnectCheck() {
    reconnectTimer?.cancel();
    reconnectTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;

      if (gejalaChannel == null ||
          kerusakanChannel == null ||
          rulesChannel == null) {
        setState(() => isRealtimeConnected = false);
        reconnectRealtimeSafe();
      }
    });
  }

  void reconnectRealtimeSafe() {
    if (!mounted) return;

    try {
      setupRealtimeSync();
    } catch (_) {
      if (!mounted) return;
      setState(() => isRealtimeConnected = false);
    }
  }

  String getSyncText() {
    if (isSyncing) return "Menyinkronkan data terbaru...";

    if (lastSyncAt == null) {
      return isRealtimeConnected ? "Realtime aktif" : "Mode offline aman";
    }

    final jam = lastSyncAt!.hour.toString().padLeft(2, '0');
    final menit = lastSyncAt!.minute.toString().padLeft(2, '0');

    return isRealtimeConnected
        ? "Realtime aktif • Sinkron terakhir $jam:$menit"
        : "Mode aman • Sinkron terakhir $jam:$menit";
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFE9D5FF),
          foregroundColor: const Color(0xFF5B21B6),
          elevation: 8,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          },
          child: const Icon(Icons.settings),
        ),
        body: Column(
          children: [
            buildHeader(),
            buildRealtimeBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => refreshMasterData(showLoading: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildDiagnosaCard(context),
                      const SizedBox(height: 18),
                      buildMenuCard(
                        context: context,
                        icon: Icons.warning_amber_rounded,
                        title: "Daftar Kerusakan",
                        subtitle: "Lihat daftar kerusakan motor listrik",
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KerusakanPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      buildMenuCard(
                        context: context,
                        icon: Icons.history_rounded,
                        title: "Riwayat Diagnosa",
                        subtitle: "Lihat hasil diagnosa sebelumnya",
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RiwayatPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      buildInfoBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.of(context).padding.top + 20,
        22,
        24,
      ),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.electric_bike_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MOTRIX",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Diagnosa Kerusakan Motor Listrik",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRealtimeBar() {
    final Color statusColor =
        isRealtimeConnected ? const Color(0xFF16A34A) : const Color(0xFFF97316);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            isRealtimeConnected
                ? Icons.cloud_done_rounded
                : Icons.cloud_sync_rounded,
            color: statusColor,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              getSyncText(),
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isSyncing
                ? null
                : () => refreshMasterData(showLoading: true),
            child: Icon(
              Icons.refresh_rounded,
              color: isSyncing ? Colors.grey : primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDiagnosaCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiagnosePage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Mulai Diagnosa",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }

  Widget buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget buildInfoBox() {
    return const Text(
      "Motrix membantu mendiagnosa kerusakan motor listrik secara cepat menggunakan metode Certainty Factor.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: Color(0xFF64748B),
      ),
    );
  }
}