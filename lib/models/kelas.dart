import 'dart:convert';

class Kelas {
  final int id;
  final String namaKelas;
  final DateTime createdAt;
  final List<Siswa> siswa;
  Map<String, dynamic>? jadwal;

  Kelas({
    required this.id,
    required this.namaKelas,
    required this.createdAt,
    this.siswa = const [],
    this.jadwal,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    var siswaList =
        (json['siswa'] as List?)?.map((s) => Siswa.fromJson(s)).toList() ?? [];
    Map<String, String>? jadwalMap;
    if (json['jadwal'] != null) {
      if (json['jadwal'] is String) {
        final decoded = jsonDecode(json['jadwal']);
        jadwalMap = Map<String, String>.from(decoded);
      } else {
        jadwalMap = Map<String, String>.from(json['jadwal']);
      }
    }

    return Kelas(
      id: json['id'],
      namaKelas: json['nama_kelas'],
      createdAt: DateTime.parse(json['created_at']),
      siswa: siswaList,
      jadwal: jadwalMap,
    );
  }
}

class Siswa {
  final int id;
  final String namaSiswa;

  Siswa({
    required this.id,
    required this.namaSiswa,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      namaSiswa: json['nama_siswa'],
    );
  }
}
