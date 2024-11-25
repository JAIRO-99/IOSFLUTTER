import 'package:Rumba/views/Login/CodeVerificacion2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailRecuperationScreen extends StatefulWidget {
  @override
  _EmailRecuperationScreenState createState() =>
      _EmailRecuperationScreenState();
}

class _EmailRecuperationScreenState extends State<EmailRecuperationScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // Controla si se está realizando la solicitud

  void _checkFields() {
    setState(() {
      _emailController.text.isNotEmpty;
    });
  }

  Future<void> _sendPasswordResetRequest(String email) async {
    setState(() {
      _isLoading = true; // Inicia la carga
    });

    final url = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/password/request-reset?email=$email');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Navegar a la siguiente pantalla si la solicitud es exitosa
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CodeVerificacion2(email: email)),
        );
      } else {
        // Mostrar un mensaje de error si la solicitud falla
        _showErrorMessage('Error al enviar la solicitud. Inténtalo de nuevo.');
      }
    } catch (e) {
      // Manejar errores de conexión
      _showErrorMessage('Error de conexión. Verifica tu red.');
      print('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false; // Finaliza la carga
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Color(0xFF28E7C5),
        ),
      ),
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
                    'Recuperación de contraseña',
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
                  SizedBox(height: 20),
                ],
              ),
              // Reemplazar el botón con un ProgressIndicator si está cargando
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 1),
                child: SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF28E7C5),
                          ),
                        )
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
                            onPressed: () {
                              final email = _emailController.text;
                              if (email.isNotEmpty) {
                                _sendPasswordResetRequest(email);
                              } else {
                                _showErrorMessage(
                                    'Por favor, ingresa un correo válido.');
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
    );
  }
}
