import 'package:flutter/material.dart';
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

  dynamic cariKerusakan(String kerusakanId) {
    try {
      return DataManager.kerusakan.firstWhere((k) => k.id == kerusakanId);
    } catch (_) {
      return null;
    }
  }

  dynamic cariGejala(String gejalaId) {
    try {
      return DataManager.gejala.firstWhere((g) => g.id == gejalaId);
    } catch (_) {
      return null;
    }
  }

  List<String> getKategoriList() {
    final kategoriSet = <String>{};

    for (final rule in DataManager.rules) {
      final kerusakan = cariKerusakan(rule.kerusakanId);
      if (kerusakan != null) {
        kategoriSet.add(kerusakan.kategori);
      }
    }

    final kategoriList = kategoriSet.toList()
      ..sort((a, b) => kategoriIndex(a).compareTo(kategoriIndex(b)));

    return ["Semua", ...kategoriList];
  }

  List<Rule> getSortedRule() {
  final sortedRule = List<Rule>.from(DataManager.rules);

    sortedRule.sort((a, b) {
      final kA = cariKerusakan(a.kerusakanId);
      final kB = cariKerusakan(b.kerusakanId);

      final kategoriA = kA?.kategori ?? "";
      final kategoriB = kB?.kategori ?? "";

      final kategoriCompare =
          kategoriIndex(kategoriA).compareTo(kategoriIndex(kategoriB));

      if (kategoriCompare != 0) return kategoriCompare;

      final namaA = (kA?.nama ?? "").toString().toLowerCase();
      final namaB = (kB?.nama ?? "").toString().toLowerCase();

      return namaA.compareTo(namaB);
    });

    if (selectedKategori == "Semua") return sortedRule;

    return sortedRule.where((rule) {
      final kerusakan = cariKerusakan(rule.kerusakanId);
      return kerusakan?.kategori == selectedKategori;
    }).toList();
  }

  List<dynamic> getSortedKerusakan() {
    final list = List<dynamic>.from(DataManager.kerusakan);

    list.sort((a, b) {
      final kategoriCompare = kategoriIndex(a.kategori).compareTo(
        kategoriIndex(b.kategori),
      );

      if (kategoriCompare != 0) return kategoriCompare;

      return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
    });

    return list;
  }

  List<dynamic> getSortedGejalaByKategori(String? kategori) {
    final list = List<dynamic>.from(DataManager.gejala);

    list.sort((a, b) {
      final kategoriCompare = kategoriIndex(a.kategori).compareTo(
        kategoriIndex(b.kategori),
      );

      if (kategoriCompare != 0) return kategoriCompare;

      return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
    });

    if (kategori == null) return list;

    return list.where((g) => g.kategori == kategori).toList();
  }

  Future<String?> pilihKerusakanDialog(String? selectedId) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final kerusakanList = getSortedKerusakan();

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.82,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Pilih Kerusakan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      for (final kategori in urutanKategori) ...[
                        if (kerusakanList.any((k) => k.kategori == kategori))
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  kategoriIcon(kategori),
                                  color: kategoriColor(kategori),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  kategori,
                                  style: TextStyle(
                                    color: kategoriColor(kategori),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...kerusakanList
                            .where((k) => k.kategori == kategori)
                            .map((k) {
                          final aktif = k.id == selectedId;

                          return Card(
                            color: aktif
                                ? kategoriColor(k.kategori).withOpacity(0.22)
                                : const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: aktif
                                    ? kategoriColor(k.kategori)
                                    : Colors.white10,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    kategoriColor(k.kategori).withOpacity(0.16),
                                child: Icon(
                                  kategoriIcon(k.kategori),
                                  color: kategoriColor(k.kategori),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                k.nama,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                k.kategori,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: aktif
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.lightGreenAccent,
                                    )
                                  : const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white54,
                                    ),
                              onTap: () => Navigator.pop(context, k.id),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> cetakPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final logo = await imageFromAssetBundle('assets/logo.png');
    final sortedRule = getSortedRule();

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
                pw.Image(logo, width: 60, height: 60),
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
                      pw.Text("Laporan Data Rule"),
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
            pw.Text("Filter Kategori: $selectedKategori"),
            pw.SizedBox(height: 15),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(120),
                2: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    cellH("No"),
                    cellH("Kerusakan"),
                    cellH("Gejala & Bobot"),
                  ],
                ),
                ...List.generate(sortedRule.length, (index) {
                  final r = sortedRule[index];
                  final k = cariKerusakan(r.kerusakanId);

                  final gejalaText = r.gejalaRules.map((rg) {
                    final g = cariGejala(rg.gejalaId);
                    return "- ${g?.nama ?? 'Gejala tidak ditemukan'} | Bobot: ${rg.bobotPakar.toStringAsFixed(1)}";
                  }).join("\n");

                  return pw.TableRow(
                    children: [
                      cell("${index + 1}"),
                      cell(
                        "${k?.nama ?? 'Kerusakan tidak ditemukan'} (${k?.kategori ?? '-'})",
                      ),
                      cell(gejalaText),
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
      child: pw.Text(text),
    );
  }

  pw.Widget cellH(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  void tambahRule({Rule? rule, int? index}) {
    String? selectedKerusakan = rule?.kerusakanId;

    Map<String, double> selectedGejala = {
      for (var g in rule?.gejalaRules ?? []) g.gejalaId: g.bobotPakar,
    };

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final kerusakanTerpilih = selectedKerusakan == null
              ? null
              : cariKerusakan(selectedKerusakan!);

          final selectedKategoriRule = kerusakanTerpilih?.kategori;

          final filteredGejala = getSortedGejalaByKategori(
            selectedKategoriRule,
          );

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 24,
            ),
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.94,
              height: MediaQuery.of(context).size.height * 0.86,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rule == null ? "Tambah Rule" : "Edit Rule",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kerusakan",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final result = await pilihKerusakanDialog(
                                selectedKerusakan,
                              );

                              if (result == null) return;

                              setModalState(() {
                                selectedKerusakan = result;
                                selectedGejala.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  if (kerusakanTerpilih != null)
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          kategoriColor(kerusakanTerpilih.kategori)
                                              .withOpacity(0.16),
                                      child: Icon(
                                        kategoriIcon(
                                          kerusakanTerpilih.kategori,
                                        ),
                                        color: kategoriColor(
                                          kerusakanTerpilih.kategori,
                                        ),
                                        size: 18,
                                      ),
                                    )
                                  else
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white10,
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: kerusakanTerpilih == null
                                        ? const Text(
                                            "Pilih kerusakan",
                                            style: TextStyle(
                                              color: Colors.white54,
                                            ),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                kerusakanTerpilih.nama,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                kerusakanTerpilih.kategori,
                                                style: TextStyle(
                                                  color: kategoriColor(
                                                    kerusakanTerpilih.kategori,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Gejala Terkait",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (selectedKategoriRule != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kategoriColor(selectedKategoriRule)
                                        .withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    selectedKategoriRule,
                                    style: TextStyle(
                                      color: kategoriColor(selectedKategoriRule),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (selectedKerusakan == null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Text(
                                "Pilih kerusakan terlebih dahulu. Setelah itu gejala akan tampil otomatis sesuai kategori kerusakan.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          else if (filteredGejala.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Text(
                                "Belum ada gejala pada kategori ini.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          else
                            ...filteredGejala.map((g) {
                              final checked = selectedGejala.containsKey(g.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: checked
                                      ? Colors.blue.withOpacity(0.13)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: checked
                                        ? Colors.lightBlueAccent
                                            .withOpacity(0.8)
                                        : Colors.white10,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      dense: true,
                                      value: checked,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: Colors.deepPurpleAccent,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        g.nama,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        checked
                                            ? "${g.kategori} • Bobot Pakar: ${selectedGejala[g.id]!.toStringAsFixed(1)}"
                                            : g.kategori,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            selectedGejala[g.id] = 0.8;
                                          } else {
                                            selectedGejala.remove(g.id);
                                          }
                                        });
                                      },
                                    ),
                                    if (checked)
                                      Row(
                                        children: [
                                          const Text(
                                            "0",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Expanded(
                                            child: Slider(
                                              value: selectedGejala[g.id]!,
                                              min: 0,
                                              max: 1,
                                              divisions: 10,
                                              label: selectedGejala[g.id]!
                                                  .toStringAsFixed(1),
                                              onChanged: (val) {
                                                setModalState(() {
                                                  selectedGejala[g.id] = val;
                                                });
                                              },
                                            ),
                                          ),
                                          const Text(
                                            "1",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF111827),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(22),
                      ),
                    ),
                    child: Row(
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
                            onPressed: () async {
                              if (selectedKerusakan == null ||
                                  selectedGejala.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Pilih kerusakan dan minimal satu gejala",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final newRule = Rule(
                                kerusakanId: selectedKerusakan!,
                                gejalaRules: selectedGejala.entries.map((e) {
                                  return RuleGejala(
                                    gejalaId: e.key,
                                    bobotPakar: e.value,
                                  );
                                }).toList(),
                              );

                              final updated = List<Rule>.from(DataManager.rules);

                              if (rule == null) {
                                final existingIndex = updated.indexWhere(
                                  (r) => r.kerusakanId == selectedKerusakan,
                                );

                                if (existingIndex == -1) {
                                  updated.add(newRule);
                                } else {
                                  updated[existingIndex] = newRule;
                                }
                              } else {
                                if (index != null && index >= 0 && index < updated.length) {
                                  updated[index] = newRule;
                                }
                              }

                              await DataManager.saveRules(updated);

                              if (!mounted) return;
                              setState(() {});

                              Navigator.pop(context);
                            },
                            child: const Text("Simpan"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

Future<void> hapus(Rule rule) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Hapus Rule'),
        content: Text(
          'Yakin ingin menghapus aturan untuk kerusakan "${rule.kerusakanId}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Hapus'),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  final updated = List<Rule>.from(DataManager.rules);
  updated.removeWhere((item) => item.kerusakanId == rule.kerusakanId);

  await DataManager.saveRules(updated);

  if (!mounted) return;
  setState(() {});

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Rule berhasil dihapus'),
      backgroundColor: Colors.green,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final kategoriList = getKategoriList();
    final sortedRule = getSortedRule();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Kelola Rule")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DropdownButtonFormField<String>(
                initialValue: selectedKategori,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                decoration: InputDecoration(
                  labelText: "Filter Kategori",
                  prefixIcon: const Icon(Icons.filter_list),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: kategoriList.map((kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedKategori = value);
                },
              ),
            ),
            Expanded(
              child: sortedRule.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada rule untuk kategori ini",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedRule.length,
                      itemBuilder: (context, index) {
                        final rule = sortedRule[index];
                        final kerusakan = cariKerusakan(rule.kerusakanId);
                        final originalIndex = DataManager.rules.indexWhere(
                        (item) => item.kerusakanId == rule.kerusakanId,
                      );

                        final kategori = kerusakan?.kategori ?? "-";
                        final color = kategoriColor(kategori);

                        return Card(
                          color: const Color(0xFF1E293B),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: color.withOpacity(0.18),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color.withOpacity(0.15),
                                      child: Icon(
                                        kategoriIcon(kategori),
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        kerusakan?.nama ??
                                            "Kerusakan tidak ditemukan",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => tambahRule(
                                        rule: rule,
                                        index: originalIndex,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => hapus(rule),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        kategori,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: color.withOpacity(0.14),
                                      side: BorderSide.none,
                                    ),
                                    Chip(
                                      label: Text(
                                        "${rule.gejalaRules.length} gejala",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor:
                                          Colors.green.withOpacity(0.18),
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...rule.gejalaRules.take(3).map((rg) {
                                  final gejala = cariGejala(rg.gejalaId);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "• ",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            gejala?.nama ??
                                                "Gejala tidak ditemukan",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          "CF ${rg.bobotPakar.toStringAsFixed(1)}",
                                          style: const TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                if (rule.gejalaRules.length > 3)
                                  Text(
                                    "+${rule.gejalaRules.length - 3} gejala lainnya",
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => tambahRule(),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async => cetakPDF(),
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