class BreakdownJenisModel {
  final num tonaseKg;
  final num rupiah;
  final num poin;

  BreakdownJenisModel({required this.tonaseKg, required this.rupiah, required this.poin});

  factory BreakdownJenisModel.fromJson(Map<String, dynamic> json) {
    return BreakdownJenisModel(
      tonaseKg: json['tonaseKg'] ?? 0,
      rupiah: json['rupiah'] ?? 0,
      poin: json['poin'] ?? 0,
    );
  }
}

class RekapitulasiModel {
  final String periode;
  final num totalKg;
  final num totalTon;
  final num totalEstimasiPembayaranRupiah;
  final num totalPoinDiterbitkan;
  final Map<String, BreakdownJenisModel> breakdownJenisSampah;
  final num totalTransaksiPenukaran;
  final num totalPoinTerpakai;

  RekapitulasiModel({
    required this.periode,
    required this.totalKg,
    required this.totalTon,
    required this.totalEstimasiPembayaranRupiah,
    required this.totalPoinDiterbitkan,
    required this.breakdownJenisSampah,
    required this.totalTransaksiPenukaran,
    required this.totalPoinTerpakai,
  });

  factory RekapitulasiModel.fromJson(Map<String, dynamic> json) {
    final tonase = json['rekapitulasiTonase'] ?? {};
    final penukaran = json['rekapitulasiPenukaranPoin'] ?? {};
    final breakdownJson = json['breakdownJenisSampah'] as Map<String, dynamic>? ?? {};

    final breakdown = <String, BreakdownJenisModel>{};
    breakdownJson.forEach((key, value) {
      breakdown[key] = BreakdownJenisModel.fromJson(value);
    });

    return RekapitulasiModel(
      periode: json['periode'] ?? '',
      totalKg: tonase['totalKg'] ?? 0,
      totalTon: tonase['totalTon'] ?? 0,
      totalEstimasiPembayaranRupiah: tonase['totalEstimasiPembayaranRupiah'] ?? 0,
      totalPoinDiterbitkan: tonase['totalPoinDiterbitkan'] ?? 0,
      breakdownJenisSampah: breakdown,
      totalTransaksiPenukaran: penukaran['totalTransaksiPenukaran'] ?? 0,
      totalPoinTerpakai: penukaran['totalPoinTerpakai'] ?? 0,
    );
  }
}

class DashboardSummaryModel {
  final num saldoPoinSaatIni;
  final num totalSampahDisetorKg;
  final num totalPoinDidapat;
  final num totalPoinDitukar;
  final Map<String, dynamic>? transaksiTerakhirSetor;
  final Map<String, dynamic>? transaksiTerakhirTukar;

  DashboardSummaryModel({
    required this.saldoPoinSaatIni,
    required this.totalSampahDisetorKg,
    required this.totalPoinDidapat,
    required this.totalPoinDitukar,
    this.transaksiTerakhirSetor,
    this.transaksiTerakhirTukar,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      saldoPoinSaatIni: json['saldoPoinSaatIni'] ?? 0,
      totalSampahDisetorKg: json['totalSampahDisetorKg'] ?? 0,
      totalPoinDidapat: json['totalPoinDidapat'] ?? 0,
      totalPoinDitukar: json['totalPoinDitukar'] ?? 0,
      transaksiTerakhirSetor: json['transaksiTerakhirSetor'],
      transaksiTerakhirTukar: json['transaksiTerakhirTukar'],
    );
  }
}

class DashboardStatsModel {
  final num totalNasabah;
  final num totalKategoriSampah;
  final num totalTransaksiSetor;
  final num totalHadiah;
  final num? totalBeratSampahKg;
  final num? totalPoinTersalurkan;

  DashboardStatsModel({
    required this.totalNasabah,
    required this.totalKategoriSampah,
    required this.totalTransaksiSetor,
    required this.totalHadiah,
    this.totalBeratSampahKg,
    this.totalPoinTersalurkan,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalNasabah: json['totalNasabah'] ?? 0,
      totalKategoriSampah: json['totalKategoriSampah'] ?? 0,
      totalTransaksiSetor: json['totalTransaksiSetor'] ?? 0,
      totalHadiah: json['totalHadiah'] ?? 0,
      totalBeratSampahKg: json['totalBeratSampahKg'],
      totalPoinTersalurkan: json['totalPoinTersalurkan'],
    );
  }
}
