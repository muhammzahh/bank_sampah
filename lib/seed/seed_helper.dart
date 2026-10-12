// seed_helper.dart
// Placeholder file — actual seed logic is handled server-side via DashboardService.generateSeed()
// This file was previously a misplaced copy of RegisterAdminScreen.

import '../services/dashboard_service.dart';

/// Helper untuk generate data seed / dummy via API.
class SeedHelper {
  /// Panggil endpoint seed untuk membuat data contoh di server.
  static Future<Map<String, dynamic>> generateSeed() async {
    return await DashboardService.generateSeed();
  }
}
