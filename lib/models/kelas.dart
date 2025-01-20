class Kelas {
  final int id;
  final String namaKelas;
  final DateTime createdAt;
  final List<Siswa> siswa;

  Kelas({
    required this.id,
    required this.namaKelas,
    required this.createdAt,
    this.siswa = const [],
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    var siswaList =
        (json['siswa'] as List?)?.map((s) => Siswa.fromJson(s)).toList() ?? [];

    return Kelas(
      id: json['id'],
      namaKelas: json['nama_kelas'],
      createdAt: DateTime.parse(json['created_at']),
      siswa: siswaList,
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
