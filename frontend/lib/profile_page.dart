import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'api_service.dart';

class ProfilePage extends StatelessWidget {
  final CameraDescription camera;

  const ProfilePage({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              // Profile avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF66BB6A).withOpacity(0.4), blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Sustainify User',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              SizedBox(height: 4),
              Text(
                'Making the planet greener 🌱',
                style: TextStyle(fontSize: 14, color: Color(0xFF66BB6A)),
              ),
              SizedBox(height: 30),

              // Stats row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStatCard('Scans', '12', Icons.qr_code_scanner),
                    SizedBox(width: 12),
                    _buildStatCard('Eco Score', '78', Icons.eco),
                    SizedBox(width: 12),
                    _buildStatCard('Items Saved', '5', Icons.recycling),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Menu items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.history, 'Scan History', 'View your past scans', () {}),
                    _buildMenuItem(Icons.settings_outlined, 'Settings', 'App preferences', () {}),
                    _buildMenuItem(Icons.info_outline, 'About Sustainify', 'Learn about our mission', () {}),
                    _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data', () {}),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Version
              Text(
                'Sustainify AI v1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Powered by AWS ☁️',
                style: TextStyle(fontSize: 12, color: Color(0xFF66BB6A), fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF43A047), size: 24),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Color(0xFF43A047), size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                    SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
