class PenukaranPoinModel {
  final String id;
  final String? kodePenukaran;
  final String tanggal;
  final String? createdAt;
  final num poinTerpakai;
  final num? sisaSaldoPoin;
  final String status;
  final String? namaHadiah;
  final num? poinDibutuhkanHadiah;
  final String? fotoHadiah;
  final String? namaNasabah;
  final String? telpNasabah;

  PenukaranPoinModel({
    required this.id,
    this.kodePenukaran,
    required this.tanggal,
    this.createdAt,
    required this.poinTerpakai,
    this.sisaSaldoPoin,
    required this.status,
    this.namaHadiah,
    this.poinDibutuhkanHadiah,
    this.fotoHadiah,
    this.namaNasabah,
    this.telpNasabah,
  });

  num get totalPoinDisplay {
    if (poinTerpakai > 0) return poinTerpakai;
    if (poinDibutuhkanHadiah != null && poinDibutuhkanHadiah! > 0) return poinDibutuhkanHadiah!;
    return 0;
  }

  factory PenukaranPoinModel.fromJson(Map<String, dynamic> json) {
    final hadiah = json['hadiah'];
    final nasabah = json['nasabah'];
    final num poin = json['poinTerpakai'] ??
        json['totalPoin'] ??
        json['poinDibutuhkan'] ??
        (hadiah != null ? hadiah['poinDibutuhkan'] : null) ??
        0;

    return PenukaranPoinModel(
      id: json['id'] ?? '',
      kodePenukaran: json['kodePenukaran'],
      tanggal: json['tanggal'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? json['tanggal'],
      poinTerpakai: poin,
      sisaSaldoPoin: json['sisaSaldoPoin'],
      status: json['status'] ?? '',
      namaHadiah: hadiah != null ? hadiah['namaHadiah'] : json['namaHadiah'],
      poinDibutuhkanHadiah: hadiah != null ? hadiah['poinDibutuhkan'] : json['poinDibutuhkan'],
      fotoHadiah: hadiah != null ? hadiah['foto'] : json['fotoHadiah'],
      namaNasabah: nasabah != null ? nasabah['namaNasabah'] : json['namaNasabah'],
      telpNasabah: nasabah != null ? nasabah['telp'] : json['telpNasabah'],
    );
  }
}
