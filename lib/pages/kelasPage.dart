import 'package:flutter/material.dart';
import '../services/serviceKelas.dart';

class KelasPage extends StatefulWidget {
  final int kelasId;

  KelasPage({required this.kelasId});

  @override
  _KelasPageState createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  late Future<Map<String, dynamic>> kelasDetails;
  // Change the state declaration to be mutable
  Map<int, Set<int>> selectedValues = <int, Set<int>>{};

  @override
  void initState() {
    super.initState();
    kelasDetails = Servicekelas().tampilsiswafetch(widget.kelasId);
  }

  void _initializeStudentSet(int studentId) {
    if (!selectedValues.containsKey(studentId)) {
      selectedValues[studentId] = <int>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kelas'),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: kelasDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Data kelas tidak ditemukan'));
          }

          final kelas = snapshot.data!;
          final siswaList = kelas['siswa'] as List<dynamic>?;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.blue.shade800,
                child: Text(
                  'Kelas: ${kelas['nama_kelas']}',
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
                            _initializeStudentSet(studentId);

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
                                        value: selectedValues[studentId]
                                                ?.contains(columnIndex) ??
                                            false,
                                        onChanged: (bool? checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedValues[studentId]!
                                                  .add(columnIndex);
                                            } else {
                                              selectedValues[studentId]!
                                                  .remove(columnIndex);
                                            }
                                          });
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
    );
  }
}
