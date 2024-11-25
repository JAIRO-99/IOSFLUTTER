import 'package:Rumba/views/control/roomReceptorView.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LoadingReceptorView extends StatefulWidget {
  final int waitTime = 4; // Tiempo de espera

  @override
  _LoadingReceptorViewState createState() => _LoadingReceptorViewState();
}

class _LoadingReceptorViewState extends State<LoadingReceptorView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializamos el controlador de la animación
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true); // Repite la animación de opacidad en reversa

    // Creamos la animación de opacidad que varía entre 0.5 y 1
    _opacityAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

    // Iniciar un temporizador que use el tiempo de espera pasado por parámetro
    Timer(Duration(seconds: widget.waitTime), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoomReceptorView()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar el controlador cuando no se necesite
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro para dar contraste
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/rumba.png', // Reemplaza con tu imagen
                width: 200,
                height: 150, // Tamaño ajustable según tu preferencia
              ),
              SizedBox(height: 20), // Espacio entre imagen y texto
              Text(
                'Rumba en curso',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              SizedBox(height: 10), // Espacio entre los textos
              Text(
                'La sala ya está lista, tus amigos se están uniendo',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
