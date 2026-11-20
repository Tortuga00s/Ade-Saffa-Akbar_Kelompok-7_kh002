import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

// Identitas mahasiswa hanya untuk menentukan aturan validasi.
// Data BARANG tetap berasal dari lima input pengguna.
const String namaMahasiswa = 'Ade Saffa Akbar';
const String nimMahasiswa = '20240801071';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AplikasiStokBarang());
}

class AplikasiStokBarang extends StatelessWidget {
  const AplikasiStokBarang({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatatan Stok Barang',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1766A3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD6DFEB)),
          ),
        ),
      ),
      home: const HalamanStokBarang(),
    );
  }
}

class HalamanStokBarang extends StatefulWidget {
  const HalamanStokBarang({super.key});

  @override
  State<HalamanStokBarang> createState() => _HalamanStokBarangState();
}

class _HalamanStokBarangState extends State<HalamanStokBarang> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tanggalMasukController = TextEditingController();
  final _tanggalKeluarController = TextEditingController();
  final _kodeController = TextEditingController();
  final _stokController = TextEditingController();

  DateTime? _tanggalMasuk;
  DateTime? _tanggalKeluar;
  bool _sedangMenyimpan = false;

  // NIM berakhir angka ganjil: kode barang harus desimal (double).
  // NIM berakhir angka genap: kode barang harus integer (int).
  bool get _nimGanjil => int.parse(nimMahasiswa.substring(nimMahasiswa.length - 1)).isOdd;

  String get _akhiranKode => _nimGanjil
      ? nimMahasiswa.substring(nimMahasiswa.length - 3)
      : nimMahasiswa.substring(nimMahasiswa.length - 2);

  String get _inisialNama => namaMahasiswa.trim().substring(0, 1).toUpperCase();

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalMasukController.dispose();
    _tanggalKeluarController.dispose();
    _kodeController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  String? _validasiNama(String? value) {
    final teks = (value ?? '').trim();
    if (teks.isEmpty) return 'Nama barang wajib diisi.';
    if (!teks.toUpperCase().startsWith(_inisialNama)) {
      return 'Nama barang harus diawali inisial $_inisialNama.';
    }
    return null;
  }

  String? _validasiTanggalMasuk(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Tanggal masuk wajib dipilih.';
    return null;
  }

  String? _validasiTanggalKeluar(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Tanggal keluar wajib dipilih.';
    if (_tanggalMasuk != null && _tanggalKeluar != null &&
        _tanggalKeluar!.isBefore(_tanggalMasuk!)) {
      return 'Tanggal keluar tidak boleh sebelum tanggal masuk.';
    }
    return null;
  }

  String? _validasiKode(String? value) {
    final teks = (value ?? '').trim().replaceAll(',', '.');
    if (teks.isEmpty) return 'Kode barang wajib diisi.';

    // Minimal enam angka pada bagian utuh. Untuk NIM ganjil harus
    // memiliki pecahan desimal; NIM genap harus bilangan bulat.
    final pola = _nimGanjil
        ? RegExp(r'^\d{6,}\.\d+$')
        : RegExp(r'^\d{6,}$');
    if (!pola.hasMatch(teks)) {
      return _nimGanjil
          ? 'Gunakan kode desimal; contoh: 123$_akhiranKode.5'
          : 'Gunakan minimal 6 digit bilangan bulat.';
    }

    final bagianBulat = teks.split('.').first;
    if (!bagianBulat.endsWith(_akhiranKode)) {
      return 'Bagian bulat kode harus berakhiran $_akhiranKode.';
    }

    if (_nimGanjil) {
      final kode = double.tryParse(teks);
      if (kode == null || !kode.isFinite) {
        return 'Kode barang harus berupa angka desimal yang valid.';
      }
    } else if (int.tryParse(teks) == null) {
      return 'Kode barang harus berupa integer yang valid.';
    }
    return null;
  }

  String? _validasiStok(String? value) {
    final teks = (value ?? '').trim();
    if (teks.isEmpty) return 'Jumlah stok wajib diisi.';
    final stok = int.tryParse(teks);
    if (stok == null) return 'Jumlah stok harus bilangan bulat.';
    if (stok < 0) return 'Jumlah stok tidak boleh negatif.';
    return null;
  }

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    return '$hari/$bulan/${tanggal.year}';
  }

  Future<void> _pilihTanggal({required bool masuk}) async {
    if (_sedangMenyimpan) return;
    final tanggalSekarang = masuk ? _tanggalMasuk : _tanggalKeluar;
    final pilihan = await showDatePicker(
      context: context,
      initialDate: tanggalSekarang ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: masuk ? 'PILIH TANGGAL MASUK' : 'PILIH TANGGAL KELUAR',
    );
    if (!mounted || pilihan == null) return;
    setState(() {
      if (masuk) {
        _tanggalMasuk = pilihan;
        _tanggalMasukController.text = _formatTanggal(pilihan);
      } else {
        _tanggalKeluar = pilihan;
        _tanggalKeluarController.text = _formatTanggal(pilihan);
      }
    });
  }

  void _pesan(String teks, {required bool berhasil}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(teks),
          backgroundColor: berhasil ? const Color(0xFF26734A) : Colors.red.shade700,
        ),
      );
  }

  Future<void> _simpanBarang() async {
    if (_sedangMenyimpan || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _sedangMenyimpan = true);

    try {
      final nama = _namaController.text.trim();
      final tanggalMasuk = _tanggalMasukController.text.trim();
      final tanggalKeluar = _tanggalKeluarController.text.trim();
      final kodeTeks = _kodeController.text.trim().replaceAll(',', '.');
      final stok = int.parse(_stokController.text.trim());

      // Bilangan desimal untuk NIM ganjil: double -> Firestore Number.
      // Bilangan bulat untuk NIM genap: int -> Firestore Integer.
      final num kode = _nimGanjil
          ? double.parse(kodeTeks)
          : int.parse(kodeTeks);

      await FirebaseFirestore.instance.collection('stok_barang').add({
        'nama_barang': nama,
        'tanggal_masuk_barang': tanggalMasuk,
        'tanggal_keluar_barang': tanggalKeluar,
        'kode_barang': kode,
        'jumlah_stok': stok,
        'waktu': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _namaController.clear();
      _tanggalMasukController.clear();
      _tanggalKeluarController.clear();
      _kodeController.clear();
      _stokController.clear();
      _tanggalMasuk = null;
      _tanggalKeluar = null;
      _formKey.currentState?.reset();
      _pesan('Data barang berhasil disimpan ke Firebase!', berhasil: true);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _pesan('Gagal menyimpan: ${e.message ?? e.code}', berhasil: false);
    } catch (e) {
      if (!mounted) return;
      _pesan('Terjadi kesalahan: $e', berhasil: false);
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  Widget _formTanggal({required bool masuk}) {
    return TextFormField(
      controller: masuk ? _tanggalMasukController : _tanggalKeluarController,
      readOnly: true,
      onTap: () => _pilihTanggal(masuk: masuk),
      validator: masuk ? _validasiTanggalMasuk : _validasiTanggalKeluar,
      decoration: InputDecoration(
        labelText: masuk ? 'Tanggal Masuk Barang' : 'Tanggal Keluar Barang',
        hintText: 'Pilih tanggal (DD/MM/YYYY)',
        prefixIcon: const Icon(Icons.calendar_month_outlined),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final jenisKode = _nimGanjil ? 'Desimal' : 'Integer';
    final contohKode = _nimGanjil ? '123$_akhiranKode.5' : '1234$_akhiranKode';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Stok Barang'),
        backgroundColor: warna.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: warna.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 38, color: warna.onPrimaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Form Data Stok Barang',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 5),
                              Text('NIM $nimMahasiswa • $jenisKode • Akhiran $_akhiranKode',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Masukkan informasi barang',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Nama barang diawali "$_inisialNama". Kode minimal 6 digit '
                              'pada bagian bulat, berakhiran $_akhiranKode.',
                              style: TextStyle(
                                  color: warna.onSurfaceVariant, fontSize: 12),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _namaController,
                              textCapitalization: TextCapitalization.sentences,
                              validator: _validasiNama,
                              decoration: InputDecoration(
                                labelText: 'Nama Barang',
                                hintText: '$_inisialNama - Buku Tulis',
                                prefixIcon: const Icon(Icons.inventory_2_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _formTanggal(masuk: true),
                            const SizedBox(height: 14),
                            _formTanggal(masuk: false),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _kodeController,
                              keyboardType: _nimGanjil
                                  ? const TextInputType.numberWithOptions(decimal: true)
                                  : TextInputType.number,
                              inputFormatters: [
                                _nimGanjil
                                    ? FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'))
                                    : FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _validasiKode,
                              decoration: InputDecoration(
                                labelText: 'Kode Barang ($jenisKode)',
                                hintText: 'Contoh: $contohKode',
                                prefixIcon: const Icon(Icons.qr_code_2_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _stokController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: _validasiStok,
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Stok',
                                hintText: 'Contoh: 25',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                            ),
                            const SizedBox(height: 22),
                            FilledButton.icon(
                              onPressed: _sedangMenyimpan ? null : _simpanBarang,
                              icon: _sedangMenyimpan
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.cloud_upload_outlined),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Text(_sedangMenyimpan
                                    ? 'Menyimpan...' : 'Simpan Barang'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Data dikirim ke Cloud Firestore → collection stok_barang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: warna.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
