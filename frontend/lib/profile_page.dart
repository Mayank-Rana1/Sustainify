import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'login_page.dart';
import 'api_service.dart';

class ProfilePage extends StatelessWidget {
  final CameraDescription camera;

  const ProfilePage({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/profile.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF67B55D),
                        ),
                      ),
                      Text(
                        AuthService.username ?? 'User',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF3B8132),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ListView(
                  children: [
                    _buildMenuButton(Icons.card_giftcard, 'Rewards'),
                    _buildMenuButton(Icons.vpn_key_outlined, 'Change Password'),
                    _buildMenuButton(Icons.badge_outlined, 'Details'),
                    _buildMenuButton(Icons.settings_outlined, 'Settings'),
                    _buildMenuButton(Icons.notes, 'Terms and Conditions', isLogout: true, context: context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String text, {bool isLogout = false, BuildContext? context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          if (isLogout && context != null) {
            AuthService.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage(camera: camera)),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF90C988).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFF3B8132)),
              SizedBox(width: 20),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF193B15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
