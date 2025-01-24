import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kelasProvider.dart';
import 'listSiswaNilaiPage.dart';

class listNilaiPage extends StatefulWidget {
  @override
  _listNilaiPageState createState() => _listNilaiPageState();
}

class _listNilaiPageState extends State<listNilaiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KelasProvider>().loadKelas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Nilai'),
        elevation: 0,
      ),
      body: Consumer<KelasProvider>(
        builder: (context, kelasProvider, child) {
          if (kelasProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: kelasProvider.kelasList.length,
            itemBuilder: (context, index) {
              var kelas = kelasProvider.kelasList[index];
              return Container(
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
                            NilaiDetailPage(kelasId: kelas.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
