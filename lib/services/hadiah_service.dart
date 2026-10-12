import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/hadiah_model.dart';

class HadiahService {
  static Future<List<HadiahModel>> getAll() async {
    final res = await ApiClient.get(ApiConstants.hadiah, withAuth: true);
    final list = res['data'] as List<dynamic>;
    return list.map((e) => HadiahModel.fromJson(e)).toList();
  }

  static Future<HadiahModel> getDetail(String id) async {
    final res = await ApiClient.get('${ApiConstants.hadiah}/$id', withAuth: true);
    return HadiahModel.fromJson(res['data']);
  }

  static Future<HadiahModel> create({
    required String namaHadiah,
    required num poinDibutuhkan,
    required num stok,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      ApiConstants.hadiah,
      method: 'POST',
      withAuth: true,
      fields: {
        'namaHadiah': namaHadiah,
        'poinDibutuhkan': poinDibutuhkan.toString(),
        'stok': stok.toString(),
      },
      file: foto,
    );
    return HadiahModel.fromJson(res['data']);
  }

  static Future<HadiahModel> update({
    required String id,
    required String namaHadiah,
    required num poinDibutuhkan,
    required num stok,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      '${ApiConstants.hadiah}/$id',
      method: 'PUT',
      withAuth: true,
      fields: {
        'namaHadiah': namaHadiah,
        'poinDibutuhkan': poinDibutuhkan.toString(),
        'stok': stok.toString(),
      },
      file: foto,
    );
    return HadiahModel.fromJson(res['data']);
  }

  static Future<void> delete(String id) async {
    await ApiClient.delete('${ApiConstants.hadiah}/$id', withAuth: true);
  }
}
