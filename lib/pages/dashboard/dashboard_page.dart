import 'dart:async';

import 'package:flutter/material.dart';
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
  bool isFirstLoading = true;

  DateTime? lastSyncAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDashboardRealtime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    debounceTimer?.cancel();
    reconnectTimer?.cancel();

    if (gejalaChannel != null) {
      supabase.removeChannel(gejalaChannel!);
    }
    if (kerusakanChannel != null) {
      supabase.removeChannel(kerusakanChannel!);
    }
    if (rulesChannel != null) {
      supabase.removeChannel(rulesChannel!);
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reconnectRealtimeSafe();
      refreshMasterData(showLoading: false);
    }
  }

  Future<void> initDashboardRealtime() async {
    await refreshMasterData(showLoading: false);
    setupRealtimeSync();

    if (!mounted) return;
    setState(() {
      isFirstLoading = false;
    });
  }

  Future<void> refreshMasterData({bool showLoading = true}) async {
    if (isSyncing) return;

    if (mounted) {
      setState(() {
        isSyncing = showLoading;
      });
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
      setState(() {
        isSyncing = false;
        isFirstLoading = false;
      });
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
      setState(() {
        isRealtimeConnected = true;
      });
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
    reconnectTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) return;

      final bool channelMissing =
          gejalaChannel == null || kerusakanChannel == null || rulesChannel == null;

      if (channelMissing) {
        setState(() {
          isRealtimeConnected = false;
        });
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
      setState(() {
        isRealtimeConnected = false;
      });
    }
  }

  String getSyncText() {
    if (isSyncing) return "Menyinkronkan data terbaru...";

    if (lastSyncAt == null) {
      return isRealtimeConnected
          ? "Realtime aktif"
          : "Realtime mencoba tersambung ulang";
    }

    final String jam = lastSyncAt!.hour.toString().padLeft(2, '0');
    final String menit = lastSyncAt!.minute.toString().padLeft(2, '0');

    return isRealtimeConnected
        ? "Realtime aktif • Sinkron terakhir $jam:$menit"
        : "Mode aman • Sinkron terakhir $jam:$menit";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SafeArea(
        child: isFirstLoading
            ? buildModernLoading()
            : Column(
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

  Widget buildModernLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Memuat Motrix",
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Menyiapkan sinkronisasi realtime...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryBlue,
                  ),
                )
              : Icon(
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
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.refresh_rounded,
                color: primaryBlue,
                size: 20,
              ),
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
          gradient: const LinearGradient(
            colors: [primaryBlue, primaryPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Diagnosa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Mulai diagnosa berdasarkan gejala",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 30,
            ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_rounded, color: Color(0xFF0284C7)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Aplikasi diagnosa motor listrik membantu mendeteksi kerusakan dengan cepat dan terstruktur.",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}