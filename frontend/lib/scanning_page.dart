import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'api_service.dart';

class ScanningPage extends StatefulWidget {
  final CameraDescription camera;
  final String mode; 

  const ScanningPage({Key? key, required this.camera, this.mode = 'shop'})
      : super(key: key);

  @override
  _ScanningPageState createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;
  bool _isRecording = false;
  File? _videoFile; // Now used for image
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
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

  Future<void> _startVideoRecording() async {
    if (!_controller.value.isInitialized) return;
    _animationController.forward();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopVideoRecording() async {
    _animationController.reset();
    setState(() {
      _isRecording = false;
    });
    
    // Instead of stopping video, take a picture for AWS
    try {
      final image = await _controller.takePicture();
      await _processImage(File(image.path));
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  // Function to pick a video from the gallery
  Future<void> _pickVideoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      await _processImage(File(result.files.single.path!));
    } else {
      print('Image picking canceled.');
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
                        onLongPressStart: (details) => _startVideoRecording(),
                        onLongPressEnd: (details) => _stopVideoRecording(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return CircularProgressIndicator(
                                  value: _animation.value,
                                  strokeWidth: 8.0,
                                  color: Colors.greenAccent[700],
                                  backgroundColor: Colors.grey,
                                );
                              },
                            ),
                            CircleAvatar(
                              radius: 35.0,
                              backgroundColor: Colors.greenAccent[700],
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.videocam,
                                color: Colors.white,
                                size: 35.0,
                              ),
                            ),
                          ],
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
