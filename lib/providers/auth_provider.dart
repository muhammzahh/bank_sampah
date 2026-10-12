import 'dart:io';
import 'package:flutter/material.dart';
import '../core/storage/local_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.initial;
  UserModel? currentUser;
  String? errorMessage;
  bool appMakerReady = false;

  /// Dipanggil sekali saat app start: pastikan appKey ada, cek sesi login.
  Future<void> initSession() async {
    final hasKey = await LocalStorage.hasAppKey();
    appMakerReady = hasKey;

    final isLoggedIn = await LocalStorage.isLoggedIn();
    if (isLoggedIn) {
      try {
        currentUser = await AuthService.getMe();
        await _applyLocalProfileOverrides();
        status = AuthStatus.authenticated;
      } catch (_) {
        await LocalStorage.clearSession();
        status = AuthStatus.unauthenticated;
      }
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _applyLocalProfileOverrides() async {
    if (currentUser == null) return;
    final userId = currentUser!.id;

    final photoPath = await LocalStorage.getProfilePhotoPath(userId);
    if (currentUser!.isNasabah && currentUser!.nasabah != null) {
      final savedNama = await LocalStorage.getLocalProfileData(userId, 'namaNasabah');
      final savedAlamat = await LocalStorage.getLocalProfileData(userId, 'alamat');
      final savedTelp = await LocalStorage.getLocalProfileData(userId, 'telp');

      currentUser = currentUser!.copyWith(
        nasabah: currentUser!.nasabah!.copyWith(
          namaNasabah: savedNama ?? currentUser!.nasabah!.namaNasabah,
          alamat: savedAlamat ?? currentUser!.nasabah!.alamat,
          telp: savedTelp ?? currentUser!.nasabah!.telp,
          foto: photoPath ?? currentUser!.nasabah!.foto,
        ),
      );
    } else if (currentUser!.isAdmin && currentUser!.adminBank != null) {
      final savedUnit = await LocalStorage.getLocalProfileData(userId, 'namaUnit');
      final savedPengelola = await LocalStorage.getLocalProfileData(userId, 'namaPengelola');
      final savedTelp = await LocalStorage.getLocalProfileData(userId, 'telp');

      currentUser = currentUser!.copyWith(
        adminBank: currentUser!.adminBank!.copyWith(
          namaUnit: savedUnit ?? currentUser!.adminBank!.namaUnit,
          namaPengelola: savedPengelola ?? currentUser!.adminBank!.namaPengelola,
          telp: savedTelp ?? currentUser!.adminBank!.telp,
          foto: photoPath ?? currentUser!.adminBank!.foto,
        ),
      );
    }
  }

  /// Setup App Maker
  Future<bool> setupAppMaker({
    required String email,
    required String password,
    required String namaSiswa,
    required String kelas,
    required String namaApp,
  }) async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      final data = await AuthService.registerAppMaker(
        email: email,
        password: password,
        namaSiswa: namaSiswa,
        kelas: kelas,
        namaApp: namaApp,
      );
      await LocalStorage.saveAppKey(data['appKey']);
      appMakerReady = true;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Login App Maker
  Future<bool> loginAppMaker({
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      final data = await AuthService.loginAppMaker(
        email: email,
        password: password,
      );
      await LocalStorage.saveAppKey(data['appKey']);
      appMakerReady = true;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerNasabah({
    required String username,
    required String password,
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? foto,
  }) async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      await AuthService.registerNasabah(
        username: username,
        password: password,
        namaNasabah: namaNasabah,
        alamat: alamat,
        telp: telp,
        foto: foto,
      );
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAdminBank({
    required String username,
    required String password,
    required String namaUnit,
    required String namaPengelola,
    required String telp,
  }) async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      await AuthService.registerAdminBank(
        username: username,
        password: password,
        namaUnit: namaUnit,
        namaPengelola: namaPengelola,
        telp: telp,
      );
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String username, required String password}) async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      final user = await AuthService.login(username: username, password: password);
      await LocalStorage.saveToken(user.token ?? '');
      await LocalStorage.saveRole(user.role);
      await LocalStorage.saveUserInfo(
        userId: user.id,
        userName: user.nasabah?.namaNasabah ?? user.adminBank?.namaUnit ?? user.username,
        nasabahId: user.nasabah?.id,
        adminBankId: user.adminBank?.id,
      );
      currentUser = user;
      await _applyLocalProfileOverrides();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      currentUser = await AuthService.getMe();
      await _applyLocalProfileOverrides();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateNasabahProfile({
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? fotoFile,
  }) async {
    if (currentUser == null || currentUser!.nasabah == null) return false;
    final userId = currentUser!.id;
    try {
      String? photoPath = currentUser!.nasabah!.foto;
      if (fotoFile != null) {
        photoPath = fotoFile.path;
        await LocalStorage.saveProfilePhotoPath(userId, photoPath);
      }

      await LocalStorage.saveLocalProfileData(userId, {
        'namaNasabah': namaNasabah,
        'alamat': alamat,
        'telp': telp,
      });

      currentUser = currentUser!.copyWith(
        nasabah: currentUser!.nasabah!.copyWith(
          namaNasabah: namaNasabah,
          alamat: alamat,
          telp: telp,
          foto: photoPath,
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAdminProfile({
    required String namaUnit,
    required String namaPengelola,
    required String telp,
    File? fotoFile,
  }) async {
    if (currentUser == null || currentUser!.adminBank == null) return false;
    final userId = currentUser!.id;
    try {
      String? photoPath = currentUser!.adminBank!.foto;
      if (fotoFile != null) {
        photoPath = fotoFile.path;
        await LocalStorage.saveProfilePhotoPath(userId, photoPath);
      }

      await LocalStorage.saveLocalProfileData(userId, {
        'namaUnit': namaUnit,
        'namaPengelola': namaPengelola,
        'telp': telp,
      });

      currentUser = currentUser!.copyWith(
        adminBank: currentUser!.adminBank!.copyWith(
          namaUnit: namaUnit,
          namaPengelola: namaPengelola,
          telp: telp,
          foto: photoPath,
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearSession();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
