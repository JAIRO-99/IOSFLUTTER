import 'package:app_worbun_1k/views/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Recuperationpassword2 extends StatefulWidget {
  final String email; // Recibir email como parámetro
  final String code; // Recibir código como parámetro

  Recuperationpassword2(
      {required this.email, required this.code}); // Constructor

  @override
  _Recuperationpassword2ScreenState createState() =>
      _Recuperationpassword2ScreenState();
}

class _Recuperationpassword2ScreenState extends State<Recuperationpassword2> {
  final TextEditingController _passwordRecuperationController =
      TextEditingController();
  final TextEditingController _passwordRecuperationConfirm =
      TextEditingController();
  bool _isLoading = false; // Variable para controlar el estado de carga

  void _checkFields() {
    setState(() {
      _passwordRecuperationController.text.isNotEmpty &&
          _passwordRecuperationConfirm.text.isNotEmpty;
    });
  }

  Future<void> _changePassword(
      String email, String code, String newPassword) async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    final url = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/password/change-password');

    final body = jsonEncode({
      "email": email,
      "code": code,
      "newPassword": newPassword,
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Contraseña cambiada exitosamente.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showErrorMessage(
            'Error al cambiar la contraseña. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showErrorMessage('Error de conexión. Verifica tu red.');
      print('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                      enabled: !_isLoading, // Deshabilitar si está cargando
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
                      controller: _passwordRecuperationConfirm,
                      enabled: !_isLoading, // Deshabilitar si está cargando
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

                    // Indicador de carga o botón "Continuar"
                    _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF28E7C5),
                            ),
                          ) // Mostrar indicador de carga
                        : Padding(
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
                                    final newPassword =
                                        _passwordRecuperationController.text;
                                    final confirmPassword =
                                        _passwordRecuperationConfirm.text;

                                    if (newPassword != confirmPassword) {
                                      _showErrorMessage(
                                          'Las contraseñas no coinciden.');
                                    } else if (newPassword.length < 8) {
                                      _showErrorMessage(
                                          'La contraseña debe tener al menos 8 caracteres.');
                                    } else {
                                      // Hacer la solicitud para cambiar la contraseña
                                      _changePassword(widget.email, widget.code,
                                          newPassword);
                                    }
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
