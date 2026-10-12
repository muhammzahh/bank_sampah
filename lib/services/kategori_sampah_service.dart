import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/kategori_sampah_model.dart';

class KategoriSampahService {
  static Future<List<KategoriSampahModel>> getAll() async {
    final res = await ApiClient.get(ApiConstants.kategoriSampah, withAuth: true);
    final list = res['data'] as List<dynamic>;
    return list.map((e) => KategoriSampahModel.fromJson(e)).toList();
  }

  static Future<KategoriSampahModel> getDetail(String id) async {
    final res = await ApiClient.get('${ApiConstants.kategoriSampah}/$id', withAuth: true);
    return KategoriSampahModel.fromJson(res['data']);
  }

  static Future<KategoriSampahModel> create({
    required String namaKategori,
    required num hargaPerKg,
    required num poinPerKg,
    required String jenis,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      ApiConstants.kategoriSampah,
      method: 'POST',
      withAuth: true,
      fields: {
        'namaKategori': namaKategori,
        'hargaPerKg': hargaPerKg.toString(),
        'poinPerKg': poinPerKg.toString(),
        'jenis': jenis,
      },
      file: foto,
    );
    return KategoriSampahModel.fromJson(res['data']);
  }

  static Future<KategoriSampahModel> update({
    required String id,
    required String namaKategori,
    required num hargaPerKg,
    required num poinPerKg,
    required String jenis,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      '${ApiConstants.kategoriSampah}/$id',
      method: 'PUT',
      withAuth: true,
      fields: {
        'namaKategori': namaKategori,
        'hargaPerKg': hargaPerKg.toString(),
        'poinPerKg': poinPerKg.toString(),
        'jenis': jenis,
      },
      file: foto,
    );
    return KategoriSampahModel.fromJson(res['data']);
  }

  static Future<void> delete(String id) async {
    await ApiClient.delete('${ApiConstants.kategoriSampah}/$id', withAuth: true);
  }
}
