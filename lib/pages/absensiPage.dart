import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kelasProvider.dart';

class absensiPage extends StatefulWidget {
  final int kelasId;

  absensiPage({required this.kelasId});

  @override
  _absensiPageState createState() => _absensiPageState();
}

class _absensiPageState extends State<absensiPage> {
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KelasProvider>().loadKelasDetails(widget.kelasId);
    });
  }

  Future<void> _saveAttendance() async {
    try {
      await context.read<KelasProvider>().saveAttendance();
      setState(() {
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absensi berhasil disimpan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan absensi: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Perubahan Belum Disimpan'),
          content: Text('Apakah Anda ingin menyimpan perubahan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Buang Perubahan'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveAttendance();
                Navigator.of(context).pop(true);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Detail Kelas',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButton: Consumer<KelasProvider>(
          builder: (context, provider, child) {
            return _hasChanges
                ? FloatingActionButton(
                    onPressed: _saveAttendance,
                    child: Icon(Icons.save),
                    backgroundColor: Colors.green,
                  )
                : Container();
          },
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
                  color: Colors.blue,
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.grey.shade200),
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        columns: [
                          DataColumn(
                            label: Container(
                              width: 150,
                              child: Text(
                                'Nama Mahasiswa',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ...List.generate(
                            14,
                            (index) => DataColumn(
                              label: Container(
                                width: 25,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: siswaList?.map<DataRow>((siswa) {
                              final studentId = siswa['id'] as int;
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: 150,
                                      child: Text(
                                        siswa['nama_siswa'] ?? 'Nama tidak ada',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  ...List.generate(
                                    14,
                                    (columnIndex) => DataCell(
                                      Container(
                                        width: 25,
                                        alignment: Alignment.center,
                                        child: Checkbox(
                                          value: kelasProvider
                                                  .selectedValues[studentId]
                                                  ?.contains(columnIndex) ??
                                              false,
                                          onChanged: (bool? checked) {
                                            if (checked != null) {
                                              kelasProvider.toggleAttendance(
                                                  studentId, columnIndex);
                                              setState(() {
                                                _hasChanges = true;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
