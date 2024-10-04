import 'package:app_worbun_1k/crossplatform/AppDatabase.dart';
import 'package:app_worbun_1k/views/Home/djViews/loadingDjView.dart';
import 'package:flutter/material.dart';
import 'package:app_worbun_1k/crossplatform/Song.dart';
import 'package:app_worbun_1k/crossplatform/SongService.dart';
import 'package:ntp/ntp.dart';
import 'dart:convert'; // Para manejar JSON
import 'dart:typed_data'; // Para usar Uint8List
import 'package:web_socket_channel/io.dart'; // WebSocket
import 'package:http/http.dart' as http;

class Controlmusicview extends StatefulWidget {
  @override
  _ControlmusicviewState createState() => _ControlmusicviewState();
}

class _ControlmusicviewState extends State<Controlmusicview> {
  String roomCode = ''; // Inicialmente vacío
  

  @override
  void initState() {
    super.initState();
    _loadRoomCode(); // Llamada para cargar el valor de la base de datos.
  }

  Future<void> _loadRoomCode() async {
    // Instancia de la base de datos
    final db = AppDatabase();

    // Obtener credenciales
    final credentials = await db.getCredentials();

    // Si existen credenciales, asigna el valor de accessCode a roomCode
    if (credentials != null && credentials['accessCode'] != null) {
      setState(() {
        roomCode = credentials['accessCode']; // Asigna el valor obtenido
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF28E7C5),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Rectángulo con dos colores e imagen encima, ignorando la zona segura
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: screenHeight *
                0.5, // Ajuste para que el rectángulo ocupe la parte superior
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6942E2), Color(0xFF28E7C5)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/djLogo.png',
                  width: 340,
                  height: 340,
                ),
              ),
            ),
          ),

          // Texto "ALOJA" en el centro con fondo negro y bordes degradados
          Align(
            alignment: Alignment(0, -0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90.0),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6942E2), Color(0xFF28E7C5)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black, // Fondo negro para el texto
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Center(
                    child: Text(
                      roomCode.isNotEmpty
                          ? roomCode
                          : 'Cargando...', // Muestra 'Cargando...' si roomCode está vacío
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Texto y botón en la parte inferior
          Align(
            alignment: Alignment(0, 0.5),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ahora tu controlas la música, comparte tu código.', // Mostrar roomCode
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6942E2), Color(0xFF28E7C5)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoadingDjView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Que empiece la Rumba',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

