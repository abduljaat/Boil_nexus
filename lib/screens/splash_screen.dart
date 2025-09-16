import 'dart:math'; // Import for sin
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Renamed to match user's code
class TechPulseSplashScreen extends StatefulWidget {
  const TechPulseSplashScreen({Key? key}) : super(key: key); // Use super.key

  @override
  _TechPulseSplashScreenState createState() => _TechPulseSplashScreenState();
}

class _TechPulseSplashScreenState extends State<TechPulseSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.elasticOut),
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue[900], // Using colors from user code
      end: Colors.blueAccent,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        final user = FirebaseAuth.instance.currentUser;
        final prefs = await SharedPreferences.getInstance();
        final hasLocalUser = prefs.getString('user_uid') != null && prefs.getString('user_uid')!.isNotEmpty;
        if (user != null && hasLocalUser) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Keep dark background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated wave visualization
                SizedBox(
                  width: 200,
                  height: 120,
                  child: CustomPaint(
                    painter: _WavePainter(
                      progress: _waveAnimation.value,
                      color: _colorAnimation.value ?? Colors.blueAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Main title with pulse effect
                Transform.scale(
                  scale: _textScaleAnimation.value,
                  child: Text(
                    'BOILNEXUS', // Changed text to match app name
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: _colorAnimation.value?.withOpacity(0.5) ??
                              Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle with fade-in
                Opacity(
                  opacity: _controller.value,
                  child: const Text(
                    'Industrial Process Control', // Changed subtitle
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Animated loading indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _colorAnimation.value ?? Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// CustomPainter for the wave effect
class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final waveHeight = size.height * 0.4;
    final baseLine = size.height * 0.6;

    final path = Path();
    path.moveTo(0, baseLine);

    for (double i = 0; i < size.width; i++) {
      final x = i;
      // Use sin for wave calculation
      final y = baseLine -
          sin((i / size.width * 2 * pi) + progress * 2 * pi) * // Use pi constant
          waveHeight * progress;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw progress indicator (area below wave)
    final indicatorPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final indicatorPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width, baseLine) // Line across baseline
      ..lineTo(size.width, size.height) // Line down right
      ..lineTo(0, size.height) // Line across bottom
      ..lineTo(0, baseLine) // Line up left
      ..close();

    canvas.drawPath(indicatorPath, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}