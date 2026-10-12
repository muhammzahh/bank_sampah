import '../core/constants/api_constants.dart';

class HadiahModel {
  final String id;
  final String namaHadiah;
  final num poinDibutuhkan;
  final num stok;
  final String? foto;

  HadiahModel({
    required this.id,
    required this.namaHadiah,
    required this.poinDibutuhkan,
    required this.stok,
    this.foto,
  });

  factory HadiahModel.fromJson(Map<String, dynamic> json) {
    String? rawFoto = json['foto'] ?? json['image'] ?? json['fotoUrl'] ?? json['imageUrl'] ?? json['gambar'];
    String? formattedFoto;

    if (rawFoto != null && rawFoto.toString().trim().isNotEmpty) {
      final val = rawFoto.toString().trim();
      if (val.startsWith('http://') || val.startsWith('https://') || val.startsWith('file://')) {
        formattedFoto = val;
      } else {
        final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
        final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
        final cleanPath = val.startsWith('/') ? val : '/$val';
        formattedFoto = '$cleanBase$cleanPath';
      }
    }

    return HadiahModel(
      id: json['id'] ?? '',
      namaHadiah: json['namaHadiah'] ?? '',
      poinDibutuhkan: json['poinDibutuhkan'] ?? 0,
      stok: json['stok'] ?? 0,
      foto: formattedFoto,
    );
  }
}
