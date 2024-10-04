import 'package:app_worbun_1k/views/Login/CodeVerificacion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPasswordScreen extends StatefulWidget {
  @override
  _RegisterPasswordScreenState createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  final TextEditingController _codeConfirm = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _checkFields() {
    setState(() {
      _passwordController.text.isNotEmpty &&
          _passwordConfirm.text.isNotEmpty &&
          _codeConfirm.text.isNotEmpty;
    });
  }

  void _registerUser() async {
    final email = _codeConfirm.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Manejar error de campos vacíos
      print('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true; // Mostrar ProgressView
    });

    final url = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/auth/register?email=$email&password=$password');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Usuario registrado correctamente
        print('Usuario registrado exitosamente.');
        print(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodeVerificacion(email: email),
          ),
        );
      } else {
        // Mostrar alerta en caso de error
        _showErrorDialog();
        print('Error al registrar el usuario: ${response.body}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    } finally {
      setState(() {
        _isLoading = false; // Ocultar ProgressView cuando termine la solicitud
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Datos incorrectos, intente de nuevo.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar la alerta
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkFields);
    _passwordConfirm.addListener(_checkFields);
    _codeConfirm.addListener(_checkFields);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirm.dispose();
    _codeConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Oculta el teclado al hacer tap fuera de los TextFields
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
          child: Stack(
            children: [
              SingleChildScrollView(
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
                      SizedBox(height: 20),

                      // Correo
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
                        controller: _codeConfirm,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'example: Email@gmail.com',
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

                      // Contraseña
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Crea una contraseña',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: !_isPasswordVisible,
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
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
                        controller: _passwordConfirm,
                        enabled: !_isLoading,
                        obscureText: !_isConfirmPasswordVisible,
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
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
                              onPressed: _isLoading ? null : _registerUser,
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
                    ],
                  ),
                ),
              ),

              // Mostrar ProgressView cuando esté cargando
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF28E7C5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
