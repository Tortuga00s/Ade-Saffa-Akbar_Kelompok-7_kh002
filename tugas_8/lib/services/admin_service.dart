import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin.dart';
import '../practicum_ids.dart';

class AdminService {
  static const _storageKey = 'admins_json';

  static List<dynamic> _read(SharedPreferences prefs) {
    final stored = prefs.getString(_storageKey);
    if (stored != null) return jsonDecode(stored) as List<dynamic>;

    return [
      {
        'id': adminIdFromNim,
        'name': 'Rani Putri',
        'email': 'rani@example.com',
        'department': 'Teknologi Informasi',
      },
      {
        'id': adminIdFromNim + 1,
        'name': 'Dimas Pratama',
        'email': 'dimas@example.com',
        'department': 'Operasional',
      },
    ];
  }

  static Future<List<Admin>> getAdmins() async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs)
        .map((json) => Admin.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  static Future<Admin> getAdmin(int id) async {
    for (final admin in await getAdmins()) {
      if (admin.id == id) return admin;
    }
    throw StateError('Admin dengan ID $id tidak ditemukan.');
  }

  static Future<bool> deleteAdmin(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = _read(prefs);
    final index = data.indexWhere((admin) => admin['id'] == id);
    if (index == -1) return false;

    data.removeAt(index);
    if (!await prefs.setString(_storageKey, jsonEncode(data))) {
      throw StateError('Perubahan data Admin gagal disimpan.');
    }
    return true;
  }
}
