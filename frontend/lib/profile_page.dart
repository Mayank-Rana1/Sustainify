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
                    _buildMenuItem(Icons.history, 'Scan History', 'View your past scans', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please use the History tab at the bottom to view past scans.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    }),
                    _buildMenuItem(Icons.settings_outlined, 'Settings', 'App preferences', () {
                      _showSettingsSheet(context);
                    }),
                    _buildMenuItem(Icons.info_outline, 'About Sustainify', 'Learn about our mission', () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Sustainify AI',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 Sustainify Team\nBuilt for AWS Hackathon',
                        applicationIcon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.eco, size: 40, color: Color(0xFF43A047)),
                        ),
                        children: [
                          SizedBox(height: 10),
                          Text('Sustainify helps you shop smart and dispose smart by using AWS Rekognition to analyze everyday products and provide environmental impact insights.'),
                        ],
                      );
                    }),
                    _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data', () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Privacy Policy', style: TextStyle(color: Color(0xFF2E7D32))),
                          content: Text('We respect your privacy.\n\nImages are processed via AWS Rekognition to generate eco-insights and are not permanently stored without your consent.\n\nYour history is securely stored in DynamoDB for your convenience.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), 
                              child: Text('Close', style: TextStyle(color: Color(0xFF43A047)))
                            ),
                          ],
                        ),
                      );
                    }),
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

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                SizedBox(height: 20),
                SwitchListTile(
                  title: Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Get reminders to dispose items responsibly', style: TextStyle(fontSize: 12)),
                  value: true,
                  activeColor: Color(0xFF43A047),
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notifications updated'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
                SwitchListTile(
                  title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Coming soon in a future update', style: TextStyle(fontSize: 12)),
                  value: false,
                  activeColor: Color(0xFF43A047),
                  onChanged: (val) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Dark mode is currently under development.'), duration: Duration(seconds: 1)),
                     );
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF43A047),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        }
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
