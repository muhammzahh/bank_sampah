class DetailSetorModel {
  final String? kategoriSampahId;
  final String? namaKategori;
  final String? jenis;
  final num beratKg;
  final num? poinPerKg;
  final num subtotalPoin;

  DetailSetorModel({
    this.kategoriSampahId,
    this.namaKategori,
    this.jenis,
    required this.beratKg,
    this.poinPerKg,
    required this.subtotalPoin,
  });

  factory DetailSetorModel.fromJson(Map<String, dynamic> json) {
    return DetailSetorModel(
      kategoriSampahId: json['kategoriSampahId'],
      namaKategori: json['kategori'] ??
          (json['kategoriSampah'] != null
              ? json['kategoriSampah']['namaKategori']
              : null),
      jenis: json['jenis'] ??
          (json['kategoriSampah'] != null ? json['kategoriSampah']['jenis'] : null),
      beratKg: json['beratKg'] ?? 0,
      poinPerKg: json['poinPerKg'],
      subtotalPoin: json['subtotalPoin'] ?? 0,
    );
  }
}

class SetorSampahModel {
  final String id;
  final String? kodeSetor;
  final String tanggal;
  final String? createdAt;
  final String status;
  final num totalBeratKg;
  final num? totalPoin;
  final num? estimasiTotalPoin;
  final String? catatan;
  final String? catatanAdmin;
  final String? namaNasabah;
  final String? telpNasabah;
  final List<DetailSetorModel> detailSetors;

  SetorSampahModel({
    required this.id,
    this.kodeSetor,
    required this.tanggal,
    this.createdAt,
    required this.status,
    required this.totalBeratKg,
    this.totalPoin,
    this.estimasiTotalPoin,
    this.catatan,
    this.catatanAdmin,
    this.namaNasabah,
    this.telpNasabah,
    this.detailSetors = const [],
  });

  /// Nama/jenis sampah yang diajukan (misal: 'Kertas', 'Logam', 'Plastik, Kaca')
  String get namaSampahDisplay {
    if (detailSetors.isNotEmpty) {
      final names = detailSetors
          .map((d) => d.namaKategori ?? d.jenis)
          .where((n) => n != null && n.toString().trim().isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      if (names.isNotEmpty) {
        return names.join(', ');
      }
    }
    return kodeSetor ?? 'Setor Sampah';
  }

  factory SetorSampahModel.fromJson(Map<String, dynamic> json) {
    return SetorSampahModel(
      id: json['id'] ?? '',
      kodeSetor: json['kodeSetor'],
      tanggal: json['tanggal'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? json['tanggal'],
      status: json['status'] ?? '',
      totalBeratKg: json['totalBeratKg'] ?? 0,
      totalPoin: json['totalPoin'],
      estimasiTotalPoin: json['estimasiTotalPoin'],
      catatan: json['catatan'],
      catatanAdmin: json['catatanAdmin'],
      namaNasabah: json['nasabah'] != null ? json['nasabah']['namaNasabah'] : null,
      telpNasabah: json['nasabah'] != null ? json['nasabah']['telp'] : null,
      detailSetors: (json['detailSetors'] as List<dynamic>? ?? [])
          .map((e) => DetailSetorModel.fromJson(e))
          .toList(),
    );
  }
}

/// Item untuk request pengajuan setor (ItemSetorDto)
class ItemSetorInput {
  final String kategoriSampahId;
  final double beratKg;

  ItemSetorInput({required this.kategoriSampahId, required this.beratKg});

  Map<String, dynamic> toJson() => {
        'kategoriSampahId': kategoriSampahId,
        'beratKg': beratKg,
      };
}
