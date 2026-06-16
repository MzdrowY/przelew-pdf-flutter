import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme_colors.dart';

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
    final colors = context.appColors;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.backgroundTop, colors.backgroundBottom, colors.backgroundTop],
            ),
          ),
        ),
        if (colors.useAurora) ...[
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
                        colors: [
                          i == 0 ? colors.primary.withValues(alpha: .12) :
                          i == 1 ? colors.accent.withValues(alpha: .10) :
                          colors.primarySoft.withValues(alpha: .08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Container(
            decoration: BoxDecoration(
              color: colors.backgroundTop.withValues(alpha: .30),
            ),
          ),
        ] else ...[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surface.withValues(alpha: .15),
                  colors.backgroundTop,
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
