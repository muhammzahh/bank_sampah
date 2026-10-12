import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/setor_sampah_model.dart';

class SetorSampahService {
  /// Nasabah: ajukan penyetoran sampah (multi item)
  static Future<SetorSampahModel> ajukanSetor({
    required String tanggal, // ISO 8601
    required String catatan,
    required List<ItemSetorInput> items,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.setorPengajuan,
      withAuth: true,
      body: {
        'tanggal': tanggal,
        'catatan': catatan,
        'items': items.map((e) => e.toJson()).toList(),
      },
    );
    return SetorSampahModel.fromJson(res['data']);
  }

  /// Nasabah: histori setor milik sendiri
  static Future<List<SetorSampahModel>> getMySetor({String? bulan}) async {
    final res = await ApiClient.get(
      ApiConstants.setorMySetor,
      withAuth: true,
      query: bulan != null ? {'bulan': bulan} : null,
    );
    final list = res['data'] as List<dynamic>;
    return list.map((e) => SetorSampahModel.fromJson(e)).toList();
  }

  /// Admin: seluruh pengajuan setor
  static Future<List<SetorSampahModel>> getAdminList({
    String? status,
    String? bulan,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (bulan != null) query['bulan'] = bulan;

    final res = await ApiClient.get(
      ApiConstants.setorAdminList,
      withAuth: true,
      query: query,
    );
    final list = res['data'] as List<dynamic>;
    return list.map((e) => SetorSampahModel.fromJson(e)).toList();
  }

  /// Nasabah/Admin: detail transaksi / struk nota
  static Future<SetorSampahModel> getDetail(String id) async {
    final res = await ApiClient.get('${ApiConstants.setorDetail}/$id', withAuth: true);
    return SetorSampahModel.fromJson(res['data']);
  }

  /// Admin: verifikasi & finalisasi timbangan
  static Future<SetorSampahModel> verify({
    required String id,
    required String status, // diverifikasi | ditolak | selesai
    required String catatanAdmin,
    List<Map<String, dynamic>>? itemsReal,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      'catatanAdmin': catatanAdmin,
    };
    if (itemsReal != null) body['itemsReal'] = itemsReal;

    final res = await ApiClient.put(
      '${ApiConstants.setorAdminVerify}/$id',
      withAuth: true,
      body: body,
    );
    return SetorSampahModel.fromJson(res['data']);
  }
}
