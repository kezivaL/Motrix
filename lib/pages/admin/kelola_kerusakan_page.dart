import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';
import '../../../models/kerusakan.dart';

class KelolaKerusakanPage extends StatefulWidget {
  const KelolaKerusakanPage({super.key});

  @override
  State<KelolaKerusakanPage> createState() =>
      _KelolaKerusakanPageState();
}

class _KelolaKerusakanPageState
    extends State<KelolaKerusakanPage> {

  final List<String> urutanKategori = [
    "Mesin",
    "Kelistrikan",
    "Transmisi",
    "Rem",
  ];

  void cetakData() {
    print("=== DATA KERUSAKAN ===");

    for (var k in DataManager.kerusakan) {
      print("Nama: ${k.nama}");
      print("Kategori: ${k.kategori}");
      print("Deskripsi: ${k.deskripsi.join(", ")}");
      print("Solusi: ${k.solusi}");
      print("------------------");
    }
  }

  void showForm({Kerusakan? item, int? index}) {
    final namaController =
        TextEditingController(text: item?.nama ?? "");

    final deskripsiController =
        TextEditingController(
      text: item?.deskripsi.join(" ") ?? "",
    );

    final solusiController =
        TextEditingController(
      text: item?.solusi ?? "",
    );

    String selectedKategori =
        item?.kategori ?? urutanKategori.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(item == null
                ? "Tambah Kerusakan"
                : "Edit Kerusakan"),
            content: SingleChildScrollView(
              child: Column(
                children: [

                  TextField(
                    controller: namaController,
                    decoration:
                        const InputDecoration(labelText: "Nama"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: deskripsiController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Deskripsi",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: solusiController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Solusi",
                      hintText:
                          "Pisahkan dengan ENTER\nContoh:\nGanti baterai\nCek kabel",
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    initialValue: selectedKategori,
                    items: urutanKategori.map((k) {
                      return DropdownMenuItem<String>(
                        value: k,
                        child: Text(k),
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
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  final nama = namaController.text;

                  final deskripsi = deskripsiController.text
                      .split('.')
                      .where((e) => e.trim().isNotEmpty)
                      .toList();

                  final solusi = solusiController.text;

                  if (nama.isEmpty) return;

                  setState(() {
                    if (item == null) {
                      DataManager.kerusakan.add(
                        Kerusakan(
                          id:
                              "K${DataManager.kerusakan.length + 1}",
                          nama: nama,
                          deskripsi: deskripsi,
                          solusi: solusi,
                          kategori: selectedKategori,
                        ),
                      );
                    } else {
                      DataManager.kerusakan[index!] =
                          Kerusakan(
                        id: item.id,
                        nama: nama,
                        deskripsi: deskripsi,
                        solusi: solusi,
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

  void hapus(int index) {
    setState(() {
      DataManager.kerusakan.removeAt(index);
    });
  }

  Color getKategoriColor(String kategori) {
    switch (kategori) {
      case "Mesin":
        return Colors.red;
      case "Kelistrikan":
        return Colors.amber;
      case "Transmisi":
        return Colors.blue;
      case "Rem":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    final sorted = List.from(DataManager.kerusakan);
    sorted.sort((a, b) =>
        urutanKategori.indexOf(a.kategori)
            .compareTo(
                urutanKategori.indexOf(b.kategori)));

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      child: Scaffold(
        appBar:
            AppBar(title: const Text("Kelola Kerusakan")),

        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final item = sorted[index];

            return Card(
              color: const Color(0xFF1E293B),
              child: ListTile(
                title: Text(item.nama,
                    style:
                        const TextStyle(color: Colors.white)),

                /// 🔥 FIX TOTAL DISINI
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 KATEGORI + DESKRIPSI
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                          decoration: BoxDecoration(
                            color: getKategoriColor(
                                    item.kategori)
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.kategori,
                            style: TextStyle(
                              color: getKategoriColor(
                                  item.kategori),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            item.deskripsi.join(". "),
                            style: const TextStyle(
                                color: Colors.white70),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// 🔥 SOLUSI LIST
                    ...item.solusi
                        .split('\n')
                        .map((s) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                                bottom: 4),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text("• ",
                                style: TextStyle(
                                    color:
                                        Colors.white70)),
                            Expanded(
                              child: Text(
                                s,
                                style:
                                    const TextStyle(
                                        color: Colors
                                            .white70),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),

                trailing: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.white),
                      onPressed: () =>
                          showForm(
                              item: item,
                              index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () =>
                          hapus(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        floatingActionButton:
            FloatingActionButton(
          onPressed: () => showForm(),
          child: const Icon(Icons.add),
        ),

        bottomNavigationBar: Container(
          padding:
              const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              cetakData();
            },
            icon: const Icon(Icons.print),
            label: const Text("Cetak"),
            style: ElevatedButton.styleFrom(
              minimumSize:
                  const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }
}