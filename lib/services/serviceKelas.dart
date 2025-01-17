import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Servicekelas {
  // Tambah kelas baru
  static Future<void> addClass(String className) async {
    final supabaseClient = Supabase.instance.client;

    try {
      final response = await supabaseClient
          .from('kelas')
          .insert([
            {
              'nama_kelas': className,
              'created_at': DateTime.now().toIso8601String(),
            }
          ])
          .select()
          .single();

      if (response != null) {
        Fluttertoast.showToast(msg: 'Kelas berhasil ditambah');
      } else {
        Fluttertoast.showToast(msg: "Kelas gagal ditambah");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan");
    }
  }

  // Perbarui nama kelas
  static Future<bool> updateClassName(int id, String newName) async {
    try {
      await Supabase.instance.client
          .from('kelas')
          .update({'nama_kelas': newName}).eq('id', id);

      Fluttertoast.showToast(msg: 'Kelas berhasil diperbarui');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Terjadi kesalahan saat memperbarui kelas');
      return false;
    }
  }

  // Ambil daftar kelas
  static Future<List<dynamic>> fetchClasses() async {
    final supabaseClient = Supabase.instance.client;

    try {
      final response = await supabaseClient
          .from('kelas')
          .select()
          .order('created_at', ascending: false);

      return response as List<dynamic>;
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data kelas");
      return [];
    }
  }

  Future<Map<String, dynamic>> tampilsiswafetch(int kelasId) async {
    try {
      final response = await Supabase.instance.client
          .from('kelas')
          .select('id, nama_kelas, siswa (id, nama_siswa)')
          .eq('id', kelasId)
          .single();
      return response;
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data siswa");
      return {};
    }
  }
}
