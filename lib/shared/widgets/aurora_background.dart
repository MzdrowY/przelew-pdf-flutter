import 'dart:math';
import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;
  final _baseDx = <double>[];
  final _baseDy = <double>[];
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    const count = 3;
    _controllers = List.generate(count, (i) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(seconds: 15 + i * 5),
      );
      c.repeat(reverse: true);
      return c;
    });
    for (var i = 0; i < count; i++) {
      _baseDx.add(_rnd.nextDouble() * 200);
      _baseDy.add(_rnd.nextDouble() * 150);
    }
    _animations = List.generate(count, (i) {
      return Tween<Offset>(begin: const Offset(-0.2, 0), end: const Offset(0.3, 0.4))
          .animate(_controllers[i]);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0x3F7C75FF).withValues(alpha: .12), // primary purple
      const Color(0x3F4ECDC4).withValues(alpha: .10), // teal
      const Color(0x3F9D97FF).withValues(alpha: .08), // soft purple
    ];

    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF07070F),
                Color(0xFF0C0C18),
                Color(0xFF080812),
              ],
            ),
          ),
        ),
        // Animated colored blobs
        ...List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (context, child) {
              return Positioned(
                left: _baseDx[i] + (_animations[i].value.dx * 300),
                top: _baseDy[i] + (_animations[i].value.dy * 200),
                child: Container(
                  width: 250 + i * 50.0,
                  height: 250 + i * 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [colors[i], Colors.transparent],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        // Subtle noise/texture overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .30),
          ),
        ),
      ],
    );
  }
}
