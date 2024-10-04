import 'package:app_worbun_1k/crossplatform/AppDatabase.dart';
import 'package:app_worbun_1k/views/Home/tabBar.dart';
import 'package:app_worbun_1k/views/Login/EmailRecuperationScreen.dart';
import 'package:app_worbun_1k/views/Login/registerPassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false; // Indica si la solicitud de login está en progreso
  bool _obscurePassword = true; // Indica si la contraseña está oculta o visible

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Muestra el ProgressView cuando empieza el login
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    final url = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/auth/login?email=$email&password=$password');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final String token = response.body;
        print('Login exitoso. Token: $token');
        await _fetchRoomCodeAndSave(email); // Obtener y guardar roomCode
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TabBarApp(email: email)),
        );
      } else {
        _showErrorMessage('Credenciales incorrectas. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showErrorMessage('Error de conexión. Verifica tu red.');
    } finally {
      setState(() {
        _isLoading = false; // Oculta el ProgressView cuando finaliza el login
      });
    }
  }

  // Obtener el roomCode del usuario y guardarlo en la base de datos
  Future<void> _fetchRoomCodeAndSave(String email) async {
    final url = Uri.parse('https://rumba-music2.azurewebsites.net/api/rooms/roomcode/$email');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String roomCode = data['roomCode'];

        print('Room Code obtenido: $roomCode');
        
        // Guardar las credenciales (email, token vacío por ahora, y roomCode)
        await AppDatabase().saveCredentials('', email, roomCode);
      } else {
        print('Error al obtener el Room Code.');
      }
    } catch (e) {
      print('Error de conexión al obtener el Room Code: $e');
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
    _passwordController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Color(0xFF28E7C5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  height: screenHeight,
                  padding: const EdgeInsets.all(35.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 288,
                            height: 182,
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                      Text(
                        'Hola, bienvenido de nuevo!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 68,
                            left: 15,
                            right: 12,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFB6FF00),
                                borderRadius: BorderRadius.circular(60),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 15,
                            right: 12,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFB6FF00),
                                borderRadius: BorderRadius.circular(60),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: TextField(
                                  controller: _emailController,
                                  enabled: !_isLoading, // Deshabilita el TextField si está cargando
                                  decoration: InputDecoration(
                                    labelText: 'Correo Electrónico',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 226, 229, 229),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(60),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(Icons.email),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: TextField(
                                  controller: _passwordController,
                                  enabled: !_isLoading, // Deshabilita el TextField si está cargando
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 226, 229, 229),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(60),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  obscureText: _obscurePassword,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment(0.8, 0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EmailRecuperationScreen()),
                            );
                          },
                          child: GradientText(
                            ' Olvidaste la contraseña?',
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
                      ),
                      SizedBox(height: 20),
                      if (_isLoading) // Muestra el ProgressView mientras se carga
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF28E7C5),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 10.0,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                width: 2,
                                color: _isButtonEnabled
                                    ? Colors.transparent
                                    : Colors.white,
                              ),
                              gradient: _isButtonEnabled
                                  ? LinearGradient(
                                      colors: [
                                        Color(0xFFB6FF00),
                                        Color(0xFF6942E2),
                                        Color(0xFF28E7C5),
                                      ],
                                    )
                                  : null,
                            ),
                            child: ElevatedButton(
                              onPressed: _isButtonEnabled && !_isLoading
                                  ? _login
                                  : null, // Deshabilita el botón si está cargando
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isButtonEnabled
                                    ? Colors.transparent
                                    : Colors.black,
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
                            'Nuevo usuario?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterPasswordScreen()),
                              );
                            },
                            child: GradientText(
                              ' Regístrate',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// TEXTO CON GRADIENTE

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
