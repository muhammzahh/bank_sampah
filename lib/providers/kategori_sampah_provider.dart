import 'dart:io';
import 'package:flutter/material.dart';
import '../models/kategori_sampah_model.dart';
import '../services/kategori_sampah_service.dart';

class KategoriSampahProvider extends ChangeNotifier {
  List<KategoriSampahModel> kategoriList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      kategoriList = await KategoriSampahService.getAll();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String namaKategori,
    required num hargaPerKg,
    required num poinPerKg,
    required String jenis,
    File? foto,
  }) async {
    try {
      await KategoriSampahService.create(
        namaKategori: namaKategori,
        hargaPerKg: hargaPerKg,
        poinPerKg: poinPerKg,
        jenis: jenis,
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
    required String namaKategori,
    required num hargaPerKg,
    required num poinPerKg,
    required String jenis,
    File? foto,
  }) async {
    try {
      await KategoriSampahService.update(
        id: id,
        namaKategori: namaKategori,
        hargaPerKg: hargaPerKg,
        poinPerKg: poinPerKg,
        jenis: jenis,
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
      await KategoriSampahService.delete(id);
      kategoriList.removeWhere((k) => k.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
