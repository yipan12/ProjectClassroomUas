import 'package:flutter/material.dart';
import '../services/serviceKelas.dart';
import '../models/kelas.dart';

class KelasProvider extends ChangeNotifier {
  final Servicekelas _service = Servicekelas();
  List<Kelas> _kelasList = [];
  Map<String, dynamic>? _selectedKelasDetails;
  bool _isLoading = false;
  Map<int, Set<int>> _selectedValues = {};

  // Getters
  List<Kelas> get kelasList => _kelasList;
  Map<String, dynamic>? get selectedKelasDetails => _selectedKelasDetails;
  bool get isLoading => _isLoading;
  Map<int, Set<int>> get selectedValues => _selectedValues;

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
    } catch (e) {
      // Error handling
    } finally {
      _isLoading = false;
      notifyListeners();
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
