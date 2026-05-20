import 'package:flutter/material.dart';
import '../admin/kelola_gejala_page.dart';
import '../admin/kelola_kerusakan_page.dart';
import '../admin/kelola_rule_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  /// 🔐 LOGOUT
  void handleLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Yakin mau keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  /// 📊 STAT CARD
  Widget buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  /// 📂 MENU CARD
  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  /// 🔥 BUILD WAJIB ADA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Admin Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: handleLogout,
                      icon: Icon(Icons.logout, color: Colors.white),
                    )
                  ],
                ),

                SizedBox(height: 20),

                /// STAT
                Row(
                  children: [
                    buildStatCard("Gejala", "15", Colors.blue),
                    buildStatCard("Kerusakan", "12", Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    buildStatCard("Rule", "48", Colors.purple),
                    buildStatCard("Diagnosa", "234", Colors.green),
                  ],
                ),

                SizedBox(height: 20),

                /// MENU
                Expanded(
                  child: ListView(
                    children: [
                      buildMenuCard(
                        icon: Icons.list,
                        title: "Kelola Gejala",
                        desc: "Tambah & edit data gejala",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KelolaGejalaPage(),
                            ),
                          );
                        },
                      ),
                      buildMenuCard(
                        icon: Icons.warning,
                        title: "Kelola Kerusakan",
                        desc: "Kelola data kerusakan",
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KelolaKerusakanPage(),
                            ),
                          );
                        },
                      ),
                      buildMenuCard(
                        icon: Icons.account_tree,
                        title: "Kelola Rule",
                        desc: "Relasi gejala & kerusakan",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KelolaRulePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}