import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';
import '../../../models/symptom.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class KelolaGejalaPage extends StatefulWidget {
  const KelolaGejalaPage({super.key});

  @override
  State<KelolaGejalaPage> createState() => _KelolaGejalaPageState();
}

class _KelolaGejalaPageState extends State<KelolaGejalaPage> {

  /// 🔥 URUTAN KATEGORI
  final List<String> urutanKategori = [
    "Mesin",
    "Kelistrikan",
    "Transmisi",
    "Rem",
  ];

  /// ================= PDF =================
  Future<void> cetakPDFGejala() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pw.ImageProvider? logo;
    try {
      logo = await imageFromAssetBundle('assets/logo.png');
    } catch (e) {
      print("LOGO ERROR: $e");
    }

    /// 🔥 SORT DATA
    final sortedGejala = List.from(DataManager.gejala);
    sortedGejala.sort((a, b) {
      final indexA = urutanKategori.indexOf(a.kategori);
      final indexB = urutanKategori.indexOf(b.kategori);
      return indexA.compareTo(indexB);
    });

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

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("SISTEM DIAGNOSA MOTOR LISTRIK",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("Aplikasi Motrix"),
                    pw.Text("Laporan Data Gejala"),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    "Tanggal: ${now.day}/${now.month}/${now.year}"),
                pw.Text(
                    "Waktu: ${now.hour}:${now.minute.toString().padLeft(2, '0')}"),
              ],
            ),

            pw.Text("Dicetak oleh: Admin"),

            pw.SizedBox(height: 10),

            pw.Text(
                "Laporan ini berisi data gejala yang digunakan dalam sistem diagnosa motor listrik."),

            pw.SizedBox(height: 15),

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(250),
                2: const pw.FlexColumnWidth(),
              },
              children: [

                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    cellHeader("No"),
                    cellHeader("Nama Gejala"),
                    cellHeader("Kategori"),
                  ],
                ),

                ...List.generate(sortedGejala.length, (index) {
                  final g = sortedGejala[index];

                  return pw.TableRow(
                    children: [
                      cell("${index + 1}"),
                      cell(g.nama),
                      cell(g.kategori),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 30),

            /// 🔥 TANDA TANGAN (OPSIONAL TAPI KEREN)
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text("Admin"),
                  pw.SizedBox(height: 40),
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
      child: pw.Text(text),
    );
  }

  pw.Widget cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  /// ================= FORM =================
 void showForm({Symptom? symptom, int? index}) {
  final namaController =
      TextEditingController(text: symptom?.nama ?? "");

  String selectedKategori =
      symptom?.kategori ?? urutanKategori.first;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) {
        return AlertDialog(
          title:
              Text(symptom == null ? "Tambah Gejala" : "Edit Gejala"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// NAMA
              TextField(
                controller: namaController,
                decoration:
                    const InputDecoration(labelText: "Nama Gejala"),
              ),

              const SizedBox(height: 10),

              /// 🔥 DROPDOWN KATEGORI
              DropdownButtonFormField<String>(
                initialValue: selectedKategori,
                items: urutanKategori.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (val) {
                  setModalState(() {
                    selectedKategori = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Kategori",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final nama = namaController.text;

                if (nama.isEmpty) return;

                setState(() {
                  if (symptom == null) {
                    DataManager.gejala.add(
                      Symptom(
                        id: "G${DataManager.gejala.length + 1}",
                        nama: nama,
                        kategori: selectedKategori,
                      ),
                    );
                  } else {
                    DataManager.gejala[index!] = Symptom(
                      id: symptom.id,
                      nama: nama,
                      kategori: selectedKategori,
                    );
                  }
                });

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    ),
  );
}

  void hapusGejala(int index) {
    setState(() {
      DataManager.gejala.removeAt(index);
    });
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {

    /// 🔥 SORT UI
    final sortedGejala = List.from(DataManager.gejala);
    sortedGejala.sort((a, b) {
      final indexA = urutanKategori.indexOf(a.kategori);
      final indexB = urutanKategori.indexOf(b.kategori);
      return indexA.compareTo(indexB);
    });

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Kelola Gejala")),

        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedGejala.length,
          itemBuilder: (context, index) {
            final item = sortedGejala[index];

            return Card(
              color: const Color(0xFF1E293B),
              child: ListTile(
                title: Text(item.nama,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.kategori,
                    style: const TextStyle(color: Colors.white70)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () =>
                          showForm(symptom: item, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => hapusGejala(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => showForm(),
          child: const Icon(Icons.add),
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              await cetakPDFGejala();
            },
            icon: const Icon(Icons.print),
            label: const Text("Cetak"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }
}