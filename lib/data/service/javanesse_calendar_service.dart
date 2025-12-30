import 'package:islami_app/data/model/weton_result_model.dart';

class JavanesseCalendarService {
  static const List<String> _pasaran = [
    'Legi',
    'Pahing',
    'Pon',
    'Wage',
    'Kliwon'
  ];
  static const List<String> _dino = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu'
  ];
  static const List<int> _neptuPasaran = [5, 9, 7, 4, 8];
  static const List<int> _neptuDino = [5, 4, 3, 7, 8, 6, 9];
  static const List<String> _namaBulanJawa = [
    'Sura',
    'Sapar',
    'Mulud',
    'Bakda Mulud',
    'Jumadilawal',
    'Jumadilakir',
    'Rejeb',
    'Ruwah',
    'Pasa',
    'Sawal',
    'Dulkangidah',
    'Besar'
  ];
  static const List<int> _lamaBulanJawa = [
    30,
    29,
    30,
    29,
    30,
    29,
    30,
    29,
    30,
    29,
    30,
    0
  ];

  // 8 Juli 2024 Masehi adalah 1 Sura 1958 Je (Senin Legi)
  static final DateTime refDate = DateTime(2024, 7, 8);
  static const int refPasaranIndex = 0; // Legi
  static const int refTahunJawa = 1958;
  static const int refBulanJawa = 1; // Sura adalah bulan ke-1
  static const int refTanggalJawa = 1;

  //* Helper untuk mengecek tahun kabisat (wuntu) dalam siklus 8 tahun (windu)
  static bool _isTahunWuntu(int tahun) {
    // Referensi: Tahun 1958 adalah Je (posisi 4 dari 8)
    // Siklus nama: Alip, Ehe, Jimawal, Je, Dal, Be, Wawu, Jimakir
    // Tahun wuntu/kabisat jatuh pada Ehe, Dal, Be, Jimakir
    final List<int> tahunWuntuPos = [2, 5, 6, 8];
    // Menghitung posisi tahun target dalam siklus windu relatif terhadap tahun referensi
    final int posisiSiklus = (4 + (tahun - refTahunJawa)) % 8;
    // Jika hasilnya 0, berarti posisi ke-8 (Jimakir)
    return tahunWuntuPos.contains(posisiSiklus == 0 ? 8 : posisiSiklus);
  }

  /// Fungsi utama untuk menghitung semua detail kalender Jawa.
  static WetonResultModel hitungWeton(DateTime tanggal) {
    // 1. Hitung selisih hari dari tanggal referensi
    final int selisihHari = tanggal.difference(refDate).inDays;

    // 2. Hitung Weton dan Neptu (logika yang sudah ada)
    final int dinoIndex = tanggal.weekday % 7;
    final int pasaranIndex = (selisihHari + refPasaranIndex) % 5;
    final String namaDino = _dino[dinoIndex];
    final String namaPasaran = _pasaran[pasaranIndex];
    final int neptuDino = _neptuDino[dinoIndex];
    final int neptuPasaran = _neptuPasaran[pasaranIndex];

    // 3. Hitung Tanggal, Bulan, dan Tahun Jawa
    // Hitung total hari yang telah berlalu di tahun referensi sampai tanggal referensi
    int hariTerlewatDiTahunRef = 0;
    for (int i = 0; i < refBulanJawa - 1; i++) {
      hariTerlewatDiTahunRef += _lamaBulanJawa[i];
    }
    hariTerlewatDiTahunRef += refTanggalJawa;

    // Total hari dari awal tahun referensi (1 Sura 1958) ke tanggal target
    int totalHariJawa = hariTerlewatDiTahunRef + selisihHari;

    int tahunJawa = refTahunJawa;
    int hariDalamSetahun = _isTahunWuntu(tahunJawa) ? 355 : 354;

    // Menyesuaikan tahun jika total hari melebihi/kurang dari hari dalam setahun
    if (totalHariJawa > 0) {
      while (totalHariJawa > hariDalamSetahun) {
        totalHariJawa -= hariDalamSetahun;
        tahunJawa++;
        hariDalamSetahun = _isTahunWuntu(tahunJawa) ? 355 : 354;
      }
    } else {
      while (totalHariJawa <= 0) {
        tahunJawa--;
        hariDalamSetahun = _isTahunWuntu(tahunJawa) ? 355 : 354;
        totalHariJawa += hariDalamSetahun;
      }
    }

    // Menemukan bulan dan tanggal dari sisa hari
    int bulanJawaIndex = 0;
    for (int i = 0; i < _lamaBulanJawa.length; i++) {
      int hariDalamSebulan = (i == 11) // Jika bulan Besar
          ? (_isTahunWuntu(tahunJawa) ? 30 : 29)
          : _lamaBulanJawa[i];

      if (totalHariJawa <= hariDalamSebulan) {
        bulanJawaIndex = i;
        break;
      }
      totalHariJawa -= hariDalamSebulan;
    }

    final int tanggalJawa = totalHariJawa;
    final String namaBulanJawa = _namaBulanJawa[bulanJawaIndex];

    // 4. Kembalikan semua hasil dalam satu objek
    return WetonResultModel(
      weton: '$namaDino $namaPasaran',
      namaDino: namaDino,
      namaPasaran: namaPasaran,
      neptuDino: neptuDino,
      neptuPasaran: neptuPasaran,
      jumlahNeptu: neptuDino + neptuPasaran,
      tanggalJawa: '$tanggalJawa $namaBulanJawa $tahunJawa',
    );
  }
}