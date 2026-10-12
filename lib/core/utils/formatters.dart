import 'package:intl/intl.dart';

class Formatters {
  static String rupiah(num value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static String tanggalIndo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String tanggalSingkat(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// Mengembalikan string "Januari 2026" untuk header filter
  static String bulanTahun(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  /// Label tampilan "Januari 2026" untuk display di UI
  static String bulanTahunLabel(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'diverifikasi':
        return 'Diverifikasi';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'diproses':
        return 'Diproses';
      default:
        return status;
    }
  }
}
