import 'package:app_worbun_1k/views/Login/recuperationPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VerificationScreen(),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Oculta el teclado al hacer tap en cualquier parte
      },
      child: Scaffold(
        backgroundColor: Colors.black, // Fondo negro para toda la vista
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Color(0xFF28E7C5),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // Separar las partes
            children: [
              // Primera parte: Subtítulos y explicación
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Recuperar contraseña",
                    style: TextStyle(
                      color: Color(0xFF28E7C5),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Coloque el código de recuperación para poder recuperar contraseña",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              // Segunda parte: Imagen de Perú, código de país y TextField
              Column(
                children: [
                  SizedBox(height: 10),
                  // Línea blanca inferior
                  Divider(color: Colors.white),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Divider(color: Colors.white),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Solo números
                            LengthLimitingTextInputFormatter(
                                5), // Limita a 5 dígitos
                          ],
                          decoration: InputDecoration(
                            hintText: "0 0 0 0 0",
                            hintStyle: TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor:
                                Colors.black, // Fondo gris oscuro del TextField
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white),
                ],
              ),

              // Tercera parte: Botón de continuar con fondo degradado de 3 colores
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB6FF00), // Color 1
                          Color(0xFF6942E2), // Color 2
                          Color(0xFF28E7C5), // Color 3
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Recuperationpassword()),
                        );
                      },
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
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
