class AdminBankModel {
  final String id;
  final String namaUnit;
  final String namaPengelola;
  final String telp;
  final String? foto;

  AdminBankModel({
    required this.id,
    required this.namaUnit,
    required this.namaPengelola,
    required this.telp,
    this.foto,
  });

  factory AdminBankModel.fromJson(Map<String, dynamic> json) {
    return AdminBankModel(
      id: json['id'] ?? '',
      namaUnit: json['namaUnit'] ?? '',
      namaPengelola: json['namaPengelola'] ?? '',
      telp: json['telp'] ?? '',
      foto: json['foto'],
    );
  }

  AdminBankModel copyWith({
    String? id,
    String? namaUnit,
    String? namaPengelola,
    String? telp,
    String? foto,
  }) {
    return AdminBankModel(
      id: id ?? this.id,
      namaUnit: namaUnit ?? this.namaUnit,
      namaPengelola: namaPengelola ?? this.namaPengelola,
      telp: telp ?? this.telp,
      foto: foto ?? this.foto,
    );
  }
}
