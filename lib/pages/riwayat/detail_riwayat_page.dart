import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class DetailRiwayatPage extends StatelessWidget {
  final DateTime tanggal;
  final List<Map<String, dynamic>> results;
  final int totalGejala;
  final List<Map<String, dynamic>> gejalaTerpilih;

  const DetailRiwayatPage({
    super.key,
    required this.tanggal,
    required this.results,
    required this.totalGejala,
    this.gejalaTerpilih = const [],
  });

  String bulan(int bulan) {
    const namaBulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    return namaBulan[bulan - 1];
  }

  String formatTanggal(DateTime date) {
    return "${date.day} ${bulan(date.month)} ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color getScoreColor(double skor) {
    if (skor >= 0.7) return const Color(0xFFEF4444);
    if (skor >= 0.4) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }

  Future<void> cetakHasil() async {
    final pdf = pw.Document();

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
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "SISTEM DIAGNOSA MOTOR LISTRIK",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text("Aplikasi Motrix"),
                    pw.Text("Laporan Detail Riwayat Diagnosa"),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              "Tanggal Diagnosa: ${tanggal.day}/${tanggal.month}/${tanggal.year}",
            ),
            pw.Text(
              "Waktu Diagnosa: ${tanggal.hour}:${tanggal.minute.toString().padLeft(2, '0')}",
            ),
            pw.Text("Total Gejala Dipilih: $totalGejala"),
            pw.Text("Total Kemungkinan: ${results.length} kerusakan"),
            pw.SizedBox(height: 15),
            pw.Text(
              "Gejala yang Dipilih Pengguna",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (gejalaTerpilih.isEmpty)
              pw.Text("-")
            else
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(80),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pdfHeaderCell("No"),
                      pdfHeaderCell("Gejala"),
                      pdfHeaderCell("CF User"),
                    ],
                  ),
                  ...List.generate(gejalaTerpilih.length, (index) {
                    final item = gejalaTerpilih[index];

                    return pw.TableRow(
                      children: [
                        pdfCell("${index + 1}"),
                        pdfCell(item["nama"] ?? "-"),
                        pdfCell(
                          ((item["cfUser"] ?? 0).toDouble())
                              .toStringAsFixed(1),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 18),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(120),
                2: const pw.FixedColumnWidth(70),
                3: const pw.FlexColumnWidth(),
                4: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    pdfHeaderCell("No"),
                    pdfHeaderCell("Kerusakan"),
                    pdfHeaderCell("CF"),
                    pdfHeaderCell("Deskripsi"),
                    pdfHeaderCell("Saran Perbaikan"),
                  ],
                ),
                ...List.generate(results.length, (index) {
                  final item = results[index];

                  final double skor =
                      (item["skor"] ?? 0).toDouble().clamp(0.0, 1.0);

                  final persen = (skor * 100).toStringAsFixed(1);

                  final solusiText = (item["solusi"] ?? "")
                      .toString()
                      .split('\n')
                      .where((e) => e.trim().isNotEmpty)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => "${entry.key + 1}. ${entry.value.trim()}")
                      .join("\n");

                  return pw.TableRow(
                    children: [
                      pdfCell("${index + 1}"),
                      pdfCell(item["nama"] ?? "-"),
                      pdfCell("$persen%"),
                      pdfCell(item["deskripsi"] ?? "-"),
                      pdfCell(solusiText.isEmpty ? "-" : solusiText),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Catatan:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Nilai CF diperoleh dari kombinasi keyakinan pengguna dan bobot pakar pada setiap gejala yang dipilih.",
              style: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget pdfHeaderCell(String text) {
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

  pw.Widget pdfCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedResults = List<Map<String, dynamic>>.from(results);
    sortedResults.sort(
      (a, b) => (b["skor"] ?? 0).toDouble().compareTo(
            (a["skor"] ?? 0).toDouble(),
          ),
    );

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
                        "Detail Riwayat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatTanggal(tanggal),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$totalGejala gejala dipilih",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: sortedResults.isEmpty
                ? const Center(child: Text("Tidak ada hasil diagnosa"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: sortedResults.length,
                    itemBuilder: (context, index) {
                      final item = sortedResults[index];

                      final double skor =
                          (item["skor"] ?? 0).toDouble().clamp(0.0, 1.0);

                      final int persen = (skor * 100).round();
                      final color = getScoreColor(skor);

                      final solusi = (item["solusi"] ?? "").toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: color.withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  child: Text(
                                    "#${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item["nama"] ?? "-",
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "$persen%",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Tingkat Kemungkinan",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: skor,
                                minHeight: 10,
                                color: color,
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                            const SizedBox(height: 18),
                            buildSectionTitle(
                              Icons.description_outlined,
                              "Deskripsi",
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["deskripsi"] ?? "-",
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 18),
                            buildSectionTitle(
                              Icons.construction_rounded,
                              "Saran Perbaikan",
                            ),
                            const SizedBox(height: 8),
                            ...solusi
                                .split('\n')
                                .where((e) => e.trim().isNotEmpty)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              final int i = entry.key + 1;
                              final String s = entry.value.trim();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$i. ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: cetakHasil,
          icon: const Icon(Icons.print_rounded),
          label: const Text("Cetak"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: const Color(0xFFE9D5FF),
            foregroundColor: const Color(0xFF5B21B6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}