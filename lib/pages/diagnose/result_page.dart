import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final int totalGejala;
  final List<Map<String, dynamic>> gejalaTerpilih;

  const ResultPage({
    super.key,
    required this.results,
    required this.totalGejala,
    this.gejalaTerpilih = const [],
  });

Future<void> cetakHasil() async {
  final pdf = pw.Document();
  final now = DateTime.now();

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
                  pw.Text("Laporan Hasil Diagnosa"),
                ],
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
                    .map(
                      (entry) =>
                          "${entry.key + 1}. ${entry.value.trim()}",
                    )
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

          pw.SizedBox(height: 25),

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
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text("Hasil Diagnosa"),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          buildHeader(now),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text("Tidak ada hasil diagnosa"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return buildResultCard(item, index);
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

  Widget buildHeader(DateTime now) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.analytics_rounded,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${now.day} ${_bulan(now.month)} ${now.year} • ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$totalGejala gejala dipilih",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(Map<String, dynamic> item, int index) {
    final double skor = (item["skor"] ?? 0).toDouble().clamp(0.0, 1.0);
    final int persen = (skor * 100).round();
    final String solusi = item["solusi"] ?? "";
    final Color color = getScoreColor(skor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
          buildSectionTitle(Icons.description_outlined, "Deskripsi"),
          const SizedBox(height: 8),
          Text(
            item["deskripsi"] ?? "-",
            style: const TextStyle(
              color: Color(0xFF334155),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          buildSectionTitle(Icons.construction_rounded, "Saran Perbaikan"),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
  }

  Widget buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
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

  Color getScoreColor(double skor) {
    if (skor >= 0.7) return Colors.redAccent;
    if (skor >= 0.4) return Colors.orangeAccent;
    return Colors.green;
  }

  static String _bulan(int bulan) {
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
}