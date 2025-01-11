import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://aaqdxzndfjiswpyxgrxa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhcWR4em5kZmppc3dweXhncnhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2MjA1NzgsImV4cCI6MjA1MDE5NjU3OH0.xtrK2eKqzuYxI2RRPNLa27Khp4KyK7B_1v_ddmi0tHQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

Future<void> addClass(String className) async {
  final supabaseClient = Supabase.instance.client;

  try {
    final response = await supabaseClient
        .from('kelas')
        .insert([
          {
            'nama_kelas': className,
            'created_at': DateTime.now().toIso8601String()
          }
        ])
        .select()
        .single();
    if (response != null) {
      Fluttertoast.showToast(msg: 'Kelas berhasil ditambah');
    } else {
      Fluttertoast.showToast(msg: "Kelas gagal ditambah");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Terjadi kesalahan");
  }
}

Future<List<dynamic>> fetchClasses() async {
  final supabaseClient = Supabase.instance.client;

  try {
    final response = await supabaseClient
        .from('kelas')
        .select()
        .order('created_at', ascending: false);

    return response as List<dynamic>;
  } catch (e) {
    Fluttertoast.showToast(msg: "Gagal memuat data kelas");
    return [];
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _classnamecontroler = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _isTextFieldVisible = false;
  List<dynamic> _kelaslist = [];

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
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    List<dynamic> kelasData = await fetchClasses();
    setState(() {
      _kelaslist = kelasData;
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

  void _handleSubmit() {
    if (_classnamecontroler.text.isNotEmpty) {
      addClass(_classnamecontroler.text);
      _classnamecontroler.clear();
      _toggleDialog();
      _loadKelas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal kelas'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: _kelaslist.length,
                itemBuilder: (context, index) {
                  var kelas = _kelaslist[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black54, width: 0.5),
                      ),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        kelas['nama_kelas'] ?? 'Nama Kelas Tidak Tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      minLeadingWidth: 10,
                      minVerticalPadding: 20,
                    ),
                  );
                },
              ))
            ],
          ),
          // bagian textfield
          if (_isTextFieldVisible && _animation != null)
            FadeTransition(
              opacity: _animation!,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ScaleTransition(
                    scale: _animation!,
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 32),
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 24,
                            ),
                            TextField(
                              controller: _classnamecontroler,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: "Masukan nama kelas",
                                labelText: 'Nama Kelas',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _handleSubmit(),
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _toggleDialog,
                                  child: Text(
                                    'Batal',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _handleSubmit,
                                  child: Text(
                                    'Simpan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
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
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDialog,
        child: Icon(_isTextFieldVisible ? Icons.close : Icons.add),
      ),
    );
  }
}
