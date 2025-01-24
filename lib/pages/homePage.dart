import 'package:Classroom/main.dart';
import 'package:Classroom/pages/jadwalPage.dart';
import 'package:Classroom/pages/listNilaiPage.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:Classroom/pages/jadwalPage.dart';
import 'package:Classroom/pages/listAbsenPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [listAbsenPage(), jadwalPage(), listNilaiPage()];

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.dashboard),
              title: Text("Dashboard"),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.schedule),
              title: Text("Jadwal"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.line_axis),
              title: Text("Nilai"),
              selectedColor: const Color.fromARGB(255, 67, 187, 63),
            ),
          ],
        ),
      ),
    );
  }
}
