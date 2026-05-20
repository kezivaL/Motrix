import 'package:flutter/material.dart';
import '../../widgets/diagnose_button.dart';
import '../diagnose/diagnose_page.dart';
import '../kerusakan/kerusakan_page.dart';
import '../riwayat/riwayat_page.dart';
import '../auth/login_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
          floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoginPage(),
            ),
          );
        },
        child: Icon(Icons.settings),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FULL WIDTH
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF4F46E5),
                  ],
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.electric_bike,
                      color: Colors.white, size: 32),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("MOTRIX",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("Diagnosa Kerusakan",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  )
                ],
              ),
            ),

            // CONTENT FULL FLEX
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DiagnoseButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DiagnosePage()),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      menuCard(
                      icon: Icons.warning,
                      title: "Daftar Kerusakan",
                      subtitle: "Lihat daftar kerusakan",
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
                      const SizedBox(height: 12),

                      menuCard(
                      icon: Icons.history,
                      title: "Riwayat",
                      subtitle: "Lihat riwayat diagnosa",
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

                      const SizedBox(height: 12),

                      infoBox(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

Widget menuCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap, 
}) {
  return GestureDetector(
    onTap: onTap, // 🔥 INI JUGA
    child: Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}
  Widget infoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Aplikasi diagnosa motor listrik membantu mendeteksi kerusakan dengan cepat.",
              style: TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}