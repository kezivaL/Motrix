import 'package:flutter/material.dart';

import '../../data/data_manager.dart';
import '../../models/kerusakan.dart';
import 'detail_kerusakan_page.dart';

class KerusakanPage extends StatefulWidget {
  const KerusakanPage({super.key});

  @override
  State<KerusakanPage> createState() => _KerusakanPageState();
}

class _KerusakanPageState extends State<KerusakanPage> {
  String selectedKategori = "Semua";

  final List<String> urutanKategori = [
    "Mesin",
    "Kelistrikan",
    "Transmisi",
    "Penggerak",
    "Rem",
  ];

  int kategoriIndex(String kategori) {
    final index = urutanKategori.indexOf(kategori);
    return index == -1 ? 999 : index;
  }

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
        return const Color(0xFF2563EB);
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

  void showKategoriPicker(List<String> kategoriList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.58,
minChildSize: 0.32,
maxChildSize: 0.80,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pilih Kategori",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...kategoriList.map((kategori) {
                      final isSelected = kategori == selectedKategori;
                      final color = getKategoriColor(kategori);

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedKategori = kategori;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.12)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? color.withOpacity(0.45)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  kategori,
                                  style: TextStyle(
                                    color: isSelected
                                        ? color
                                        : const Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: color,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getDeskripsiPreview(Kerusakan item) {
    final text = item.deskripsi
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(" ")
        .replaceAll("\n", " ")
        .replaceAll(RegExp(r'\s+'), " ");

    if (text.isEmpty) return "Belum ada deskripsi.";

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final List<Kerusakan> kerusakanList =
        List<Kerusakan>.from(DataManager.kerusakan);

    kerusakanList.sort((a, b) {
      final kategoriCompare =
          kategoriIndex(a.kategori).compareTo(kategoriIndex(b.kategori));

      if (kategoriCompare != 0) return kategoriCompare;

      return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
    });

    final kategoriList = <String>[
      "Semua",
      ...kerusakanList.map((e) => e.kategori).toSet().toList()
        ..sort((a, b) => kategoriIndex(a).compareTo(kategoriIndex(b))),
    ];

    final filteredList = selectedKategori == "Semua"
        ? kerusakanList
        : kerusakanList
            .where((item) => item.kategori == selectedKategori)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 18,
              20,
              26,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 3, right: 14, bottom: 8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daftar Kerusakan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${filteredList.length} kerusakan tersedia",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showKategoriPicker(kategoriList),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.35),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      selectedKategori,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF0F172A),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text("Belum ada data kerusakan"),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final color = getKategoriColor(item.kategori);
                      final icon = getKategoriIcon(item.kategori);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailKerusakanPage(data: item),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.kategori,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      getDeskripsiPreview(item),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}