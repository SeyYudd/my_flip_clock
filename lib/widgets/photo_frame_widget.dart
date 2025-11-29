import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoFrameWidget extends StatefulWidget {
  const PhotoFrameWidget({super.key});

  @override
  State<PhotoFrameWidget> createState() => _PhotoFrameWidgetState();
}

class _PhotoFrameWidgetState extends State<PhotoFrameWidget>
    with TickerProviderStateMixin {
  static const _channel = MethodChannel('photo_gallery_channel');

  List<String> _imagePaths = [];
  int _currentIndex = 0;
  Timer? _slideTimer;
  int _intervalSeconds = 10;
  bool _showControls = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Uint8List? _currentImage;
  Uint8List? _nextImage;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadSettings();
    _loadPhotos();
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _intervalSeconds = prefs.getInt('photo_interval') ?? 10;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('photo_interval', _intervalSeconds);
  }

  Future<void> _loadPhotos() async {
    try {
      // Request permission
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        // Try storage permission for older Android
        await Permission.storage.request();
      }

      // Get photos from gallery via platform channel
      final result = await _channel.invokeMethod('getPhotos', {'limit': 50});
      if (result != null && result is List) {
        setState(() {
          _imagePaths = result.cast<String>();
          if (_imagePaths.isNotEmpty) {
            _loadImage(_currentIndex);
            _startSlideshow();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
      // Use demo images
      _loadDemoImages();
    }
  }

  void _loadDemoImages() {
    // Demo: no actual images, show placeholder
    setState(() {
      _imagePaths = [];
    });
  }

  Future<void> _loadImage(int index) async {
    if (_imagePaths.isEmpty) return;
    try {
      final path = _imagePaths[index];
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() {
          _nextImage = bytes;
        });
        _fadeController.forward(from: 0).then((_) {
          setState(() {
            _currentImage = _nextImage;
          });
        });
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  void _startSlideshow() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(
      Duration(seconds: _intervalSeconds),
      (_) => _nextPhoto(),
    );
  }

  void _nextPhoto() {
    if (_imagePaths.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _imagePaths.length;
    });
    _loadImage(_currentIndex);
  }

  void _prevPhoto() {
    if (_imagePaths.isEmpty) return;
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _imagePaths.length) % _imagePaths.length;
    });
    _loadImage(_currentIndex);
    _startSlideshow(); // Reset timer
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'Photo Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Slide Interval: $_intervalSeconds seconds',
                style: const TextStyle(color: Colors.white),
              ),
              Slider(
                value: _intervalSeconds.toDouble(),
                min: 3,
                max: 60,
                divisions: 57,
                label: '$_intervalSeconds s',
                onChanged: (v) {
                  setDialogState(() => _intervalSeconds = v.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                _saveSettings();
                _startSlideshow();
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            _prevPhoto();
          } else {
            _nextPhoto();
          }
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Current image
            if (_currentImage != null)
              Image.memory(
                _currentImage!,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),

            // Fade transition for next image
            if (_nextImage != null && _currentImage != _nextImage)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.memory(
                  _nextImage!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),

            // No photos placeholder
            if (_imagePaths.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Photos',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Grant photo access to display gallery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadPhotos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),

            // Controls overlay
            if (_showControls && _imagePaths.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: const [0, 0.2, 0.8, 1],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentIndex + 1} / ${_imagePaths.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            onPressed: _showSettingsDialog,
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom controls
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _prevPhoto,
                            icon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: _nextPhoto,
                            icon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
