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
      _buildHistoryPage(),
      ProfilePage(camera: widget.camera),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 11),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 26),
                activeIcon: Icon(Icons.home, size: 26),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined, size: 26),
                activeIcon: Icon(Icons.history, size: 26),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 26),
                activeIcon: Icon(Icons.person, size: 26),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Scan History',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFF43A047)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No scans yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Scan a product to see its\nsustainability analysis here',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
