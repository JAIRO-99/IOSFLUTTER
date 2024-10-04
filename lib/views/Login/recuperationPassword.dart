import 'package:flutter/material.dart';

class Recuperationpassword extends StatefulWidget {
  @override
  _RecuperationPasswordScreenState createState() =>
      _RecuperationPasswordScreenState();
}

class _RecuperationPasswordScreenState extends State<Recuperationpassword> {
  final TextEditingController _passwordRecuperationController =
      TextEditingController();
  final TextEditingController _passwordRecuperationConfirm =
      TextEditingController();

  void _checkFields() {
    setState(() {
      _passwordRecuperationController.text.isNotEmpty &&
          _passwordRecuperationConfirm.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordRecuperationController.addListener(_checkFields);
    _passwordRecuperationConfirm.addListener(_checkFields);
  }

  @override
  void dispose() {
    _passwordRecuperationController.dispose();
    _passwordRecuperationConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Títulos
                    Column(
                      children: [
                        Text(
                          'Recuperación de contraseña',
                          style: TextStyle(
                            color: Color(0xFF28E7C5),
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Contraseña
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nueva contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordRecuperationController,
                      decoration: InputDecoration(
                        labelText: 'Debe tener 8 caracteres',
                        filled: true,
                        fillColor: Colors.white,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),

                    // Confirmar Contraseña
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Confirmar contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordRecuperationController,
                      decoration: InputDecoration(
                        labelText: 'Repetir contraseña',
                        filled: true,
                        fillColor: Colors.white,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),

                    SizedBox(height: 20),

                    // Botón "Continuar"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 50),
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
                              print('push');
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
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
