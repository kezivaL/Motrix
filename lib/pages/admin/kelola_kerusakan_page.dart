import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';
import '../../../models/kerusakan.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class KelolaKerusakanPage extends StatefulWidget {
  const KelolaKerusakanPage({super.key});

  @override
  State<KelolaKerusakanPage> createState() => _KelolaKerusakanPageState();
}

class _KelolaKerusakanPageState extends State<KelolaKerusakanPage> {
  String selectedFilterKategori = "Semua";

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

  Color kategoriColor(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Colors.redAccent;
      case "Kelistrikan":
        return Colors.amber;
      case "Transmisi":
        return Colors.lightBlueAccent;
      case "Penggerak":
        return Colors.tealAccent;
      case "Rem":
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  IconData kategoriIcon(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Icons.build;
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

  String kategoriDesc(String kategori) {
    switch (kategori) {
      case "Mesin":
        return "Masalah pada komponen mesin";
      case "Kelistrikan":
        return "Masalah pada sistem kelistrikan";
      case "Transmisi":
        return "Masalah pada sistem transmisi";
      case "Penggerak":
        return "Masalah pada sistem penggerak";
      case "Rem":
        return "Masalah pada sistem rem";
      default:
        return "Kategori lainnya";
    }
  }

  List<String> getKategoriFilterList() {
    final setKategori = DataManager.kerusakan.map((e) => e.kategori).toSet();

    final list = setKategori.toList()
      ..sort((a, b) => kategoriIndex(a).compareTo(kategoriIndex(b)));

    return ["Semua", ...list];
  }

  List<Kerusakan> getSortedFilteredKerusakan() {
    final list = List<Kerusakan>.from(DataManager.kerusakan);

    list.sort((a, b) {
      final kategoriCompare =
          kategoriIndex(a.kategori).compareTo(kategoriIndex(b.kategori));

      if (kategoriCompare != 0) return kategoriCompare;

      return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
    });

    if (selectedFilterKategori == "Semua") return list;

    return list
        .where((item) => item.kategori == selectedFilterKategori)
        .toList();
  }

  int getOriginalIndex(Kerusakan item) {
    return DataManager.kerusakan.indexWhere((e) => e.id == item.id);
  }

  String generateKerusakanId() {
    final existingIds = DataManager.kerusakan.map((e) => e.id).toSet();
    int number = DataManager.kerusakan.length + 1;

    while (existingIds.contains("K$number")) {
      number++;
    }

    return "K$number";
  }

  Future<void> cetakPDFKerusakan() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final sorted = getSortedFilteredKerusakan();

    pw.ImageProvider? logo;
    try {
      logo = await imageFromAssetBundle('assets/logo.png');
    } catch (_) {
      logo = null;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Motrix System"),
            pw.Text("Halaman ${context.pageNumber}"),
          ],
        ),
        build: (context) {
          return [
            pw.Row(
              children: [
                logo != null
                    ? pw.Image(logo, width: 60, height: 60)
                    : pw.Container(width: 60, height: 60),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "SISTEM DIAGNOSA MOTOR LISTRIK",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text("Aplikasi Motrix"),
                      pw.Text("Laporan Data Kerusakan"),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Text("Tanggal: ${now.day}/${now.month}/${now.year}"),
            pw.Text(
              "Waktu: ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
            ),
            pw.Text("Dicetak oleh: Admin"),
            pw.Text("Filter Kategori: $selectedFilterKategori"),
            pw.Text("Total Data: ${sorted.length} kerusakan"),

            pw.SizedBox(height: 15),

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(105),
                2: const pw.FixedColumnWidth(75),
                3: const pw.FlexColumnWidth(),
                4: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    cellHeader("No"),
                    cellHeader("Kerusakan"),
                    cellHeader("Kategori"),
                    cellHeader("Deskripsi"),
                    cellHeader("Solusi"),
                  ],
                ),
                ...List.generate(sorted.length, (index) {
                  final item = sorted[index];

                  final deskripsiText = item.deskripsi
                      .where((e) => e.trim().isNotEmpty)
                      .map((e) => "- ${e.trim()}")
                      .join("\n");

                  final solusiText = item.solusi
                      .split('\n')
                      .where((e) => e.trim().isNotEmpty)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => "${entry.key + 1}. ${entry.value.trim()}")
                      .join("\n");

                  return pw.TableRow(
                    children: [
                      cell("${index + 1}"),
                      cell(item.nama),
                      cell(item.kategori),
                      cell(deskripsiText.isEmpty ? "-" : deskripsiText),
                      cell(solusiText.isEmpty ? "-" : solusiText),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 30),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Mengetahui,"),
                  pw.SizedBox(height: 4),
                  pw.Text("Admin"),
                  pw.SizedBox(height: 50),
                  pw.Text("(____________________)"),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  pw.Widget cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  void showForm({Kerusakan? item}) {
    final namaController = TextEditingController(text: item?.nama ?? "");

    final deskripsiController = TextEditingController(
      text: item?.deskripsi.join(". ") ?? "",
    );

    final solusiController = TextEditingController(
      text: item?.solusi ?? "",
    );

    String selectedKategori = item?.kategori ?? urutanKategori.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.92,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item == null
                                  ? "Tambah Kerusakan"
                                  : "Edit Kerusakan",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            kategoriColor(selectedKategori).withOpacity(0.18),
                        child: Icon(
                          kategoriIcon(selectedKategori),
                          color: kategoriColor(selectedKategori),
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: namaController,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration(
                          label: "Nama Kerusakan",
                          hint: "Masukkan nama kerusakan",
                          icon: Icons.build_circle_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: deskripsiController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration(
                          label: "Deskripsi",
                          hint:
                              "Jelaskan penyebab atau kondisi kerusakan. Pisahkan dengan titik.",
                          icon: Icons.description_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: solusiController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration(
                          label: "Solusi",
                          hint:
                              "Tuliskan solusi atau langkah perbaikan. Pisahkan dengan ENTER.",
                          icon: Icons.checklist_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedKategori,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        decoration: InputDecoration(
                          labelText: "Kategori",
                          filled: true,
                          fillColor: const Color(0xFF111827),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: urutanKategori.map((kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setModalState(() {
                            selectedKategori = val;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: urutanKategori.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final kategori = urutanKategori[index];
                          final aktif = selectedKategori == kategori;
                          final color = kategoriColor(kategori);

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setModalState(() {
                                selectedKategori = kategori;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: aktif
                                    ? color.withOpacity(0.20)
                                    : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: aktif ? color : Colors.white12,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: color.withOpacity(0.18),
                                    child: Icon(
                                      kategoriIcon(kategori),
                                      color: color,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          kategori,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          kategoriDesc(kategori),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (aktif)
                                    Icon(
                                      Icons.check_circle,
                                      color: color,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Batal"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final nama = namaController.text.trim();

                                final deskripsi = deskripsiController.text
                                    .split('.')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                                final solusi = solusiController.text.trim();

                                if (nama.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Nama kerusakan wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  if (item == null) {
                                    DataManager.kerusakan.add(
                                      Kerusakan(
                                        id: generateKerusakanId(),
                                        nama: nama,
                                        deskripsi: deskripsi,
                                        solusi: solusi,
                                        kategori: selectedKategori,
                                      ),
                                    );
                                  } else {
                                    final originalIndex =
                                        getOriginalIndex(item);

                                    if (originalIndex != -1) {
                                      DataManager.kerusakan[originalIndex] =
                                          Kerusakan(
                                        id: item.id,
                                        nama: nama,
                                        deskripsi: deskripsi,
                                        solusi: solusi,
                                        kategori: selectedKategori,
                                      );
                                    }
                                  }
                                });

                                Navigator.pop(context);
                              },
                              child: const Text("Simpan"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFF111827),
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
      ),
    );
  }

  void hapus(Kerusakan item) {
    final originalIndex = getOriginalIndex(item);

    if (originalIndex == -1) return;

    setState(() {
      DataManager.kerusakan.removeAt(originalIndex);
    });
  }

  Widget kategoriHeader(String kategori) {
    final color = kategoriColor(kategori);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Icon(kategoriIcon(kategori), color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            kategori,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategoriFilterList = getKategoriFilterList();
    final sorted = getSortedFilteredKerusakan();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2B2336),
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Kelola Kerusakan")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: DropdownButtonFormField<String>(
                initialValue: selectedFilterKategori,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                decoration: InputDecoration(
                  labelText: "Filter Kategori",
                  prefixIcon: const Icon(Icons.filter_list),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: kategoriFilterList.map((kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => selectedFilterKategori = val);
                },
              ),
            ),
            Expanded(
              child: sorted.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada data kerusakan",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final item = sorted[index];

                        final showHeader = index == 0 ||
                            sorted[index - 1].kategori != item.kategori;

                        final color = kategoriColor(item.kategori);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader) kategoriHeader(item.kategori),
                            Card(
                              color: const Color(0xFF1E293B),
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: color.withOpacity(0.12),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color.withOpacity(0.15),
                                      child: Icon(
                                        kategoriIcon(item.kategori),
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.nama,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item.kategori,
                                                  style: TextStyle(
                                                    color: color,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                item.deskripsi.join(". "),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ...item.solusi
                                              .split('\n')
                                              .map((s) => s.trim())
                                              .where((s) => s.isNotEmpty)
                                              .take(2)
                                              .map(
                                                (s) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: 3,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "• ",
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          s,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => showForm(item: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => hapus(item),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showForm(),
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async => cetakPDFKerusakan(),
            icon: const Icon(Icons.print),
            label: const Text("Cetak"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF211B24),
              foregroundColor: Colors.deepPurpleAccent.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}