import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/nasabah_model.dart';

class AdminNasabahService {
  /// Ambil semua nasabah (admin only)
  static Future<List<NasabahModel>> getAll() async {
    final res = await ApiClient.get(ApiConstants.adminNasabah, withAuth: true);
    final list = res['data'] as List<dynamic>;
    return list.map((e) => NasabahModel.fromJson(e)).toList();
  }

  /// Detail satu nasabah
  static Future<NasabahModel> getDetail(String id) async {
    final res = await ApiClient.get('${ApiConstants.adminNasabah}/$id', withAuth: true);
    return NasabahModel.fromJson(res['data']);
  }

  /// Admin buat akun nasabah baru
  static Future<NasabahModel> create({
    required String username,
    required String password,
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      ApiConstants.adminNasabah,
      method: 'POST',
      withAuth: true,
      fields: {
        'username': username,
        'password': password,
        'namaNasabah': namaNasabah,
        'alamat': alamat,
        'telp': telp,
      },
      file: foto,
    );
    return NasabahModel.fromJson(res['data']['nasabah'] ?? res['data']);
  }

  /// Admin edit data nasabah
  static Future<NasabahModel> update({
    required String id,
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      '${ApiConstants.adminNasabah}/$id',
      method: 'PUT',
      withAuth: true,
      fields: {
        'namaNasabah': namaNasabah,
        'alamat': alamat,
        'telp': telp,
      },
      file: foto,
    );
    return NasabahModel.fromJson(res['data']);
  }

  /// Admin hapus nasabah
  static Future<void> delete(String id) async {
    await ApiClient.delete('${ApiConstants.adminNasabah}/$id', withAuth: true);
  }
}
