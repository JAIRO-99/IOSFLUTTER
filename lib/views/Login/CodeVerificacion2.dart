import 'package:Rumba/views/Login/Recuperationpassword2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CodeVerificacion2 extends StatefulWidget {
  final String email;

  CodeVerificacion2({required this.email});

  @override
  _CodeVerificacion2State createState() => _CodeVerificacion2State();
}

class _CodeVerificacion2State extends State<CodeVerificacion2> {
  final TextEditingController _codeConfirm = TextEditingController();
  bool _isLoading = false; // Controlador para mostrar el ProgressIndicator

  void _checkFields() {
    setState(() {
      _codeConfirm.text.isNotEmpty;
    });
  }

  Future<void> _verifyCode(String email, String code) async {
    setState(() {
      _isLoading = true; // Activa el indicador de carga
    });

    final url = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/password/verify-code?email=$email&code=$code');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Código verificado con éxito, navegar a la siguiente pantalla
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Recuperationpassword2(email: email, code: code)),
        );
      } else {
        _showErrorMessage(
            'Código de verificación incorrecto. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showErrorMessage('Error de conexión. Verifica tu red.');
      print('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false; // Desactiva el indicador de carga
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
    _codeConfirm.addListener(_checkFields);
  }

  @override
  void dispose() {
    _codeConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            height: screenHeight,
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Verificación',
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
                      enabled:
                          !_isLoading, // Deshabilita el campo si _isLoading es true
                    ),
                    SizedBox(height: 10),
                  ],
                ),
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
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF28E7C5),
                              ),
                            ) // Muestra el indicador de progreso
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
                                  final code = _codeConfirm.text;
                                  if (code.isNotEmpty) {
                                    _verifyCode(widget.email, code);
                                  } else {
                                    _showErrorMessage(
                                        'Por favor, ingresa el código de verificación.');
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
