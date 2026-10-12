import 'dart:io';
import 'package:flutter/material.dart';
import '../models/hadiah_model.dart';
import '../services/hadiah_service.dart';

class HadiahProvider extends ChangeNotifier {
  List<HadiahModel> hadiahList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();
    try {
      hadiahList = await HadiahService.getAll();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String namaHadiah,
    required num poinDibutuhkan,
    required num stok,
    File? foto,
  }) async {
    try {
      await HadiahService.create(
        namaHadiah: namaHadiah,
        poinDibutuhkan: poinDibutuhkan,
        stok: stok,
        foto: foto,
      );
      await fetchAll();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String namaHadiah,
    required num poinDibutuhkan,
    required num stok,
    File? foto,
  }) async {
    try {
      await HadiahService.update(
        id: id,
        namaHadiah: namaHadiah,
        poinDibutuhkan: poinDibutuhkan,
        stok: stok,
        foto: foto,
      );
      await fetchAll();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await HadiahService.delete(id);
      hadiahList.removeWhere((h) => h.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Foreign key') ||
          msg.contains('hadiahId') ||
          msg.contains('prisma') ||
          msg.contains('constraint')) {
        errorMessage = 'Hadiah tidak dapat dihapus karena sudah memiliki riwayat penukaran oleh nasabah.';
      } else {
        errorMessage = msg;
      }
      notifyListeners();
      return false;
    }
  }
}
