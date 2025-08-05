import 'package:flutter/material.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _imageReady = false;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Navigate to login after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Preload image (though not used anymore, kept for consistency)
    precacheImage(const AssetImage('assets/logo.png'), context).then((_) {
      setState(() {
        _imageReady = true;
      });

      // Slight delay before starting fade-in
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              Color(0xFFE91E63), // Slightly darker pink
            ],
          ),
        ),
        child: Center(
          child:
              _imageReady
                  ? AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // App name
                        const Text(
                          'POWER GAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          'Energy Solutions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Loading indicator
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.3),
                        highlightColor: Colors.white,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.7),
                        highlightColor: Colors.white,
                        child: const Text(
                          'POWER GAS',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.5),
                        highlightColor: Colors.white,
                        child: Text(
                          'Energy Solutions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class AnimatedLogo extends StatefulWidget {
  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> starPositions = [];
  static const int starCount = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {
        if (_controller.value < 0.5) {
          // Random movement phase
          starPositions = List.generate(
            starCount,
            (index) => Offset(
              math.Random().nextDouble() * 200,
              math.Random().nextDouble() * 100,
            ),
          );
        } else {
          // Organize into "POWER GAS" shape
          starPositions = calculatePowerGasPositions();
        }
      });
    });
    _controller.repeat();
    starPositions = List.generate(
      starCount,
      (index) => Offset(
        math.Random().nextDouble() * 200,
        math.Random().nextDouble() * 100,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Use min to fit content
      children: [
        SizedBox(
          width: 200,
          height: 100, // Adjusted to fit stars
          child: CustomPaint(painter: StarPainter(starPositions)),
        ),
        const SizedBox(height: 10), // Reduced spacing
        Shimmer.fromColors(
          baseColor: Colors.green,
          highlightColor: Colors.lightGreenAccent,
          period: const Duration(milliseconds: 1500),
          child: const Text(
            'Rafiki Jikoni',
            style: TextStyle(
              fontSize: 20, // Reduced font size to fit
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  List<Offset> calculatePowerGasPositions() {
    const letters = "POWER GAS";
    final positions = <Offset>[];
    const double letterWidth = 20.0;
    const double startX = 0.0;
    double x = startX;
    double y = 50.0;

    for (int i = 0; i < letters.length; i++) {
      if (letters[i] == ' ') {
        x += letterWidth;
        continue;
      }
      for (int j = 0; j < starCount ~/ letters.length; j++) {
        positions.add(
          Offset(
            x + (math.Random().nextDouble() - 0.5) * letterWidth / 2,
            y + (math.Random().nextDouble() - 0.5) * 20,
          ),
        );
      }
      x += letterWidth;
    }
    return positions;
  }
}

class StarPainter extends CustomPainter {
  final List<Offset> starPositions;

  StarPainter(this.starPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var pos in starPositions) {
      final path = Path();
      path.moveTo(pos.dx, pos.dy - 5);
      path.lineTo(pos.dx + 5, pos.dy + 5);
      path.lineTo(pos.dx - 5, pos.dy + 5);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
