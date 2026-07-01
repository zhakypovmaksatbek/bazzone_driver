import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum StencilType { carFrontBack, carSide, carTrunk, seat, license }

@RoutePage(name: 'CustomCameraRoute')
class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({
    super.key,
    required this.title,
    required this.stencilType,
  });

  final String title;
  final StencilType stencilType;

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showError('Камера не найдена на этом устройстве.');
        return;
      }

      // Select primary back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (!mounted) return;

      // Set initial flash mode
      await _controller!.setFlashMode(_flashMode);

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showError('Ошибка при инициализации камеры: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ColorConst.error),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before camera completed initialization
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
      default:
        nextMode = FlashMode.off;
        break;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (e) {
      _showError('Не удалось изменить режим вспышки: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture)
      return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        context.router.maybePop(image.path);
      }
    } catch (e) {
      _showError('Ошибка при съемке кадра: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: ColorConst.black,
        body: Center(
          child: CircularProgressIndicator(color: ColorConst.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorConst.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Viewport Preview (cropped/scaled)
            Center(child: CameraPreview(_controller!)),

            // 2. Translucent mask & vector layout helper overlay
            Positioned.fill(
              child: CustomPaint(
                painter: StencilOverlayPainter(stencilType: widget.stencilType),
              ),
            ),

            // 3. Header title / guide instructions
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: ColorConst.white,
                        size: 20,
                      ),
                      onPressed: () => context.router.maybePop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: ColorConst.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _flashMode == FlashMode.off
                            ? Icons.flash_off_rounded
                            : _flashMode == FlashMode.always
                            ? Icons.flash_on_rounded
                            : Icons.flash_auto_rounded,
                        color: ColorConst.white,
                        size: 20,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Instructions below title
            Positioned(
              top: 80,
              left: 32,
              right: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getInstructionText(widget.stencilType),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // 5. Sticky Bottom Control Panel
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _captureImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white30,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: ColorConst.white,
                            shape: BoxShape.circle,
                          ),
                          child: _isTakingPicture
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: ColorConst.primary,
                                  ),
                                )
                              : null,
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

  String _getInstructionText(StencilType type) {
    switch (type) {
      case StencilType.carFrontBack:
        return 'Поместите переднюю/заднюю часть автомобиля в рамку';
      case StencilType.carSide:
        return 'Сфотографируйте автомобиль сбоку целиком, вписав в силуэт';
      case StencilType.carTrunk:
        return 'Откройте багажник и сфотографируйте его сзади';
      case StencilType.seat:
        return 'Сфотографируйте сиденье автомобиля изнутри салона';
      case StencilType.license:
        return 'Выровняйте водительское удостоверение по рамке';
    }
  }
}

class StencilOverlayPainter extends CustomPainter {
  StencilOverlayPainter({required this.stencilType});

  final StencilType stencilType;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Paint for dimmed background
    final Paint maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Paint for stencil guidelines
    final Paint linePaint = Paint()
      ..color = ColorConst.primary.withValues(alpha: 0.85)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint glowPaint = Paint()
      ..color = ColorConst.primary.withValues(alpha: 0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path maskPath = Path()..addRect(Rect.fromLTWH(0, 0, width, height));
    final Path cutoutPath = Path();

    if (stencilType == StencilType.license) {
      // 1. Draw rounded card cutout in center
      final double cardWidth = width * 0.85;
      final double cardHeight = cardWidth / 1.586; // standard card ratio
      final double cardLeft = (width - cardWidth) / 2;
      final double cardTop = (height - cardHeight) / 2 - 20;

      final RRect cardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight),
        const Radius.circular(16),
      );
      cutoutPath.addRRect(cardRect);

      // Subtract cutout from mask and paint background
      final Path maskWithCutout = Path.combine(
        PathOperation.difference,
        maskPath,
        cutoutPath,
      );
      canvas.drawPath(maskWithCutout, maskPaint);

      // Draw active stencil guide lines
      canvas.drawRRect(cardRect, linePaint);
      canvas.drawRRect(cardRect, glowPaint);
    } else {
      // For car shapes, draw transparent overlay and custom guidelines
      canvas.drawPath(maskPath, maskPaint);

      final Path stencilPath = Path();

      if (stencilType == StencilType.carFrontBack) {
        // Draw car front/back shape
        final double cx = width / 2;
        final double cy = height / 2 - 20;
        final double w = width * 0.75;
        final double h = w * 0.65;

        // Roof
        stencilPath.moveTo(cx - w * 0.25, cy - h * 0.4);
        stencilPath.lineTo(cx + w * 0.25, cy - h * 0.4);
        // Windshield columns
        stencilPath.lineTo(cx + w * 0.4, cy - h * 0.1);
        // Hood
        stencilPath.lineTo(cx + w * 0.48, cy - h * 0.05);
        // Headlights/Grille level
        stencilPath.lineTo(cx + w * 0.48, cy + h * 0.25);
        // Left side
        stencilPath.lineTo(cx - w * 0.48, cy + h * 0.25);
        stencilPath.lineTo(cx - w * 0.48, cy - h * 0.05);
        stencilPath.lineTo(cx - w * 0.4, cy - h * 0.1);
        stencilPath.close();

        // Wheels
        stencilPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - w * 0.45, cy + h * 0.25, w * 0.15, h * 0.15),
            const Radius.circular(4),
          ),
        );
        stencilPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + w * 0.3, cy + h * 0.25, w * 0.15, h * 0.15),
            const Radius.circular(4),
          ),
        );

        // Side mirrors
        stencilPath.moveTo(cx - w * 0.4, cy - h * 0.1);
        stencilPath.quadraticBezierTo(
          cx - w * 0.48,
          cy - h * 0.15,
          cx - w * 0.48,
          cy - h * 0.08,
        );
        stencilPath.moveTo(cx + w * 0.4, cy - h * 0.1);
        stencilPath.quadraticBezierTo(
          cx + w * 0.48,
          cy - h * 0.15,
          cx + w * 0.48,
          cy - h * 0.08,
        );
      } else if (stencilType == StencilType.carSide) {
        // Draw car side shape
        final double cx = width / 2;
        final double cy = height / 2 - 20;
        final double w = width * 0.85;
        final double h = w * 0.4;

        // Front bumper
        stencilPath.moveTo(cx - w * 0.5, cy + h * 0.1);
        // Hood
        stencilPath.quadraticBezierTo(
          cx - w * 0.45,
          cy - h * 0.05,
          cx - w * 0.35,
          cy - h * 0.05,
        );
        // Windshield
        stencilPath.lineTo(cx - w * 0.18, cy - h * 0.4);
        // Roof
        stencilPath.lineTo(cx + w * 0.18, cy - h * 0.4);
        // Rear window
        stencilPath.lineTo(cx + w * 0.32, cy - h * 0.08);
        // Trunk
        stencilPath.lineTo(cx + w * 0.48, cy - h * 0.08);
        // Rear bumper
        stencilPath.lineTo(cx + w * 0.5, cy + h * 0.15);
        stencilPath.lineTo(cx + w * 0.42, cy + h * 0.18);
        // Bottom body line
        stencilPath.lineTo(cx - w * 0.42, cy + h * 0.18);
        stencilPath.close();

        // Wheels
        final double r = w * 0.1;
        stencilPath.addOval(
          Rect.fromCircle(
            center: Offset(cx - w * 0.28, cy + h * 0.18),
            radius: r,
          ),
        );
        stencilPath.addOval(
          Rect.fromCircle(
            center: Offset(cx + w * 0.28, cy + h * 0.18),
            radius: r,
          ),
        );
      } else if (stencilType == StencilType.carTrunk) {
        // Draw car back view with open trunk
        final double cx = width / 2;
        final double cy = height / 2 - 20;
        final double w = width * 0.7;
        final double h = w * 0.7;

        // Bumper/Wheels
        stencilPath.moveTo(cx - w * 0.45, cy + h * 0.3);
        stencilPath.lineTo(cx + w * 0.45, cy + h * 0.3);
        stencilPath.lineTo(cx + w * 0.45, cy + h * 0.1);
        // Open lid guidelines
        stencilPath.lineTo(cx + w * 0.3, cy - h * 0.3);
        stencilPath.lineTo(cx - w * 0.3, cy - h * 0.3);
        stencilPath.lineTo(cx - w * 0.45, cy + h * 0.1);
        stencilPath.close();

        // Interior Trunk cutout box
        stencilPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - w * 0.35, cy - h * 0.05, w * 0.7, h * 0.32),
            const Radius.circular(8),
          ),
        );
      } else if (stencilType == StencilType.seat) {
        // Draw seat silhouette
        final double cx = width / 2;
        final double cy = height / 2 - 30;
        final double w = width * 0.45;
        final double h = w * 1.5;

        // Headrest
        stencilPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - w * 0.3, cy - h * 0.45, w * 0.6, h * 0.18),
            const Radius.circular(16),
          ),
        );

        // Connection bars
        stencilPath.moveTo(cx - w * 0.1, cy - h * 0.28);
        stencilPath.lineTo(cx - w * 0.1, cy - h * 0.24);
        stencilPath.moveTo(cx + w * 0.1, cy - h * 0.28);
        stencilPath.lineTo(cx + w * 0.1, cy - h * 0.24);

        // Backrest
        stencilPath.moveTo(cx - w * 0.4, cy - h * 0.23);
        stencilPath.quadraticBezierTo(
          cx - w * 0.48,
          cy + h * 0.15,
          cx - w * 0.42,
          cy + h * 0.2,
        );
        stencilPath.lineTo(cx + w * 0.42, cy + h * 0.2);
        stencilPath.quadraticBezierTo(
          cx + w * 0.48,
          cy + h * 0.15,
          cx + w * 0.4,
          cy - h * 0.23,
        );
        stencilPath.close();

        // Bottom Cushion
        stencilPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - w * 0.5, cy + h * 0.22, w * 1.0, h * 0.2),
            const Radius.circular(16),
          ),
        );
      }

      canvas.drawPath(stencilPath, linePaint);
      canvas.drawPath(stencilPath, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StencilOverlayPainter oldDelegate) {
    return oldDelegate.stencilType != stencilType;
  }
}
