import 'package:flutter/material.dart';
import '../../data/data_manager.dart';
import '../../data/rule_data.dart';
import '../../models/kerusakan.dart';
import '../../models/rule.dart';

class DetailKerusakanPage extends StatelessWidget {
  final Kerusakan data;

  const DetailKerusakanPage({
    super.key,
    required this.data,
  });

  Color getKategoriColor(String kategori) {
    switch (kategori) {
      case "Mesin":
        return const Color(0xFFEF4444);

      case "Kelistrikan":
        return const Color(0xFFF59E0B);

      case "Transmisi":
        return const Color(0xFF3B82F6);

      case "Penggerak":
        return const Color(0xFF14B8A6);

      case "Rem":
        return const Color(0xFFF97316);

      default:
        return Colors.grey;
    }
  }

  IconData getKategoriIcon(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Icons.build_circle;

      case "Kelistrikan":
        return Icons.bolt;

      case "Transmisi":
        return Icons.settings;

      case "Penggerak":
        return Icons.cyclone;

      case "Rem":
        return Icons.warning_amber_rounded;

      default:
        return Icons.device_unknown;
    }
  }

  Rule? getRuleByKerusakanId(String kerusakanId) {
    try {
      return dataRule.firstWhere(
        (rule) => rule.kerusakanId == kerusakanId,
      );
    } catch (_) {
      return null;
    }
  }

  String getNamaGejala(String gejalaId) {
    try {
      final gejala = DataManager.gejala.firstWhere(
        (g) => g.id == gejalaId,
      );

      return gejala.nama;
    } catch (_) {
      return "Gejala tidak ditemukan";
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getKategoriColor(data.kategori);
    final icon = getKategoriIcon(data.kategori);

    final Rule? rule =
        getRuleByKerusakanId(data.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: CustomScrollView(
        slivers: [
          /// APPBAR
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: color,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.18),
                            borderRadius:
                                BorderRadius.circular(26),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          data.nama,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.18),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Text(
                            data.kategori,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  buildCard(
                    title: "Deskripsi",
                    icon: Icons.description_outlined,
                    color: color,
                    child: Column(
                      children: data.deskripsi
                          .map(
                            (item) => buildBullet(item),
                          )
                          .toList(),
                    ),
                  ),

                  buildGejalaCard(
                    rule: rule,
                    color: color,
                  ),

                  buildCard(
                    title: "Saran Perbaikan",
                    icon: Icons.build_outlined,
                    color: color,
                    child: Column(
                      children: data.solusi
                          .split('\n')
                          .where(
                            (e) =>
                                e.trim().isNotEmpty,
                          )
                          .toList()
                          .asMap()
                          .entries
                          .map(
                        (entry) {
                          final i = entry.key + 1;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment:
                                      Alignment.center,
                                  decoration:
                                      BoxDecoration(
                                    color: color
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "$i",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style:
                                        const TextStyle(
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  Widget buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text("• "),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGejalaCard({
    required Rule? rule,
    required Color color,
  }) {
    final gejalaRules =
        rule?.gejalaRules ?? [];

    return buildCard(
      title: "Gejala Terkait",
      icon: Icons.medical_information_outlined,
      color: color,

      child: gejalaRules.isEmpty
          ? Text(
              "Belum ada gejala terkait.",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            )
          : Column(
              children: gejalaRules.map((g) {
                final namaGejala =
                    getNamaGejala(g.gejalaId);

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 12),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color:
                        color.withOpacity(0.06),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 20,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          namaGejala,
                          style: const TextStyle(
                            height: 1.4,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              color.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        child: Text(
                          "CF ${g.bobotPakar.toStringAsFixed(1)}",
                          style: TextStyle(
                            color: color,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}