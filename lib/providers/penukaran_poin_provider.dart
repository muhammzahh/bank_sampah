import 'package:flutter/material.dart';
import '../models/penukaran_poin_model.dart';
import '../services/penukaran_poin_service.dart';

class PenukaranPoinProvider extends ChangeNotifier {
  List<PenukaranPoinModel> myPenukaranList = [];
  List<PenukaranPoinModel> adminPenukaranList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<PenukaranPoinModel?> tukar(String hadiahId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await PenukaranPoinService.tukar(hadiahId: hadiahId);
      myPenukaranList = await PenukaranPoinService.getMyPenukaran();
      isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchMyPenukaran() async {
    isLoading = true;
    notifyListeners();
    try {
      myPenukaranList = await PenukaranPoinService.getMyPenukaran();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminList({String? bulan}) async {
    isLoading = true;
    notifyListeners();
    try {
      adminPenukaranList = await PenukaranPoinService.getAdminList(bulan: bulan);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({required String id, required String status}) async {
    try {
      await PenukaranPoinService.updateStatus(id: id, status: status);
      await fetchAdminList();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
