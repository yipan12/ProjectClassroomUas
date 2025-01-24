import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/serviceKelas.dart';
import '../models/kelas.dart';

class KelasProvider extends ChangeNotifier {
  final Servicekelas _service = Servicekelas();
  List<Kelas> _kelasList = [];
  Map<String, dynamic>? _selectedKelasDetails;
  bool _isLoading = false;
  Map<int, Set<int>> _selectedValues = {};
  List<Map<String, dynamic>>? _nilaiSiswa;

  List<Kelas> get kelasList => _kelasList;
  Map<String, dynamic>? get selectedKelasDetails => _selectedKelasDetails;
  bool get isLoading => _isLoading;
  Map<int, Set<int>> get selectedValues => _selectedValues;
  List<Map<String, dynamic>>? get nilaiSiswa => _nilaiSiswa;

  Future<void> loadKelas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final kelasData = await Servicekelas.fetchClasses();
      _kelasList = kelasData.map((json) => Kelas.fromJson(json)).toList();
    } catch (e) {
      // Error handling
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAttendance(int kelasId) async {
    try {
      final response = await Supabase.instance.client
          .from('absensi')
          .select()
          .eq('kelas_id', kelasId);

      _selectedValues.clear();
      for (var record in response) {
        final studentId = record['student_id'] as int;
        final columnIndex = record['column_index'] as int;

        if (!_selectedValues.containsKey(studentId)) {
          _selectedValues[studentId] = {};
        }
        _selectedValues[studentId]!.add(columnIndex);
      }
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  Future<void> loadNilaiSiswa(int siswaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('nilai')
          .select()
          .eq('siswa_id', siswaId);

      _nilaiSiswa = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat nilai: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClass(int kelasId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client
          .from('nilai')
          .delete()
          .eq('mata_pelajaran', kelasId);

      await Supabase.instance.client
          .from('siswa')
          .delete()
          .eq('kelas_id', kelasId);

      await Supabase.instance.client.from('kelas').delete().eq('id', kelasId);

      await loadKelas();
    } catch (e) {
      throw Exception('Gagal menghapus kelas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNilai(
      int siswaId, String jenisNilai, int nilai, int kelasId) async {
    try {
      await Supabase.instance.client.from('nilai').insert({
        'siswa_id': siswaId,
        'jenis_nilai': jenisNilai,
        'nilai': nilai,
        'mata_pelajaran': kelasId,
      });

      await loadNilaiSiswa(siswaId);
    } catch (e) {
      throw Exception('Gagal menambah nilai: $e');
    }
  }

  Future<void> updateNilai(int nilaiId, String jenisNilai, int nilai) async {
    try {
      await Supabase.instance.client.from('nilai').update({
        'jenis_nilai': jenisNilai,
        'nilai': nilai,
      }).eq('id', nilaiId);

      if (_nilaiSiswa != null && _nilaiSiswa!.isNotEmpty) {
        await loadNilaiSiswa(_nilaiSiswa![0]['siswa_id']);
      }
    } catch (e) {
      throw Exception('Gagal memperbarui nilai: $e');
    }
  }

  Future<void> deleteNilai(int nilaiId) async {
    try {
      await Supabase.instance.client.from('nilai').delete().eq('id', nilaiId);
      if (_nilaiSiswa != null && _nilaiSiswa!.isNotEmpty) {
        await loadNilaiSiswa(_nilaiSiswa![0]['siswa_id']);
      }
    } catch (e) {
      throw Exception('Gagal menghapus nilai: $e');
    }
  }

  Future<void> addClass(String className) async {
    await Servicekelas.addClass(className);
    await loadKelas();
  }

  Future<bool> updateClassName(int id, String newName) async {
    final success = await Servicekelas.updateClassName(id, newName);
    if (success) {
      await loadKelas();
    }
    return success;
  }

  Future<void> loadKelasDetails(int kelasId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedKelasDetails = await _service.tampilsiswafetch(kelasId);
      _initializeSelectedValues();
      await _loadAttendance(kelasId);
    } catch (e) {
      // Error handling
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(int kelasId, String namaSiswa) async {
    try {
      await Supabase.instance.client
          .from('siswa')
          .insert({
            'nama_siswa': namaSiswa,
            'kelas_id': kelasId,
          })
          .select()
          .single();
      await loadKelasDetails(kelasId);
    } catch (e) {
      throw Exception('Gagal menambah siswa: $e');
    }
  }

  Future<bool> updateClassSchedule(int id, Map<String, String> schedule) async {
    final success = await Servicekelas.updateClassSchedule(id, schedule);
    if (success) {
      await loadKelas();
    }
    return success;
  }

  Future<void> saveAttendance() async {
    final kelasId = _selectedKelasDetails?['id'];
    if (kelasId == null) return;

    try {
      await Supabase.instance.client
          .from('absensi')
          .delete()
          .eq('kelas_id', kelasId);

      final records = <Map<String, dynamic>>[];
      _selectedValues.forEach((studentId, columns) {
        for (var columnIndex in columns) {
          records.add({
            'student_id': studentId,
            'column_index': columnIndex,
            'kelas_id': kelasId,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      });

      if (records.isNotEmpty) {
        await Supabase.instance.client.from('absensi').insert(records);
      }
    } catch (e) {
      throw Exception('Failed to save attendance: $e');
    }
  }

  void _initializeSelectedValues() {
    if (_selectedKelasDetails != null &&
        _selectedKelasDetails!['siswa'] != null) {
      for (var siswa in _selectedKelasDetails!['siswa']) {
        _selectedValues[siswa['id']] = {};
      }
    }
  }

  void toggleAttendance(int studentId, int columnIndex) {
    if (!_selectedValues.containsKey(studentId)) {
      _selectedValues[studentId] = {};
    }

    if (_selectedValues[studentId]!.contains(columnIndex)) {
      _selectedValues[studentId]!.remove(columnIndex);
    } else {
      _selectedValues[studentId]!.add(columnIndex);
    }
    notifyListeners();
  }
}
