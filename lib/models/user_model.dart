import 'nasabah_model.dart';
import 'admin_bank_model.dart';

export 'nasabah_model.dart';
export 'admin_bank_model.dart';

class UserModel {
  final String id;
  final String username;
  final String role; // 'NASABAH' atau 'ADMIN'
  final String? token;
  final NasabahModel? nasabah;
  final AdminBankModel? adminBank;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    this.token,
    this.nasabah,
    this.adminBank,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      token: json['token'],
      nasabah:
          json['nasabah'] != null ? NasabahModel.fromJson(json['nasabah']) : null,
      adminBank: json['adminBank'] != null
          ? AdminBankModel.fromJson(json['adminBank'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? role,
    String? token,
    NasabahModel? nasabah,
    AdminBankModel? adminBank,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      nasabah: nasabah ?? this.nasabah,
      adminBank: adminBank ?? this.adminBank,
    );
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isNasabah => role == 'NASABAH';
}
