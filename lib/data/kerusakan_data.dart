import '../models/kerusakan.dart';

final List<Kerusakan> dataKerusakan = [
  Kerusakan(
    id: 'K1',
    nama: 'Motor Overheat',
    kategori: 'Mesin',
    solusi: 'Periksa pendinginan motor',
    deskripsi: [
      'Motor terlalu panas akibat pendinginan buruk',
      'Beban motor berlebih',
    ],
  ),
  Kerusakan(
    id: 'K2',
    nama: 'Bearing Motor Aus',
    kategori: 'Mesin',
    solusi: 'Ganti bearing motor',
    deskripsi: [
      'Bearing aus menyebabkan getaran',
      'Muncul suara berisik dari motor',
    ],
  ),
  Kerusakan(
    id: 'K3',
    nama: 'Dinamo Lemah',
    kategori: 'Mesin',
    solusi: 'Cek gulungan dinamo',
    deskripsi: [
      'Output daya menurun',
      'Motor tidak bertenaga',
    ],
  ),

  Kerusakan(
    id: 'K4',
    nama: 'Aki/Baterai Soak',
    kategori: 'Kelistrikan',
    solusi: 'Ganti baterai',
    deskripsi: [
      'Baterai tidak mampu menyimpan daya',
      'Motor sulit dinyalakan',
    ],
  ),
  Kerusakan(
    id: 'K5',
    nama: 'Kabel Putus',
    kategori: 'Kelistrikan',
    solusi: 'Perbaiki kabel',
    deskripsi: [
      'Aliran listrik terganggu',
      'Kabel longgar atau putus',
    ],
  ),
  Kerusakan(
    id: 'K6',
    nama: 'Controller Rusak',
    kategori: 'Kelistrikan',
    solusi: 'Ganti controller',
    deskripsi: [
      'Motor tidak merespon gas',
      'Sistem kontrol error',
    ],
  ),
  Kerusakan(
    id: 'K7',
    nama: 'Sekring Putus',
    kategori: 'Kelistrikan',
    solusi: 'Ganti sekring',
    deskripsi: [
      'Arus listrik terputus',
      'Motor tidak menyala',
    ],
  ),

  Kerusakan(
    id: 'K8',
    nama: 'Kampas Rem Aus',
    kategori: 'Rem',
    solusi: 'Ganti kampas rem',
    deskripsi: [
      'Rem tidak pakem',
      'Bunyi saat pengereman',
    ],
  ),
  Kerusakan(
    id: 'K9',
    nama: 'Minyak Rem Habis',
    kategori: 'Rem',
    solusi: 'Isi minyak rem',
    deskripsi: [
      'Tekanan rem berkurang',
      'Rem terasa dalam',
    ],
  ),
  Kerusakan(
    id: 'K10',
    nama: 'Rem Tidak Pakem',
    kategori: 'Rem',
    solusi: 'Setel sistem rem',
    deskripsi: [
      'Kendaraan sulit berhenti',
      'Rem kurang responsif',
    ],
  ),

  Kerusakan(
    id: 'K11',
    nama: 'Rantai Kendur',
    kategori: 'Transmisi',
    solusi: 'Setel rantai',
    deskripsi: [
      'Akselerasi tidak stabil',
      'Suara berisik',
    ],
  ),
  Kerusakan(
    id: 'K12',
    nama: 'Gear Aus',
    kategori: 'Transmisi',
    solusi: 'Ganti gear',
    deskripsi: [
      'Performa transmisi menurun',
      'Suara kasar',
    ],
  ),
  Kerusakan(
    id: 'K13',
    nama: 'CVT Bermasalah',
    kategori: 'Transmisi',
    solusi: 'Servis CVT',
    deskripsi: [
      'Akselerasi tidak lancar',
      'Muncul suara aneh',
    ],
  ),
  Kerusakan(
    id: 'K14',
    nama: 'Transmisi Macet',
    kategori: 'Transmisi',
    solusi: 'Periksa transmisi',
    deskripsi: [
      'Motor tidak bisa jalan',
      'Transmisi terkunci',
    ],
  ),
  Kerusakan(
    id: 'K15',
    nama: 'Suara Kasar Transmisi',
    kategori: 'Transmisi',
    solusi: 'Lumasi dan cek gear',
    deskripsi: [
      'Kurang pelumas',
      'Gear bermasalah',
    ],
  ),
];