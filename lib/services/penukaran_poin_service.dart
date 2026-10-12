import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/penukaran_poin_model.dart';

class PenukaranPoinService {
  /// Nasabah: tukar poin dengan hadiah
  static Future<PenukaranPoinModel> tukar({required String hadiahId}) async {
    final res = await ApiClient.post(
      ApiConstants.penukaranTukar,
      withAuth: true,
      body: {'hadiahId': hadiahId},
    );
    return PenukaranPoinModel.fromJson(res['data']);
  }

  /// Nasabah: histori penukaran milik sendiri
  static Future<List<PenukaranPoinModel>> getMyPenukaran() async {
    final res = await ApiClient.get(ApiConstants.penukaranMyPenukaran, withAuth: true);
    final list = res['data'] as List<dynamic>;
    return list.map((e) => PenukaranPoinModel.fromJson(e)).toList();
  }

  /// Admin: semua transaksi penukaran, filter opsional bulan
  static Future<List<PenukaranPoinModel>> getAdminList({String? bulan}) async {
    final res = await ApiClient.get(
      ApiConstants.penukaranAdminList,
      withAuth: true,
      query: bulan != null ? {'bulan': bulan} : null,
    );
    final list = res['data'] as List<dynamic>;
    return list.map((e) => PenukaranPoinModel.fromJson(e)).toList();
  }

  /// Admin: update status penukaran (diproses / selesai)
  static Future<PenukaranPoinModel> updateStatus({
    required String id,
    required String status,
  }) async {
    final res = await ApiClient.put(
      '${ApiConstants.penukaranAdminStatus}/$id',
      withAuth: true,
      body: {'status': status},
    );
    return PenukaranPoinModel.fromJson(res['data']);
  }

  /// Nasabah/Admin: nota / struk bukti transaksi penukaran
  static Future<PenukaranPoinModel> getNota(String id) async {
    final res = await ApiClient.get('${ApiConstants.penukaranNota}/$id', withAuth: true);
    return PenukaranPoinModel.fromJson(res['data']);
  }
}
