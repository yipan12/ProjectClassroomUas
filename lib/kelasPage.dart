import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelasPage extends StatefulWidget {
  final Map<String, dynamic> kelasId; // Ubah tipe parameter menjadi Map

  KelasPage({required this.kelasId});

  @override
  _KelasPageState createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  late Future<Map<String, dynamic>> kelasDetails;

  @override
  void initState() {
    super.initState();
    kelasDetails = _fetchKelasDetails(
        widget.kelasId['id'].toString()); // Konversi ke string
  }

  Future<Map<String, dynamic>> _fetchKelasDetails(String kelasId) async {
    final supabaseClient = Supabase.instance.client;
    try {
      final response = await supabaseClient
          .from('kelas')
          .select()
          .eq('id', kelasId)
          .single();

      if (response != null && response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception("Kelas tidak ditemukan");
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kelas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: kelasDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data?['error'] != null) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?['id'] == null) {
            return Center(child: Text('Kelas tidak ditemukan'));
          } else {
            final kelas = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail untuk Kelas: ${kelas['nama_kelas'] ?? 'Tidak ada nama kelas'}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ID Kelas: ${kelas['id'] ?? 'Tidak ada ID'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Informasi lainnya: ${kelas['informasi'] ?? 'Tidak ada informasi tambahan'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
