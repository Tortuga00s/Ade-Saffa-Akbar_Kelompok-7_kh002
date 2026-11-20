import 'package:flutter/material.dart';

import '../models/admin.dart';
import '../practicum_ids.dart';
import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Admin>> _admins = AdminService.getAdmins();
  late final _id = TextEditingController(text: '$adminIdFromNim');
  String? _status;
  bool _busy = false;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  int? _readId() {
    final id = int.tryParse(_id.text.trim());
    if (id == null || id <= 0) {
      setState(() => _status = 'Masukkan ID Admin yang valid.');
      return null;
    }
    return id;
  }

  Future<void> _showDetail(int id) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final admin = await AdminService.getAdmin(id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Detail Admin #${admin.id}'),
          content: Text(
            '${admin.name}\n${admin.email}\nDepartemen: ${admin.department}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _status = 'GET gagal. $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final id = _readId();
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Admin #$id?'),
        content: const Text('Data ini akan dihapus dari daftar Admin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _busy = true);
    try {
      final deleted = await AdminService.deleteAdmin(id);
      if (!mounted) return;
      setState(() {
        _status = deleted
            ? 'DELETE berhasil. Admin #$id sudah dihapus.'
            : 'DELETE gagal. Admin #$id tidak ditemukan.';
        _admins = AdminService.getAdmins();
      });
    } catch (error) {
      if (mounted) setState(() => _status = 'DELETE gagal. $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Admin')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _id,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID Admin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: _busy
                        ? null
                        : () {
                            final id = _readId();
                            if (id != null) _showDetail(id);
                          },
                    child: const Text('Cari Admin'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus Admin'),
                  ),
                ],
              ),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Semantics(liveRegion: true, child: Text(_status!)),
                ),
              const SizedBox(height: 24),
              FutureBuilder<List<Admin>>(
                future: _admins,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Daftar Admin gagal dimuat. ${snapshot.error}');
                  }
                  final admins = snapshot.data!;
                  if (admins.isEmpty) return const Text('Daftar Admin kosong.');
                  return Column(
                    children: [
                      for (final admin in admins)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                            title: Text(admin.name),
                            subtitle: Text(
                              '#${admin.id} · ${admin.department}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _busy ? null : () => _showDetail(admin.id),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
