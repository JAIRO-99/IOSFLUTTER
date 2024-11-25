import 'package:Rumba/crossplatform/AppDatabase.dart';
import 'package:Rumba/views/Home/principalView.dart';
import 'package:Rumba/views/Home/tabBar.dart';
import 'package:Rumba/views/Login/registerPassword.dart';
import 'package:flutter/material.dart';
import 'views/Login/login.dart';
import 'views/Login/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp2());
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  Future<Map<String, dynamic>?> _checkCredentials() async {
    // Obtener las credenciales desde la base de datos
    final credentials = await AppDatabase().getCredentials();
    return credentials;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _checkCredentials(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          // Mientras se cargan los datos mostramos un spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Si hay un error al obtener los datos, mostramos un mensaje
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error al cargar las credenciales"),
              ),
            );
          }

          // Si las credenciales existen, redirigimos a TabBarApp
          if (snapshot.hasData && snapshot.data != null) {
            final String email = snapshot.data!['email'] ?? '';
            if (email.isNotEmpty) {
              return TabBarApp(email: email);
            }
          }

          // Si no hay credenciales, mostrar la pantalla principal (MyApp2)
          return Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/rumba.png',
                            width: 270,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Bienvenido!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(height: 40),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 30),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
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
                                                  LoginScreen()),
                                        );
                                      },
                                      child: const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
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
                                        'Crear cuenta',
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
                                          borderRadius:
                                              BorderRadius.circular(60),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 150),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
