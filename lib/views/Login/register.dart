/*
import 'package:app_worbun_1k/main.dart';
import 'package:app_worbun_1k/views/Login/registerPassword.dart';
import 'package:flutter/material.dart';

// VISTA DE REGISTRO CORREO

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _checkFields() {
    setState(() {
      _emailController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la altura total de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Oculta el teclado al hacer tap en cualquier parte
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(
              color: Color(0xFF28E7C5),
            ),
          ),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              height: screenHeight, // Asegura que ocupe toda la pantalla
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Únete a la Rumba',
                        style: TextStyle(
                          color: Color(0xFF28E7C5),
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Color(0xFF28E7C5),
                          fontSize: 23,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correo electrónico',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'ejemplo@gmail.com',
                          filled: true,
                          fillColor: Colors.white,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                  // Botón "Crear Cuenta"
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 1),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            width: 2,
                            color: Colors.transparent,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB6FF00),
                              Color(0xFF6942E2),
                              Color(0xFF28E7C5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RegisterPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ya tienes una cuenta?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp2()),
                          );
                        },
                        child: GradientText(
                          ' Iniciar sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          gradient: LinearGradient(
                            colors: [Color(0xFF6942E2), Color(0xFF28E7C5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ));
  }
}

//TEXTO CON GRADIENTE

class GradientText extends StatelessWidget {
  GradientText(
    this.text, {
    required this.gradient,
    required this.style,
  });

  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
*/