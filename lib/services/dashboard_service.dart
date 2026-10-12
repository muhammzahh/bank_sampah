import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/rekapitulasi_model.dart';

class DashboardService {
  static Future<DashboardSummaryModel> getNasabahSummary() async {
    final res = await ApiClient.get(ApiConstants.dashboardSummary, withAuth: true);
    return DashboardSummaryModel.fromJson(res['data']);
  }

  static Future<DashboardStatsModel> getAdminStats() async {
    final res = await ApiClient.get(ApiConstants.dashboardStats, withAuth: true);
    return DashboardStatsModel.fromJson(res['data']);
  }

  static Future<RekapitulasiModel> getRekapitulasiBulanan(String bulan) async {
    final res = await ApiClient.get(
      ApiConstants.rekapitulasiBulanan,
      withAuth: true,
      query: {'bulan': bulan},
    );
    return RekapitulasiModel.fromJson(res['data']);
  }

  /// Utility: generate seed data dummy untuk testing awal
  static Future<Map<String, dynamic>> generateSeed() async {
    final res = await ApiClient.post(ApiConstants.seed, withAuth: true);
    return res['data'] ?? {};
  }
}
