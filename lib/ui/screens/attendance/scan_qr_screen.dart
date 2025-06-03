import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'scan_qr_provider.dart';
import 'dart:ui';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanQrProvider>(context, listen: false).reset();
    });

    // Initialize animation for scanning line
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ScanQrProvider>(
        builder: (context, provider, _) {
          if (provider.status == ScanQrStatus.loading) {
            return _buildLoadingState();
          } else if (provider.status == ScanQrStatus.success) {
            return _buildSuccessState(provider);
          } else if (provider.status == ScanQrStatus.error) {
            return _buildErrorState(provider);
          }

          return Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && _isScanning) {
                    _isScanning = false;
                    final String code = barcodes.first.rawValue ?? '';
                    _processQrCode(code);
                  }
                },
              ),
              _buildScannerOverlay(),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Scan QR Code Presensi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScannerOverlay() {
    final double scanAreaSize = MediaQuery.of(context).size.width * 0.7;
    final double left = (MediaQuery.of(context).size.width - scanAreaSize) / 2;
    final double top = (MediaQuery.of(context).size.height - scanAreaSize) / 2;

    return Stack(
      children: [
        // Blur effect for the outer area
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
            ),
          ),
        ),
        // Clear scan area by clipping
        Positioned(
          left: left,
          top: top,
          width: scanAreaSize,
          height: scanAreaSize,
          child: ClipRect(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && _isScanning) {
                  _isScanning = false;
                  final String code = barcodes.first.rawValue ?? '';
                  _processQrCode(code);
                }
              },
            ),
          ),
        ),
        // Scanner overlay with animation
        CustomPaint(
          painter: ScannerOverlayPainter(),
          child: AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned(
                    top: top + (_scanLineAnimation.value * scanAreaSize),
                    left: left,
                    width: scanAreaSize,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade200, Colors.blue.shade600],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Text(
                'Memproses QR Code...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(ScanQrProvider provider) {
    final isCheckIn = provider.attendance?.checkOutTime == null;

    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCheckIn ? Icons.login : Icons.logout,
                color: Colors.green.shade400,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                isCheckIn ? 'Check-In Berhasil' : 'Check-Out Berhasil',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ScanQrProvider provider) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memproses QR Code',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ?? 'Terjadi kesalahan tidak diketahui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: Colors.blue.shade600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.reset();
                        _isScanning = true;
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processQrCode(String code) async {
    if (code.isEmpty) {
      _showErrorDialog('QR Code tidak valid');
      return;
    }

    try {
      final provider = Provider.of<ScanQrProvider>(context, listen: false);
      await provider.scanQrCode(code);
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Error',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isScanning = true;
                  });
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.blue),
                ),
              ),
            ],
          ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    final scanArea = Rect.fromLTRB(left, top, right, bottom);

    // Draw border for scan area
    final borderPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ).createShader(scanArea)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    canvas.drawRect(scanArea, borderPaint);

    final cornerSize = scanAreaSize * 0.1;
    final cornerPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade700],
          ).createShader(scanArea)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0;

    // Draw corners with gradient
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerSize)
        ..lineTo(left, top)
        ..lineTo(left + cornerSize, top),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerSize, top)
        ..lineTo(right, top)
        ..lineTo(right, top + cornerSize),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerSize)
        ..lineTo(left, bottom)
        ..lineTo(left + cornerSize, bottom),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerSize, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, bottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
