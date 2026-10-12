import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  // ---------- App Maker ----------
  static Future<Map<String, dynamic>> registerAppMaker({
    required String email,
    required String password,
    required String namaSiswa,
    required String kelas,
    required String namaApp,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.makerRegister,
      body: {
        'email': email,
        'password': password,
        'namaSiswa': namaSiswa,
        'kelas': kelas,
        'namaApp': namaApp,
      },
    );
    return res['data'];
  }

  static Future<Map<String, dynamic>> loginAppMaker({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.makerLogin,
      body: {'email': email, 'password': password},
    );
    return res['data'];
  }

  // ---------- Register Nasabah (mandiri) ----------
  static Future<NasabahModel> registerNasabah({
    required String username,
    required String password,
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? foto,
  }) async {
    final res = await ApiClient.multipart(
      ApiConstants.authNasabahRegister,
      method: 'POST',
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

  // ---------- Register Admin Bank ----------
  static Future<AdminBankModel> registerAdminBank({
    required String username,
    required String password,
    required String namaUnit,
    required String namaPengelola,
    required String telp,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.authAdminRegister,
      body: {
        'username': username,
        'password': password,
        'namaUnit': namaUnit,
        'namaPengelola': namaPengelola,
        'telp': telp,
      },
    );
    return AdminBankModel.fromJson(res['data']['adminBank'] ?? res['data']);
  }

  // ---------- Login (Nasabah / Admin) ----------
  static Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.authLogin,
      body: {'username': username, 'password': password},
    );
    return UserModel.fromJson(res['data']);
  }

  // ---------- Get Profile Me ----------
  static Future<UserModel> getMe() async {
    final res = await ApiClient.get(ApiConstants.authMe, withAuth: true);
    return UserModel.fromJson(res['data']);
  }
}
