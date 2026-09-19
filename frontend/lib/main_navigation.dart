import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final CameraDescription camera;
  const MainNavigation({Key? key, required this.camera}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      MyHomePage(camera: widget.camera),
      Center(child: Text('List Page Placeholder')),
      Center(child: Text('Favorites Placeholder')),
      ProfilePage(camera: widget.camera),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF5AB664),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF265022),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 30), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list, size: 30), label: 'List'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border, size: 30), label: 'Heart'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 30), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
