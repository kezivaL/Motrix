import 'package:flutter/material.dart';
import '../../../data/rule_data.dart';
import '../../../data/data_manager.dart';
import '../../../models/rule.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class KelolaRulePage extends StatefulWidget {
  const KelolaRulePage({super.key});

  @override
  State<KelolaRulePage> createState() => _KelolaRulePageState();
}

class _KelolaRulePageState extends State<KelolaRulePage> {

  /// 🔥 URUTAN KATEGORI
  final List<String> urutanKategori = [
    "Mesin",
    "Kelistrikan",
    "Transmisi",
    "Rem",
  ];

  /// ================= PDF =================
  Future<void> cetakPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final logo = await imageFromAssetBundle('assets/logo.png');

    /// 🔥 SORT RULE BERDASARKAN KATEGORI
    final sortedRule = List.from(dataRule);
    sortedRule.sort((a, b) {
      final kA = DataManager.kerusakan
          .firstWhere((k) => k.id == a.kerusakanId)
          .kategori;
      final kB = DataManager.kerusakan
          .firstWhere((k) => k.id == b.kerusakanId)
          .kategori;

      return urutanKategori.indexOf(kA)
          .compareTo(urutanKategori.indexOf(kB));
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

            /// HEADER
            pw.Row(
              children: [
                pw.Image(logo, width: 60, height: 60),
                pw.SizedBox(width: 15),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("SISTEM DIAGNOSA MOTOR LISTRIK",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("Aplikasi Motrix"),
                    pw.Text("Laporan Data Rule"),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Text(
                "Tanggal: ${now.day}/${now.month}/${now.year}"),
            pw.Text(
                "Waktu: ${now.hour}:${now.minute.toString().padLeft(2, '0')}"),
            pw.Text("Dicetak oleh: Admin"),

            pw.SizedBox(height: 15),

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(120),
                2: const pw.FlexColumnWidth(),
              },
              children: [

                /// HEADER
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    cellH("No"),
                    cellH("Kerusakan"),
                    cellH("Gejala"),
                  ],
                ),

                /// DATA
                ...List.generate(sortedRule.length, (index) {
                  final r = sortedRule[index];

                  final k = DataManager.kerusakan
                      .firstWhere((e) => e.id == r.kerusakanId);

                  final gejalaText = r.gejalaIds.map((gid) {
                    final g = DataManager.gejala
                        .firstWhere((e) => e.id == gid);
                    return "- ${g.nama}";
                  }).join("\n");

                  return pw.TableRow(children: [
                    cell("${index + 1}"),
                    cell("${k.nama} (${k.kategori})"),
                    cell(gejalaText),
                  ]);
                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget cell(String text) =>
      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text));

  pw.Widget cellH(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );

  /// ================= TAMBAH / EDIT =================
  void tambahRule({Rule? rule, int? index}) {
    String? selectedKerusakan = rule?.kerusakanId;
    List<String> selectedGejala = rule?.gejalaIds ?? [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {

          /// 🔥 SORT KERUSAKAN
          final sortedKerusakan = List.from(DataManager.kerusakan);
          sortedKerusakan.sort((a, b) =>
              urutanKategori.indexOf(a.kategori)
                  .compareTo(urutanKategori.indexOf(b.kategori)));

          /// 🔥 KATEGORI TERPILIH
          final selectedKategori = selectedKerusakan == null
              ? null
              : DataManager.kerusakan
                  .firstWhere((k) => k.id == selectedKerusakan)
                  .kategori;

          /// 🔥 SORT GEJALA
          final sortedGejala = List.from(DataManager.gejala);
          sortedGejala.sort((a, b) =>
              urutanKategori.indexOf(a.kategori)
                  .compareTo(urutanKategori.indexOf(b.kategori)));

          return AlertDialog(
            title: Text(rule == null ? "Tambah Rule" : "Edit Rule"),
            content: SingleChildScrollView(
              child: Column(
                children: [

                  /// 🔥 DROPDOWN KERUSAKAN
                  DropdownButtonFormField<String>(
                    initialValue: selectedKerusakan,
                    hint: const Text("Pilih Kerusakan"),
                    items: sortedKerusakan.map((k) {
                      return DropdownMenuItem<String>(
                        value: k.id,
                        child: Text("${k.nama} (${k.kategori})"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedKerusakan = val;
                        selectedGejala.clear();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 LIST GEJALA (FILTER + URUT)
                  ...sortedGejala
                      .where((g) =>
                          selectedKategori == null ||
                          g.kategori == selectedKategori)
                      .map((g) {
                    return CheckboxListTile(
                      title: Text("${g.nama} (${g.kategori})"),
                      value: selectedGejala.contains(g.id),
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            selectedGejala.add(g.id);
                          } else {
                            selectedGejala.remove(g.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedKerusakan == null ||
                      selectedGejala.isEmpty) return;

                  setState(() {
                    if (rule == null) {
                      dataRule.add(
                        Rule(
                          kerusakanId: selectedKerusakan!,
                          gejalaIds: selectedGejala,
                        ),
                      );
                    } else {
                      dataRule[index!] = Rule(
                        kerusakanId: selectedKerusakan!,
                        gejalaIds: selectedGejala,
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

  void hapus(int index) {
    setState(() {
      dataRule.removeAt(index);
    });
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {

    /// 🔥 SORT RULE UNTUK UI
    final sortedRule = List.from(dataRule);
    sortedRule.sort((a, b) {
      final kA = DataManager.kerusakan
          .firstWhere((k) => k.id == a.kerusakanId)
          .kategori;
      final kB = DataManager.kerusakan
          .firstWhere((k) => k.id == b.kerusakanId)
          .kategori;

      return urutanKategori.indexOf(kA)
          .compareTo(urutanKategori.indexOf(kB));
    });

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Kelola Rule")),

        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedRule.length,
          itemBuilder: (context, index) {
            final rule = sortedRule[index];

            final kerusakan = DataManager.kerusakan
                .firstWhere((k) => k.id == rule.kerusakanId);

            return Card(
              color: const Color(0xFF1E293B),
              child: ListTile(
                title: Text(
                  "${kerusakan.nama} (${kerusakan.kategori})",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${rule.gejalaIds.length} gejala",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () =>
                          tambahRule(rule: rule, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => hapus(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => tambahRule(),
          child: const Icon(Icons.add),
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              await cetakPDF();
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