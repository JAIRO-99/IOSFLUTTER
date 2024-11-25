import 'package:Rumba/crossplatform/AppDatabase.dart';
import 'package:Rumba/views/Login/ApiService.dart';
import 'package:Rumba/views/Login/CodePromotional/PromoCodeScreen.dart';
import 'package:Rumba/views/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CodeVerificacion extends StatefulWidget {
  final String email; // Recibe el correo

  CodeVerificacion({required this.email}); // Constructor que recibe el correo

  @override
  _CodeVerificacionState createState() => _CodeVerificacionState();
}

class _CodeVerificacionState extends State<CodeVerificacion> {
  final TextEditingController _codeConfirm = TextEditingController();

  ApiService apiService = ApiService();
  bool _isLoading =
      false; // Para mostrar un indicador de carga mientras se verifica

  void _checkFields() {
    setState(() {
      _codeConfirm.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _saveCurrentScreen();
    _codeConfirm.addListener(_checkFields);
  }

  Future<void> _saveCurrentScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isInCodeVerification', true);
  }

  @override
  void dispose() {
    _codeConfirm.dispose();
    super.dispose();
  }

  // Método para mostrar la alerta
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Importante'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Método para verificar el código
  Future<void> _verifyCode() async {
    final String code = _codeConfirm.text;
    final String email = widget.email; // Correo recibido en el widget

    if (code.isEmpty) {
      print('Por favor, ingresa el código.');
      return;
    }

    final url = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/auth/verify-email?email=$email&code=$code');

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      // Realizar la solicitud POST
      final response = await http.post(url).timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        await apiService
            .registerUser(email); // Registra el usuario como DJ PROBANDO
        int? djId =
            await apiService.getDjIdByEmail(email); // Obtiene el ID del DJ
        int? roomCode =
            await apiService.createRoomForDj(djId!); // Crea una sala para el DJ

        await AppDatabase().saveCredentials('', email, roomCode.toString());

        // Verificación exitosa, redirigir al login
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromoCodeScreen(
              email: email,
            ), // Redirige a PromoCodeScreen pasando el email
          ),
        );

        setState(() {
          _isLoading = false; // Ocultar indicador de carga
        });
      } else {
        // Mostrar alerta si el código es incorrecto
        _showAlert('Código incorrecto');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
      print('Error al realizar la solicitud: $e');
      _showAlert('Error en la solicitud, intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Oculta el teclado al hacer tap
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
                      'Verificación de registro',
                      style: TextStyle(
                        color: Color(0xFF28E7C5),
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
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
                        'Por favor ingresa el código enviado a ${widget.email}. El mensaje podría estar en la carpeta de spam.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Código de verificación',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _codeConfirm,
                      decoration: InputDecoration(
                        labelText: 'Código de verificación',
                        filled: true,
                        fillColor: Colors.white,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 1),
                  child: SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? CircularProgressIndicator() // Indicador de carga mientras se verifica
                        : Container(
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
                              onPressed: _verifyCode, // Verificar código
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
    );
  }
}
