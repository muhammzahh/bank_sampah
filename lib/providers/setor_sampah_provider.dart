import 'package:flutter/material.dart';
import '../models/setor_sampah_model.dart';
import '../services/setor_sampah_service.dart';

class SetorSampahProvider extends ChangeNotifier {
  List<SetorSampahModel> mySetorList = [];
  List<SetorSampahModel> adminSetorList = [];
  bool isLoading = false;
  String? errorMessage;

  // ---- Keranjang sementara untuk form ajukan setor ----
  final List<ItemSetorInput> cartItems = [];

  void addToCart(ItemSetorInput item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  Future<bool> ajukanSetor({required String tanggal, required String catatan}) async {
    if (cartItems.isEmpty) {
      errorMessage = 'Pilih minimal satu jenis sampah terlebih dahulu';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      await SetorSampahService.ajukanSetor(
        tanggal: tanggal,
        catatan: catatan,
        items: cartItems,
      );
      clearCart();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMySetor({String? bulan}) async {
    isLoading = true;
    notifyListeners();
    try {
      mySetorList = await SetorSampahService.getMySetor(bulan: bulan);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminList({String? status, String? bulan}) async {
    isLoading = true;
    notifyListeners();
    try {
      adminSetorList = await SetorSampahService.getAdminList(status: status, bulan: bulan);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verify({
    required String id,
    required String status,
    required String catatanAdmin,
    List<Map<String, dynamic>>? itemsReal,
    String? currentFilterStatus,
  }) async {
    try {
      await SetorSampahService.verify(
        id: id,
        status: status,
        catatanAdmin: catatanAdmin,
        itemsReal: itemsReal,
      );
      await fetchAdminList(status: currentFilterStatus ?? 'menunggu_konfirmasi');
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
