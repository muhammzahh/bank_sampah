import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/rekapitulasi_model.dart';
import '../services/admin_nasabah_service.dart';
import '../services/dashboard_service.dart';

class AdminProvider extends ChangeNotifier {
  List<NasabahModel> nasabahList = [];
  DashboardStatsModel? stats;
  RekapitulasiModel? rekap;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchNasabahList() async {
    isLoading = true;
    notifyListeners();
    try {
      nasabahList = await AdminNasabahService.getAll();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNasabah({
    required String username,
    required String password,
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? foto,
  }) async {
    try {
      await AdminNasabahService.create(
        username: username,
        password: password,
        namaNasabah: namaNasabah,
        alamat: alamat,
        telp: telp,
        foto: foto,
      );
      await fetchNasabahList();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNasabah({
    required String id,
    required String namaNasabah,
    required String alamat,
    required String telp,
    File? foto,
  }) async {
    try {
      await AdminNasabahService.update(
        id: id,
        namaNasabah: namaNasabah,
        alamat: alamat,
        telp: telp,
        foto: foto,
      );
      await fetchNasabahList();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNasabah(String id) async {
    try {
      await AdminNasabahService.delete(id);
      nasabahList.removeWhere((n) => n.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchStats() async {
    try {
      stats = await DashboardService.getAdminStats();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> fetchRekap(String bulan) async {
    isLoading = true;
    notifyListeners();
    try {
      rekap = await DashboardService.getRekapitulasiBulanan(bulan);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
