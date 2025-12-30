class WetonResultModel {
  final String weton; 
  final String namaDino;
  final String namaPasaran;
  final int neptuDino; 
  final int neptuPasaran;  
  final int jumlahNeptu;
  final String tanggalJawa;

  WetonResultModel({
    required this.weton,
    required this.namaDino,
    required this.namaPasaran,
    required this.neptuDino,
    required this.neptuPasaran,
    required this.jumlahNeptu,
    required this.tanggalJawa,
  });

  @override
  String toString() {
    return 'Weton: $weton, Tanggal Jawa: $tanggalJawa, Neptu: $jumlahNeptu';
  }
}