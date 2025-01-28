import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kelasProvider.dart';
import 'dart:convert'; // Tambahkan ini untuk json encoding/decoding

class jadwalPage extends StatefulWidget {
  @override
  _jadwalPageState createState() => _jadwalPageState();
}

class _jadwalPageState extends State<jadwalPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KelasProvider>().loadKelas();
    });
  }

  Future<void> _showScheduleDialog(dynamic kelas) async {
    String selectedDay = 'Senin'; // Default day
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Atur Jadwal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Pilih Hari',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Senin',
                      'Selasa',
                      'Rabu',
                      'Kamis',
                      'Jumat',
                      'Sabtu',
                      'Minggu'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDay = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Text(selectedTime != null
                        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Pilih Waktu'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: selectedTime != null
                      ? () {
                          Map<String, String> schedule = {
                            'hari': selectedDay,
                            'waktu':
                                '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          };
                          context
                              .read<KelasProvider>()
                              .updateClassSchedule(kelas.id, schedule);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? _getJadwalText(dynamic jadwalData) {
    if (jadwalData == null || jadwalData.toString().isEmpty) {
      return null;
    }

    try {
      Map<String, dynamic> jadwal;
      if (jadwalData is String) {
        jadwal = json.decode(jadwalData);
      } else {
        jadwal = Map<String, dynamic>.from(jadwalData);
      }

      if (jadwal.isEmpty) return null;

      String? hari = jadwal['hari'];
      String? waktu = jadwal['waktu'];

      if (waktu == null) return null;
      return '${hari ?? ''} ${waktu}';
    } catch (e) {
      print('Error parsing jadwal: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Kelas'),
        backgroundColor: Colors.blue,
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
              String? jadwalText = _getJadwalText(kelas.jadwal);

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
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(kelas.namaKelas),
                  subtitle: Text(
                    jadwalText != null
                        ? 'Jadwal: $jadwalText'
                        : 'Belum ada jadwal',
                    style: TextStyle(
                      color: jadwalText != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _showScheduleDialog(kelas),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
