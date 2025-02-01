import 'package:Weclass/models/kelas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kelasProvider.dart';

class NilaiSiswaPage extends StatefulWidget {
  final int siswaId;
  final String namaSiswa;

  NilaiSiswaPage({required this.siswaId, required this.namaSiswa});

  @override
  _NilaiSiswaPageState createState() => _NilaiSiswaPageState();
}

class _NilaiSiswaPageState extends State<NilaiSiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nilaiController = TextEditingController();
  final _jenisNilaiController = TextEditingController();
  List<Kelas> _kelasList = [];
  String? _selectedKelas;

  @override
  void initState() {
    super.initState();
    // Load kelas data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kelasProvider = Provider.of<KelasProvider>(context, listen: false);
      kelasProvider.loadKelas().then((_) {
        setState(() {
          _kelasList = kelasProvider.kelasList;
        });
      });
      kelasProvider.loadNilaiSiswa(widget.siswaId);
    });
  }

  void _showAddNilaiDialog() {
    _nilaiController.clear();
    _jenisNilaiController.clear();
    _selectedKelas = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Wrap AlertDialog with StatefulBuilder
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Tambah Nilai'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedKelas,
                      hint: Text('Pilih Kelas'),
                      items: _kelasList.map((kelas) {
                        return DropdownMenuItem<String>(
                          value: kelas.id.toString(),
                          child: Text(kelas.namaKelas),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          // Use setState from StatefulBuilder
                          _selectedKelas = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap pilih kelas';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _jenisNilaiController,
                      decoration: InputDecoration(
                        labelText: 'Jenis Nilai (UTS/UAS/Tugas)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi jenis nilai';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nilaiController,
                      decoration: InputDecoration(
                        labelText: 'Nilai',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi nilai';
                        }
                        int? nilai = int.tryParse(value);
                        if (nilai == null || nilai < 0 || nilai > 100) {
                          return 'Nilai harus antara 0-100';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<KelasProvider>().addNilai(
                            widget.siswaId,
                            _jenisNilaiController.text,
                            int.parse(_nilaiController.text),
                            int.parse(_selectedKelas!),
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNilaiDialog(Map<String, dynamic> nilai) {
    _nilaiController.text = nilai['nilai'].toString();
    _jenisNilaiController.text = nilai['jenis_nilai'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Nilai'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _jenisNilaiController,
                  decoration: InputDecoration(
                    labelText: 'Jenis Nilai',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi jenis nilai';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nilaiController,
                  decoration: InputDecoration(
                    labelText: 'Nilai',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi nilai';
                    }
                    int? nilai = int.tryParse(value);
                    if (nilai == null || nilai < 0 || nilai > 100) {
                      return 'Nilai harus antara 0-100';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<KelasProvider>().updateNilai(
                        nilai['id'],
                        _jenisNilaiController.text,
                        int.parse(_nilaiController.text),
                      );
                  Navigator.pop(context);
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nilai ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<KelasProvider>(
        builder: (context, kelasProvider, child) {
          if (kelasProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final nilaiList = kelasProvider.nilaiSiswa;

          if (nilaiList == null || nilaiList.isEmpty) {
            return Center(
              child: Text('Belum ada nilai'),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.blue.shade800,
                child: Text(
                  widget.namaSiswa,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: nilaiList.length,
                  itemBuilder: (context, index) {
                    final nilai = nilaiList[index];
                    // Pastikan nilai tidak null dan memiliki semua field yang diperlukan
                    if (nilai == null ||
                        nilai['jenis_nilai'] == null ||
                        nilai['nilai'] == null ||
                        nilai['id'] == null) {
                      return SizedBox(); // Skip item jika data tidak lengkap
                    }

                    return Dismissible(
                      key: Key(nilai['id'].toString()),
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          kelasProvider.deleteNilai(nilai['id']);
                        }
                      },
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _showEditNilaiDialog(nilai);
                          return false;
                        }
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text('Yakin ingin menghapus nilai ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text('Hapus'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ListTile(
                        title: Text(nilai['jenis_nilai'].toString()),
                        trailing: Text(
                          nilai['nilai'].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
        onPressed: _showAddNilaiDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
