class KategoriSampahModel {
  final String id;
  final String namaKategori;
  final num hargaPerKg;
  final num poinPerKg;
  final String jenis; // plastik | kertas | logam | kaca | organik
  final String? foto;

  KategoriSampahModel({
    required this.id,
    required this.namaKategori,
    required this.hargaPerKg,
    required this.poinPerKg,
    required this.jenis,
    this.foto,
  });

  factory KategoriSampahModel.fromJson(Map<String, dynamic> json) {
    return KategoriSampahModel(
      id: json['id'] ?? '',
      namaKategori: json['namaKategori'] ?? '',
      hargaPerKg: json['hargaPerKg'] ?? 0,
      poinPerKg: json['poinPerKg'] ?? 0,
      jenis: json['jenis'] ?? '',
      foto: json['foto'],
    );
  }
}
