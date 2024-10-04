import 'dart:math';
import 'package:flutter/material.dart';

// VISTA DE LA R
class Ranimation extends StatefulWidget {
  @override
  _DiscoRAnimationState createState() => _DiscoRAnimationState();
}

class _DiscoRAnimationState extends State<Ranimation>
    with TickerProviderStateMixin {
  late AnimationController _controllerLatido;
  late AnimationController _controller3D;
  late AnimationController _colorControllerLatido;
  late Animation<Color?> _colorAnimationLatido;
  late Animation<Color?> _colorAnimation3D;

  bool _play3DAnimation = false;

  @override
  void initState() {
    super.initState();

    // Controlador para la animación del latido (4 segundos)
    _controllerLatido = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();

    _colorControllerLatido = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimationLatido = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(_colorControllerLatido);

    // Controlador para la animación 3D (6 segundos)
    _controller3D = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _colorAnimation3D = ColorTween(
      begin: Colors.purple,
      end: Colors.green,
    ).animate(_controller3D);

    // Retrasar el inicio de la animación 3D después de 4 segundos
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _play3DAnimation = true;
      });
      _controller3D.repeat();
    });
  }

  @override
  void dispose() {
    _controllerLatido.dispose();
    _controller3D.dispose();
    _colorControllerLatido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _play3DAnimation
            ? _build3DAnimation() // Mostrar animación 3D después de 4 segundos
            : _buildLatidoAnimation(), // Mostrar animación de latido al principio
      ),
    );
  }

  // Animación de latido (4 segundos)
  Widget _buildLatidoAnimation() {
    return AnimatedBuilder(
      animation: _controllerLatido,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _colorControllerLatido,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + sin(_controllerLatido.value * pi),
              child: Opacity(
                opacity: 0.7 + 0.3 * cos(_controllerLatido.value * pi),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: _colorAnimationLatido.value!,
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/whiteR.png', // Asegúrate de usar tu imagen de la "R"
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Animación 3D y efectos (6 segundos)
  Widget _build3DAnimation() {
    return AnimatedBuilder(
      animation: _controller3D,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateX(_controller3D.value * 2 * pi) // Rotación eje X
            ..rotateY(_controller3D.value * pi) // Rotación eje Y
            ..rotateZ(_controller3D.value * pi / 2) // Rotación eje Z
            ..translate(sin(_controller3D.value * 2 * pi) * 50, 0, 0),
          child: AnimatedBuilder(
            animation: _controller3D,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: _colorAnimation3D.value!,
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: 1.5 + sin(_controller3D.value * pi),
                  child: Opacity(
                    opacity: 0.7 + 0.3 * cos(_controller3D.value * pi),
                    child: Image.asset(
                      'assets/whiteR.png', // Asegúrate de usar tu imagen de la "R"
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
