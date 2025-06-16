import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/screens/auth/login_provider.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:telemetri/utils/platform_helper.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Consumer<LoginProvider>(
        builder: (context, auth, _) {
          if (PlatformHelper.isWeb && auth.isAuthenticated && !auth.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.main,
                (route) => false,
              );
            });
          }

          if (auth.isLoading) {
            return _buildLoadingScreen();
          }

          if (PlatformHelper.isWeb) {
            return _buildWebLogin(context, auth);
          } else {
            return _buildMobileLogin(context, auth);
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Signing in...'),
        ],
      ),
    );
  }

  Widget _buildWebLogin(BuildContext context, LoginProvider auth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2147C7), Color(0xFF1a3ba8)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.all(32),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/neo_telemetri_logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Neo Telemetri',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2147C7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Web Application',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),

                  if (auth.error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2147C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed:
                          auth.isLoading
                              ? null
                              : () => _handleGoogleSignIn(context, auth),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Neo Telemetri Web Portal',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLogin(BuildContext context, LoginProvider auth) {
    return Column(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height:
                MediaQuery.of(context).size.height * 0.4 +
                MediaQuery.of(context).padding.top,
            width: double.infinity,
            color: const Color(0xFF2147C7),
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: const Text(
              "Let's get started!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const Spacer(flex: 1),

        Image.asset(
          'assets/images/neo_telemetri_logo.png',
          height: 150,
          fit: BoxFit.contain,
        ),

        const Spacer(flex: 2),

        if (auth.error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Text(
              auth.error!,
              style: TextStyle(color: Colors.red.shade900),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
            ),
            label: const Text(
              "Masuk dengan Akun Google",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2147C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed:
                auth.isLoading
                    ? null
                    : () => _handleGoogleSignIn(context, auth),
          ),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    LoginProvider auth,
  ) async {
    try {
      auth.clearError();

      final success = await auth.signInWithGoogle();

      if (success && context.mounted) {
        await Future.delayed(const Duration(milliseconds: 200));

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.main,
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);

    var gelombangPertamaKiri = Offset(size.width / 4, size.height);
    var gelombangPertamaTengah = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      gelombangPertamaKiri.dx,
      gelombangPertamaKiri.dy,
      gelombangPertamaTengah.dx,
      gelombangPertamaTengah.dy,
    );

    var gelomobangKeduaTengahKanan = Offset(
      size.width - (size.width / 4),
      size.height - 80,
    );
    var gelombangKeduaTengahAkhir = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      gelomobangKeduaTengahKanan.dx,
      gelomobangKeduaTengahKanan.dy,
      gelombangKeduaTengahAkhir.dx,
      gelombangKeduaTengahAkhir.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
