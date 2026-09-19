import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'scanning_page.dart';
import 'main_navigation.dart';
import 'api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: MainNavigation(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  const MyHomePage({Key? key, required this.camera}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  Map<String, dynamic>? _analysisResult;

  Future<void> _openScanner(String mode) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanningPage(camera: widget.camera, mode: mode),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _imageFile = result['file'];
        _analysisResult = result['result'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5FFF5),
      appBar: AppBar(
        title: Text('Sustainify AI', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_analysisResult != null)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.black),
              onPressed: () => setState(() { _analysisResult = null; _imageFile = null; }),
            )
        ],
      ),
      body: _analysisResult == null ? _buildHomeView() : _buildResultView(),
    );
  }

  Widget _buildHomeView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello,', style: TextStyle(fontSize: 28, color: Colors.grey[700])),
            Text('Ready to scan?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            SizedBox(height: 40),
            _buildActionCard(
              title: 'Shop Smart',
              subtitle: 'Scan products before buying to check eco-score and materials',
              icon: Icons.shopping_cart_outlined,
              color: Color(0xFF43A047),
              onTap: () => _openScanner('shop'),
            ),
            SizedBox(height: 20),
            _buildActionCard(
              title: 'Dispose Smart',
              subtitle: 'Scan waste to learn how to recycle or upcycle it properly',
              icon: Icons.delete_outline,
              color: Color(0xFF2E7D32),
              onTap: () => _openScanner('dispose'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 36),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final type = _analysisResult!['type'] ?? 'shop';
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_imageFile != null)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
              ),
            ),
          Container(
            transform: Matrix4.translationValues(0, -30, 0),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFFF5FFF5),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: type == 'shop' ? _buildShopResult() : _buildDisposeResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopResult() {
    final data = _analysisResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data['name'] ?? 'Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Color(0xFF43A047), borderRadius: BorderRadius.circular(20)),
              child: Text('Score: ${data['score']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        SizedBox(height: 8),
        Text('Rating: ${data['rating']}  •  Confidence: ${(data['confidence']*100).toInt()}%', style: TextStyle(color: Colors.grey[700])),
        SizedBox(height: 24),
        
        _buildSectionTitle('Packaging & Material'),
        Text(data['packaging'] ?? '', style: TextStyle(fontSize: 15)),
        SizedBox(height: 8),
        Text(data['recyclability'] ?? '', style: TextStyle(fontSize: 15)),
        
        SizedBox(height: 24),
        _buildSectionTitle('Positives'),
        for (var p in data['positives'] ?? []) Padding(padding: EdgeInsets.only(bottom:4), child: Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 18), SizedBox(width: 8), Expanded(child: Text(p))])),
        
        SizedBox(height: 16),
        _buildSectionTitle('Concerns'),
        for (var c in data['concerns'] ?? []) Padding(padding: EdgeInsets.only(bottom:4), child: Row(children: [Icon(Icons.warning, color: Colors.orange, size: 18), SizedBox(width: 8), Expanded(child: Text(c))])),
        
        SizedBox(height: 24),
        _buildSectionTitle('Score Breakdown'),
        if (data['breakdown'] != null) ...[
          _buildScoreBar('Packaging', data['breakdown']['Packaging'], 25),
          _buildScoreBar('Material', data['breakdown']['Material'], 25),
          _buildScoreBar('Recyclability', data['breakdown']['Recyclability'], 20),
          _buildScoreBar('Reusability', data['breakdown']['Reusability'], 15),
        ],

        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF2E7D32)),
              SizedBox(width: 12),
              Expanded(child: Text(data['better'] ?? '', style: TextStyle(color: Color(0xFF2E7D32)))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDisposeResult() {
    final data = _analysisResult!;
    Color actionColor = data['action'] == 'RECYCLE' ? Colors.blue : 
                        data['action'] == 'COMPOST' ? Colors.green : 
                        data['action'] == 'SAFE DISPOSAL' ? Colors.red : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: actionColor, borderRadius: BorderRadius.circular(30)),
                child: Text(data['action'] ?? 'UNKNOWN', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 12),
              Text('${data['name']} • ${data['material']}', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
              if (data['hazard'] == true) 
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.warning, color: Colors.red, size: 20), SizedBox(width: 4), Text('Hazardous Material', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 30),
        _buildSectionTitle('What to do'),
        for (int i=0; i<(data['steps']?.length ?? 0); i++) 
          Padding(
            padding: EdgeInsets.only(bottom: 12), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 12, backgroundColor: actionColor.withOpacity(0.2), child: Text('${i+1}', style: TextStyle(color: actionColor, fontSize: 12, fontWeight: FontWeight.bold))), 
                SizedBox(width: 12), 
                Expanded(child: Text(data['steps'][i], style: TextStyle(fontSize: 16)))
              ]
            )
          ),

        if (data['diy'] != null) ...[
          SizedBox(height: 24),
          _buildSectionTitle('DIY Upcycling Idea'),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.handyman, color: Colors.orange[800]),
                SizedBox(width: 12),
                Expanded(child: Text(data['diy'], style: TextStyle(color: Colors.orange[900], fontSize: 15))),
              ],
            ),
          )
        ]
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
    );
  }

  Widget _buildScoreBar(String label, int val, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: val / max,
              backgroundColor: Colors.grey[200],
              color: Color(0xFF43A047),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(width: 12),
          Text('$val/$max', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ],
      ),
    );
  }
}