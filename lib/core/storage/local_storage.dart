import 'package:shared_preferences/shared_preferences.dart';

/// Helper untuk menyimpan data sesi secara lokal:
/// appKey (multi-tenant), token JWT, dan role user yang sedang login.
class LocalStorage {
  static const _keyAppKey = 'app_key';
  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyNasabahId = 'nasabah_id';
  static const _keyAdminBankId = 'admin_bank_id';
  static const _keyProfilePhotoPrefix = 'profile_photo_';
  static const _keyProfileDataPrefix = 'profile_data_';

  // ---- App Key ----
  static Future<void> saveAppKey(String appKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppKey, appKey);
  }

  static Future<String?> getAppKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppKey);
  }

  // ---- Token ----
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ---- Role ----
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // ---- User Id / Name ----
  static Future<void> saveUserInfo({
    required String userId,
    required String userName,
    String? nasabahId,
    String? adminBankId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    if (nasabahId != null) await prefs.setString(_keyNasabahId, nasabahId);
    if (adminBankId != null) await prefs.setString(_keyAdminBankId, adminBankId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getNasabahId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNasabahId);
  }

  // ---- Profile Photo & Local Profile Overrides ----
  static Future<void> saveProfilePhotoPath(String userId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyProfilePhotoPrefix$userId', path);
  }

  static Future<String?> getProfilePhotoPath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyProfilePhotoPrefix$userId');
  }

  static Future<void> saveLocalProfileData(String userId, Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in data.entries) {
      await prefs.setString('$_keyProfileDataPrefix${userId}_${entry.key}', entry.value);
    }
  }

  static Future<String?> getLocalProfileData(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyProfileDataPrefix${userId}_$key');
  }

  // ---- Session check ----
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> hasAppKey() async {
    final key = await getAppKey();
    return key != null && key.isNotEmpty;
  }

  // ---- Clear session (logout) ----
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyNasabahId);
    await prefs.remove(_keyAdminBankId);
    // appKey TIDAK dihapus supaya tidak perlu register App Maker ulang
  }

  // ---- Read / Dismissed Notifications ----
  static const _keyReadNotifsPrefix = 'read_notif_ids_';

  static Future<void> markNotificationRead(String userId, String notifId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyReadNotifsPrefix$userId';
    final list = prefs.getStringList(key) ?? [];
    if (!list.contains(notifId)) {
      list.add(notifId);
      await prefs.setStringList(key, list);
    }
  }

  static Future<List<String>> getReadNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyReadNotifsPrefix$userId';
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> clearReadNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyReadNotifsPrefix$userId');
  }
}
