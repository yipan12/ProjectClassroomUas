import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kelasProvider.dart';
import 'absensiPage.dart';

class listAbsenPage extends StatefulWidget {
  @override
  _listAbsenPageState createState() => _listAbsenPageState();
}

class _listAbsenPageState extends State<listAbsenPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _classnamecontroler = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _isTextFieldVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KelasProvider>().loadKelas();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _classnamecontroler.dispose();
    super.dispose();
  }

  void _toggleDialog() {
    setState(() {
      if (_isTextFieldVisible) {
        _animationController?.reverse();
      } else {
        _animationController?.forward();
      }
      _isTextFieldVisible = !_isTextFieldVisible;
    });
  }

  Future<void> _showEditDialog(dynamic kelas) async {
    final TextEditingController editController = TextEditingController(
      text: kelas.namaKelas,
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Kelas'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: 'Nama Kelas',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.isNotEmpty) {
                  await context
                      .read<KelasProvider>()
                      .updateClassName(kelas.id, editController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(dynamic kelas) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Kelas'),
          content: Text(
              'Anda yakin ingin menghapus kelas  ${kelas.namaKelas}?\nSemua data siswa dan nilai akan ikut terhapus.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<KelasProvider>().deleteClass(kelas.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    if (_classnamecontroler.text.isNotEmpty) {
      context.read<KelasProvider>().addClass(_classnamecontroler.text);
      _classnamecontroler.clear();
      _toggleDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Absensi Kelas')),
      body: Consumer<KelasProvider>(
        builder: (context, kelasProvider, child) {
          if (kelasProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              ListView.builder(
                itemCount: kelasProvider.kelasList.length,
                itemBuilder: (context, index) {
                  var kelas = kelasProvider.kelasList[index];
                  return Dismissible(
                    key: Key(kelas.id.toString()),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Edit', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.edit, color: Colors.white),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        await _showEditDialog(kelas);
                      } else {
                        await _showDeleteConfirmation(kelas);
                      }
                      return false;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color.fromARGB(255, 222, 222, 222),
                            width: 2,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        title: Text(kelas.namaKelas),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  absensiPage(kelasId: kelas.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              if (_isTextFieldVisible && _animation != null)
                FadeTransition(
                  opacity: _animation!,
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 32),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _classnamecontroler,
                                decoration: InputDecoration(
                                  labelText: 'Nama Kelas',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _handleSubmit(),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _toggleDialog,
                                    child: Text('Batal'),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _handleSubmit,
                                    child: Text('Simpan'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDialog,
        child: Icon(_isTextFieldVisible ? Icons.close : Icons.add),
      ),
    );
  }
}
