import 'package:app_worbun_1k/views/Home/djViews/receptorView/loadingReceptorView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomView extends StatefulWidget {
  @override
  _CustomViewState createState() => _CustomViewState();
}

class _CustomViewState extends State<CustomView> {
  String _roomCode = ''; // Almacenar el código ingresado
  int? _djId; // Guardar el ID del DJ después de la búsqueda
  bool _isLoading = false; // Mostrar un indicador de carga

  Future<void> _fetchDjId(String roomCode) async {
    final url =
        'https://backend-crossplatoform-railway-production.up.railway.app/api/rooms/owner-by-roomcode/$roomCode';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int djId = data['id']; // Guardar el ID del DJ
        setState(() {
          _djId = djId;
        });

        // Guardar el ID del DJ y el roomCode en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('djId', djId);
        await prefs.setString('roomCode', roomCode);

        print('Guardado: DJ ID - $djId, Room Code - $roomCode');

        // Navegar a la siguiente pantalla si se obtuvo el DJ ID correctamente
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoadingReceptorView()),
        );
      } else {
        throw Exception('Error al obtener el ID del DJ.');
      }
    } catch (e) {
      print('Error al obtener el DJ ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
                  colors: [Color(0xFFB6FF00), Color(0xFF28E7C5)],
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
                  'assets/hearMusic.png',
                  width: 280,
                  height: 280,
                ),
              ),
            ),
          ),

          // TextField con borde degradado, justo en el centro
          Align(
            alignment: Alignment(0, -0.18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB6FF00), Color(0xFF28E7C5)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                padding: const EdgeInsets.all(3),
                child: TextField(
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                  inputFormatters: [UpperCaseTextFormatter()],
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Escribe tu código',
                    counterText: "",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _roomCode =
                        value; // Actualizar el código con el valor ingresado
                  },
                ),
              ),
            ),
          ),

          // Texto y botón en la parte inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Inserta tu código Rumbero y disfruta con tus amigos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB6FF00), Color(0xFF28E7C5)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null // Deshabilitar el botón si está cargando
                          : () {
                              if (_roomCode.isNotEmpty) {
                                _fetchDjId(
                                    _roomCode); // Llamar al método para obtener el DJ ID
                              } else {
                                print('Por favor, ingresa un código.');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: _isLoading
                            ? CircularProgressIndicator() // Mostrar un indicador de carga
                            : Text(
                                'Que empiece la Rumba',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
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

// Clase para convertir el texto a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(), // Convierte el texto a mayúsculas
      selection: newValue.selection,
    );
  }
}
