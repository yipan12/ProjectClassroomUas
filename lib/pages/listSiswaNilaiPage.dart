import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kelasProvider.dart';
import 'nilaiSiswaPage.dart';

class NilaiDetailPage extends StatefulWidget {
  final int kelasId;

  NilaiDetailPage({required this.kelasId});

  @override
  _NilaiDetailPageState createState() => _NilaiDetailPageState();
}

class _NilaiDetailPageState extends State<NilaiDetailPage> {
  final TextEditingController _namaSiswaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KelasProvider>().loadKelasDetails(widget.kelasId);
    });
  }

  @override
  void dispose() {
    _namaSiswaController.dispose();
    super.dispose();
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tambah Siswa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _namaSiswaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Siswa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Batal'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_namaSiswaController.text.isNotEmpty) {
                          try {
                            await context.read<KelasProvider>().addStudent(
                                  widget.kelasId,
                                  _namaSiswaController.text,
                                );
                            _namaSiswaController.clear();
                            Navigator.pop(context);
                            // Reload the data after adding student
                            _loadData();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Gagal menambah siswa: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Tambah'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Nilai'),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Consumer<KelasProvider>(
        builder: (context, kelasProvider, child) {
          if (kelasProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final kelasDetails = kelasProvider.selectedKelasDetails;
          if (kelasDetails == null) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          final siswaList = kelasDetails['siswa'] as List<dynamic>?;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.blue.shade800,
                child: Text(
                  'Kelas: ${kelasDetails['nama_kelas']}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: siswaList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final siswa = siswaList![index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          siswa['nama_siswa'] ?? 'Nama tidak ada',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NilaiSiswaPage(
                                siswaId: siswa['id'],
                                namaSiswa: siswa['nama_siswa'],
                              ),
                            ),
                          ).then((_) {
                            // Refresh the list when returning from NilaiSiswaPage
                            _loadData();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
