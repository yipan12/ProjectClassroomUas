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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KelasProvider>().loadKelasDetails(widget.kelasId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kelas'),
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey.shade200),
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
    );
  }
}
