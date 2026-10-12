class NasabahModel {
  final String id;
  final String namaNasabah;
  final String alamat;
  final String telp;
  final int saldoPoin;
  final String? foto;

  NasabahModel({
    required this.id,
    required this.namaNasabah,
    required this.alamat,
    required this.telp,
    required this.saldoPoin,
    this.foto,
  });

  factory NasabahModel.fromJson(Map<String, dynamic> json) {
    return NasabahModel(
      id: json['id'] ?? '',
      namaNasabah: json['namaNasabah'] ?? '',
      alamat: json['alamat'] ?? '',
      telp: json['telp'] ?? '',
      saldoPoin: (json['saldoPoin'] ?? 0) is int
          ? json['saldoPoin']
          : (json['saldoPoin'] as num).toInt(),
      foto: json['foto'],
    );
  }

  NasabahModel copyWith({
    String? id,
    String? namaNasabah,
    String? alamat,
    String? telp,
    int? saldoPoin,
    String? foto,
  }) {
    return NasabahModel(
      id: id ?? this.id,
      namaNasabah: namaNasabah ?? this.namaNasabah,
      alamat: alamat ?? this.alamat,
      telp: telp ?? this.telp,
      saldoPoin: saldoPoin ?? this.saldoPoin,
      foto: foto ?? this.foto,
    );
  }
}
