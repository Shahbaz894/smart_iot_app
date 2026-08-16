import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/app/routes.dart';
import 'package:smart_iot_app/src/core/constant/storage/auth_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 1.0, curve: Curves.bounceIn),
      ),
    );

    _controller.forward();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Keeps splash visible during animations
    await Future.delayed(const Duration(milliseconds: 2500));

    final authStorage = AuthStorage();
    final isLoggedIn = await authStorage.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.devices);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safe responsive dimensions extracting only the size object
    final screenSize = MediaQuery.sizeOf(context);
    final isShortScreen = screenSize.height < 650;

    // Scale image container fluidly relative to screen width/height
    final imageDimension = (screenSize.width * 0.55).clamp(160.0, 240.0);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Panel
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A), // Premium Dark Deep Blue
                  Color(0xFF0D1B2A), // Soft Midnight Accent
                ],
              ),
            ),
          ),

          // Technical Layer Overlay: Subtle visual aesthetics
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          ),

          // Main Responsive Content Body
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Centered Device Graphic Group
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Center(
                        child: Container(
                          height: imageDimension,
                          width: imageDimension,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(120),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.12),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child:
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: CircleAvatar(
                                radius: 150,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 400,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: const AssetImage(
                                    "assets/images/aabnex_device.jpeg",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isShortScreen ? 24 : 40),

                    // Brand Typography Text Section
                    const Text(
                      "AabNex",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Smart Water Management System",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.70),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Loading Indicator Area
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: screenSize.width * 0.35,
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.white10,
                            color: Color(0xFF00E5FF), // Clean Neon Cyan Accent
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Securing Connection...",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom background aesthetic overlay representing an automated grid system
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}