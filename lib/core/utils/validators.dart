/// Kumpulan fungsi validasi untuk dipakai di TextFormField(validator: ...)
class Validators {
  static String? required(String? value, {String field = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < minLength) return 'Password minimal $minLength karakter';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'No. telepon wajib diisi';
    final regex = RegExp(r'^[0-9+\-\s]{8,15}$');
    if (!regex.hasMatch(value.trim())) return 'Nomor telepon tidak valid';
    return null;
  }

  static String? number(String? value, {String field = 'Nilai'}) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    if (num.tryParse(value.trim()) == null) return '$field harus berupa angka';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Nilai'}) {
    final base = number(value, field: field);
    if (base != null) return base;
    final n = num.parse(value!.trim());
    if (n <= 0) return '$field harus lebih besar dari 0';
    return null;
  }

  static String? minLength(String? value, int length, {String field = 'Field ini'}) {
    if (value == null || value.length < length) {
      return '$field minimal $length karakter';
    }
    return null;
  }
}
