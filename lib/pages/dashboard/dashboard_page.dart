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
  static const primaryBlue = Color(0xFF2563EB);
  static const bgColor = Color(0xFFF4F7FE);
  static const textColor = Color(0xFF1E293B);

  final SupabaseClient supabase = Supabase.instance.client;

  final Map<String, RealtimeChannel> _channels = {};
  Timer? _debounceTimer;
  Timer? _reconnectTimer;

  bool isSyncing = false;
  bool isRealtimeConnected = false;
  DateTime? lastSyncAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupRealtimeSync();
    Future.microtask(() => _refreshMasterData(showLoading: false));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _reconnectTimer?.cancel();
    _removeRealtimeChannels();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _reconnectRealtimeSafe();
    _refreshMasterData(showLoading: false);
  }

  Future<void> _refreshMasterData({bool showLoading = true}) async {
    if (isSyncing) return;

    if (mounted && showLoading) {
      setState(() => isSyncing = true);
    }

    try {
      await DataManager.refreshFromSupabase();
      if (!mounted) return;
      setState(() => lastSyncAt = DateTime.now());
    } catch (_) {
      await DataManager.loadMasterData();
    } finally {
      if (mounted) setState(() => isSyncing = false);
    }
  }

  void _setupRealtimeSync() {
    _removeRealtimeChannels();

    for (final table in ['gejala', 'kerusakan', 'rules']) {
      _channels[table] = supabase
          .channel('motrix_${table}_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (_) => _scheduleRealtimeRefresh(),
          )
          .subscribe();
    }

    if (mounted) setState(() => isRealtimeConnected = true);
    _scheduleReconnectCheck();
  }

  void _removeRealtimeChannels() {
    for (final channel in _channels.values) {
      supabase.removeChannel(channel);
    }
    _channels.clear();
  }

  void _scheduleRealtimeRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 700),
      () => _refreshMasterData(showLoading: false),
    );
  }

  void _scheduleReconnectCheck() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;

      if (_channels.length < 3) {
        setState(() => isRealtimeConnected = false);
        _reconnectRealtimeSafe();
      }
    });
  }

  void _reconnectRealtimeSafe() {
    if (!mounted) return;

    try {
      _setupRealtimeSync();
    } catch (_) {
      if (mounted) setState(() => isRealtimeConnected = false);
    }
  }

  String get _syncText {
    if (isSyncing) return 'Menyinkronkan data terbaru...';

    if (lastSyncAt == null) {
      return isRealtimeConnected ? 'Realtime aktif' : 'Mode offline aman';
    }

    final time =
        '${lastSyncAt!.hour.toString().padLeft(2, '0')}:${lastSyncAt!.minute.toString().padLeft(2, '0')}';

    return isRealtimeConnected
        ? 'Realtime aktif • Sinkron terakhir $time'
        : 'Mode aman • Sinkron terakhir $time';
  }

  void _goTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
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
          onPressed: () => _goTo(const LoginPage()),
          child: const Icon(Icons.settings),
        ),
        body: Column(
          children: [
            _Header(topPadding: MediaQuery.of(context).padding.top),
            _RealtimeBar(
              isSyncing: isSyncing,
              isRealtimeConnected: isRealtimeConnected,
              syncText: _syncText,
              onRefresh: () => _refreshMasterData(showLoading: true),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshMasterData(showLoading: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _DiagnosaCard(onTap: () => _goTo(const DiagnosePage())),
                      const SizedBox(height: 18),
                      _MenuCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Daftar Kerusakan',
                        subtitle: 'Lihat daftar kerusakan motor listrik',
                        color: Colors.orange,
                        onTap: () => _goTo(const KerusakanPage()),
                      ),
                      const SizedBox(height: 14),
                      _MenuCard(
                        icon: Icons.history_rounded,
                        title: 'Riwayat Diagnosa',
                        subtitle: 'Lihat hasil diagnosa sebelumnya',
                        color: Colors.green,
                        onTap: () => _goTo(const RiwayatPage()),
                      ),
                      const SizedBox(height: 18),
                      const _InfoBox(),
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
}

class _Header extends StatelessWidget {
  final double topPadding;

  const _Header({required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, topPadding + 20, 22, 24),
      decoration: const BoxDecoration(
        color: _DashboardPageState.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                  'MOTRIX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Diagnosa Kerusakan Motor Listrik',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RealtimeBar extends StatelessWidget {
  final bool isSyncing;
  final bool isRealtimeConnected;
  final String syncText;
  final VoidCallback onRefresh;

  const _RealtimeBar({
    required this.isSyncing,
    required this.isRealtimeConnected,
    required this.syncText,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
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
              syncText,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isSyncing ? null : onRefresh,
            child: Icon(
              Icons.refresh_rounded,
              color: isSyncing ? Colors.grey : _DashboardPageState.primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosaCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DiagnosaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _DashboardPageState.primaryBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Mulai Diagnosa',
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
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: _DashboardPageState.textColor,
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
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Motrix membantu mendiagnosa kerusakan motor listrik secara cepat menggunakan metode Certainty Factor.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: Color(0xFF64748B),
      ),
    );
  }
}