import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

class ScanningPage extends StatefulWidget {
  final CameraDescription camera;
  final String mode; // 'shop' or 'dispose'

  const ScanningPage({Key? key, required this.camera, required this.mode}) : super(key: key);

  @override
  _ScanningPageState createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high, enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _isProcessing = true);
    try {
      final result = await ApiService.uploadFile(
        widget.mode == 'shop' ? 'eco' : 'dispose', 
        imageFile, 
        ""
      );
      Navigator.pop(context, {'file': imageFile, 'result': result});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized || _isProcessing) return;
    try {
      setState(() => _isProcessing = true);
      final image = await _controller.takePicture();
      await _processImage(File(image.path));
    } catch (e) {
      print('Error taking picture: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      await _processImage(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isProcessing 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 20),
                Text('Analyzing with AWS AI...', style: TextStyle(color: Colors.white, fontSize: 18))
              ],
            ),
          )
        : Stack(
            children: [
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.previewSize?.height ?? 1,
                          height: _controller.value.previewSize?.width ?? 1,
                          child: CameraPreview(_controller),
                        ),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          widget.mode == 'shop' ? 'Shop Smart' : 'Dispose Smart',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 30),
                        onPressed: () async {
                          setState(() => _isFlashOn = !_isFlashOn);
                          await _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Scanner box overlay
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo_library, color: Colors.white, size: 32),
                        onPressed: _pickGallery,
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white38,
                          ),
                          child: Center(
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48), // Balance the row
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}