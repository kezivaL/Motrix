import 'package:flutter/material.dart';

import '../../data/data_manager.dart';
import '../admin/kelola_gejala_page.dart';
import '../admin/kelola_kerusakan_page.dart';
import '../admin/kelola_rule_page.dart';
import '../../services/storage_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshData();
  }
  int totalDiagnosaAllUser = 0;
  Future<void> refreshData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await DataManager.refreshFromSupabase(includeRiwayat: true);
      totalDiagnosaAllUser = await StorageService.countAllRiwayatDiagnosa();
    } catch (_) {
      await DataManager.loadAll();
      totalDiagnosaAllUser = await StorageService.countAllRiwayatDiagnosa();
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    await refreshData();
  }

  void handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Yakin mau keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  int get totalRule {
    int total = 0;
    for (final rule in DataManager.rules) {
      total += rule.gejalaRules.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalGejala = DataManager.gejala.length;
    final totalKerusakan = DataManager.kerusakan.length;
    final totalDiagnosa = totalDiagnosaAllUser;

    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF08111F),
              Color(0xFF0F172A),
              Color(0xFF172536),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshData,
            color: const Color(0xFF38BDF8),
            backgroundColor: const Color(0xFF0F172A),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
              children: [
                buildHeader(),
                const SizedBox(height: 24),
                if (isLoading) ...[
                  buildSyncInfo(),
                  const SizedBox(height: 18),
                ],
                Row(
                  children: [
                    buildStatCard(
                      title: "Gejala",
                      value: totalGejala.toString(),
                      color1: const Color(0xFF38BDF8),
                      color2: const Color(0xFF2563EB),
                      icon: Icons.list_alt_rounded,
                    ),
                    const SizedBox(width: 14),
                    buildStatCard(
                      title: "Kerusakan",
                      value: totalKerusakan.toString(),
                      color1: const Color(0xFFF59E0B),
                      color2: const Color(0xFFD97706),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    buildStatCard(
                      title: "Rule",
                      value: totalRule.toString(),
                      color1: const Color(0xFFC026D3),
                      color2: const Color(0xFF7E22CE),
                      icon: Icons.account_tree_rounded,
                    ),
                    const SizedBox(width: 14),
                    buildStatCard(
                      title: "Diagnosa",
                      value: totalDiagnosa.toString(),
                      color1: const Color(0xFF22C55E),
                      color2: const Color(0xFF15803D),
                      icon: Icons.analytics_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                buildMenuCard(
                  icon: Icons.list_alt_rounded,
                  title: "Kelola Gejala",
                  desc: "Tambah & edit data gejala",
                  color: const Color(0xFF38BDF8),
                  onTap: () => openPage(const KelolaGejalaPage()),
                ),
                buildMenuCard(
                  icon: Icons.warning_amber_rounded,
                  title: "Kelola Kerusakan",
                  desc: "Kelola data kerusakan",
                  color: const Color(0xFFF59E0B),
                  onTap: () => openPage(const KelolaKerusakanPage()),
                ),
                buildMenuCard(
                  icon: Icons.account_tree_rounded,
                  title: "Kelola Rule",
                  desc: "Relasi gejala & kerusakan",
                  color: const Color(0xFFC026D3),
                  onTap: () => openPage(const KelolaRulePage()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Admin Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: IconButton(
            tooltip: "Refresh",
            onPressed: isLoading ? null : refreshData,
            icon: Icon(
              Icons.refresh_rounded,
              color: isLoading ? Colors.white38 : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: IconButton(
            tooltip: "Logout",
            onPressed: handleLogout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSyncInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF172554),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF38BDF8),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Menyinkronkan data dari Supabase...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -4,
              bottom: -4,
              child: Icon(
                icon,
                size: 54,
                color: Colors.white.withOpacity(0.13),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF172536),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}