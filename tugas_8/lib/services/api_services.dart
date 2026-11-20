import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String fileName = 'users.json';
  static const String webStorageKey = 'users_json';

  // Mendapatkan path lengkap lokasi penyimpanan data (File di HP/PC, atau LocalStorage di Web)
  static Future<String> getJsonFilePath() async {
    if (kIsWeb) {
      return 'Browser LocalStorage (Web Chrome)\nKey: "$webStorageKey"';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // Mendapatkan objek File untuk platform non-web (Android, iOS, Desktop)
  static Future<io.File?> _getLocalFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$fileName');
  }

  // Inisialisasi data awal (dari JSONPlaceholder atau fallback jika offline)
  static Future<List<dynamic>> _fetchInitialData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded;
        }
      }
    } catch (_) {
      // Abaikan error jaringan/CORS di web dan gunakan fallback
    }
    return _defaultUsers;
  }

  // Membaca data JSON (kompatibel Web & Mobile)
  static Future<List<dynamic>> _readJsonData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Jika di Web
    if (kIsWeb) {
      final cachedJson = prefs.getString(webStorageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          return jsonDecode(cachedJson) as List<dynamic>;
        } catch (_) {}
      }

      // Inisialisasi awal di Web
      final initialUsers = await _fetchInitialData();
      await prefs.setString(webStorageKey, jsonEncode(initialUsers));
      return initialUsers;
    }

    // 2. Jika di HP (Android/iOS) atau Desktop
    try {
      final file = await _getLocalFile();
      if (file != null && await file.exists()) {
        final contents = await file.readAsString();
        if (contents.trim().isNotEmpty) {
          return jsonDecode(contents) as List<dynamic>;
        }
      }

      // Jika file belum ada di HP, buat file baru
      final initialUsers = await _fetchInitialData();
      if (file != null) {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(initialUsers),
        );
      }
      return initialUsers;
    } catch (_) {
      // Fallback cadangan via SharedPreferences jika ada kendala filesystem
      final cachedJson = prefs.getString(webStorageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return jsonDecode(cachedJson) as List<dynamic>;
      }
      return _defaultUsers;
    }
  }

  // Menyimpan seluruh data JSON (kompatibel Web & Mobile)
  static Future<void> _writeJsonData(List<dynamic> users) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(users);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webStorageKey, jsonString);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null) {
          await file.writeAsString(jsonString);
        }
      } catch (e) {
        debugPrint('Gagal menulis file lokal: $e');
      }
    }
  }

  // GET: Mengambil semua pengguna
  static Future<List<dynamic>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return await _readJsonData();
  }

  // GET: Mengambil detail pengguna berdasarkan ID
  static Future<Map<String, dynamic>> getUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final users = await _readJsonData();

    final user = users.firstWhere(
      (element) => element['id'] == id,
      orElse: () => null,
    );

    if (user != null) {
      return Map<String, dynamic>.from(user);
    }

    throw Exception('Data pengguna dengan ID $id tidak ditemukan');
  }

  // POST: Menambahkan pengguna baru
  static Future<Map<String, dynamic>> createUser(
    String name,
    String email,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonData();

    // Hitung ID baru
    int newId = 1;
    if (users.isNotEmpty) {
      final existingIds = users
          .map<int>((u) => (u['id'] is int
              ? u['id'] as int
              : int.tryParse(u['id'].toString()) ?? 0))
          .toList();
      existingIds.sort();
      newId = existingIds.last + 1;
    }

    final newUser = {
      'id': newId,
      'name': name,
      'email': email,
      'address': {
        'city': 'Indonesia',
      },
    };

    users.add(newUser);
    await _writeJsonData(users);

    return newUser;
  }

  // PUT: Memperbarui seluruh data pengguna
  static Future<Map<String, dynamic>> updateUser(
    int id,
    String name,
    String email,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonData();

    final index = users.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      throw Exception('Gagal memperbarui pengguna: ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    existing['name'] = name;
    existing['email'] = email;

    users[index] = existing;
    await _writeJsonData(users);

    return existing;
  }

  // PATCH: Memperbarui nama pengguna
  static Future<Map<String, dynamic>> patchUser(
    int id,
    String name,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonData();

    final index = users.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      throw Exception('Gagal mengubah nama pengguna: ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    existing['name'] = name;

    users[index] = existing;
    await _writeJsonData(users);

    return existing;
  }

  // DELETE: Menghapus pengguna
  static Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await _readJsonData();

    final index = users.indexWhere((element) => element['id'] == id);

    if (index == -1) {
      return false;
    }

    users.removeAt(index);
    await _writeJsonData(users);

    return true;
  }

  // Reset data ke default awal
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(webStorageKey);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null && await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    // Tulis ulang data default
    await _writeJsonData(_defaultUsers);
  }

  // Data default cadangan jika offline / CORS browser
  static final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'address': {'city': 'Gwenborough'}
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'address': {'city': 'Wisokyburgh'}
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'address': {'city': 'McKenziehaven'}
    },
    {
      'id': 4,
      'name': 'Patricia Lebsack',
      'email': 'Julianne.OConner@kory.org',
      'address': {'city': 'South Elvis'}
    },
    {
      'id': 5,
      'name': 'Chelsey Dietrich',
      'email': 'Lucio_Hettinger@annie.ca',
      'address': {'city': 'Roscoeview'}
    },
    {
      'id': 6,
      'name': 'Mrs. Dennis Schulist',
      'email': 'Karley_Dach@jasper.info',
      'address': {'city': 'South Christy'}
    },
    {
      'id': 7,
      'name': 'Kurtis Weissnat',
      'email': 'Telly.Hoeger@billy.biz',
      'address': {'city': 'Howemouth'}
    },
    {
      'id': 8,
      'name': 'Nicholas Runolfsdottir V',
      'email': 'Sherwood@rosamond.me',
      'address': {'city': 'Aliyaview'}
    },
    {
      'id': 9,
      'name': 'Glenna Reichert',
      'email': 'Chaim_McDermott@dana.io',
      'address': {'city': 'Bartholomebury'}
    },
    {
      'id': 10,
      'name': 'Clementina DuBuque',
      'email': 'Rey.Padberg@karina.biz',
      'address': {'city': 'Lebsackbury'}
    },
  ];
}