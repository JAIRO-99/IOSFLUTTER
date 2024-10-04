import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:app_worbun_1k/crossplatform/SongService.dart'; // Asegúrate de importar SongService
import 'package:app_worbun_1k/crossplatform/Song.dart';

class RoomReceptorView extends StatefulWidget {
  @override
  _RoomReceptorViewState createState() => _RoomReceptorViewState();
}

class _RoomReceptorViewState extends State<RoomReceptorView> {
  final SongService _songService = SongService();
  List<Song> _songs = []; // Lista de canciones obtenidas
  bool _isLoading = true;
  IOWebSocketChannel? _channel; // Conexión de WebSocket

  // Variables para almacenar los datos recuperados de SharedPreferences
  String? _roomCode;
  int? _djId;

  String _fullText = "Obteniendo canciones...";
  String _currentText = "";
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesAndSongs(); // Cargar datos y canciones
    _startTextAnimation();
  }

  void _startTextAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
        // Añadir letra por letra
        _currentText = _fullText.substring(0, _currentIndex + 1);
        _currentIndex++;

        // Si ya se mostró todo el texto, reiniciar el ciclo
        if (_currentIndex == _fullText.length) {
          _currentIndex = 0; // Reiniciar el índice
        }
      });
    });
  }

  // Cargar el djId y roomCode desde SharedPreferences y descargar canciones
  Future<void> _loadSharedPreferencesAndSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _djId = prefs.getInt('djId');
      _roomCode = prefs.getString('roomCode');
    });

    if (_djId != null && _roomCode != null) {
      await _fetchSongsWithRetries(
          _roomCode!, _djId!); // Descargar las canciones
      _connectToWebSocket(_roomCode!); // Conectar al WebSocket
    }
  }

  // Obtener hora sincronizada desde NTP
  Future<DateTime> _getSynchronizedTime() async {
    return await NTP.now();
  }

  // Descargar las canciones usando el roomCode y djId con reintentos
  Future<void> _fetchSongsWithRetries(String roomCode, int djId) async {
    int retryCount = 0;
    const int maxRetries = 3;
    bool success = false;
    await _songService.stopSong();

    while (retryCount < maxRetries && !success) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _fetchSongs(roomCode, djId);
        success = true; // Si la descarga tiene éxito, marcamos como exitosa
      } catch (e) {
        retryCount++;
        print('Error al descargar canciones: Intento $retryCount, Error: $e');

        // Mostrar mensaje flotante de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR DE RED - Intento $retryCount')),
        );

        if (retryCount >= maxRetries) {
          print('Descarga fallida después de $retryCount intentos');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Descargar las canciones usando el roomCode y djId con un tiempo de espera de 3 minutos
  Future<void> _fetchSongs(String roomCode, int djId) async {
    final url =
        'https://rumba-music3.azurewebsites.net/api/rooms/validate-and-filter/$roomCode/$djId';

    try {
      // Agregar un tiempo de espera de 3 minutos (180 segundos)
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(minutes: 3));

      if (response.statusCode == 200) {
        final List<dynamic> songsJson = json.decode(response.body);
        setState(() {
          _songs = songsJson.map((json) => Song.fromJson(json)).toList();
        });
      } else {
        throw Exception(
            'Error al descargar canciones. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error durante la solicitud de canciones: $e');
    }
  }

  // Conectar al WebSocket usando el roomCode
  void _connectToWebSocket(String roomCode) {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://backend-crossplatoform-railway-production.up.railway.app/ws?roomCode=$roomCode'),
    );

    // Escuchar mensajes del WebSocket
    _channel!.stream.listen(
      (message) {
        _onMessageReceived(message);
      },
      onError: (error) {
        print('Error en WebSocket: $error');
      },
      onDone: () {
        print('Conexión WebSocket cerrada.');
      },
    );
  }

  // Manejar los mensajes recibidos por WebSocket para reproducir una canción
  void _onMessageReceived(String message) async {
    var playMessage = jsonDecode(message);
    int songId = int.parse(playMessage['songId']);
    int startTime = int.parse(playMessage['startTime']);
    String action = playMessage['action']; // Obtener la acción (PLAY o STOP)

    Song? songToPlay = _songs.firstWhere(
      (song) => song.id == songId,
      orElse: () => Song.empty(),
    );

    if (songToPlay != null) {
      if (action == 'PLAY') {
        // Obtener la hora sincronizada
        DateTime now = await _getSynchronizedTime();
        int currentTimeMillis = now.millisecondsSinceEpoch;

        // Calcular el tiempo restante hasta la hora de inicio
        int delayMillis = startTime - currentTimeMillis;

        if (delayMillis > 0) {
          // Esperar hasta la hora programada para iniciar la reproducción
          await Future.delayed(Duration(milliseconds: delayMillis));
        }

        await _songService.stopSong(); // Detener la canción actual (si existe)
        await _songService.playSong(songToPlay); // Reproducir la nueva canción
      } else if (action == 'STOP') {
        // Si la acción es STOP, detener la música
        await _songService
            .stopSong(); // Detener cualquier canción que esté reproduciéndose
        print('Canción detenida: ID $songId');
      }
    }
  }

  // Enviar señal de reproducción al WebSocket
  void _sendPlaySignal(int songId) {
    if (_channel != null) {
      final playMessage = jsonEncode({
        'songId': songId.toString(),
        'action': 'PLAY',
      });
      _channel!.sink.add(playMessage);
      print(
          'Se envió la señal de reproducción para la canción con ID: $songId');
    } else {
      print('Error: WebSocket no está conectado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Organizado por ti",
                style: TextStyle(fontSize: 15, color: Color(0xFF28E7C5))),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 4),
              Text(
                "",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 10),
            ],
          )
        ],
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(0xFFB6FF00),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Lista de reproducción",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_roomCode != null && _djId != null) {
                            await _fetchSongsWithRetries(_roomCode!, _djId!);
                          }
                        }, // BOTÓN DE ACTUALIZAR
                  label: Text(
                    "Actualizar",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(Icons.refresh,
                      color: Color.fromARGB(255, 151, 123, 238)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF6942E2), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width:
                              200, // Definir el ancho del CircularProgressIndicator
                          height:
                              200, // Definir la altura del CircularProgressIndicator
                          child:
                              CircularProgressIndicator(), // Indicador de carga circular
                        ), // Indicador de carga circular
                        SizedBox(
                            height:
                                16), // Espacio entre el indicador y el texto
                        Text(
                          _currentText, // Usar el texto dinámico
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                // Mostrar indicador de carga mientras se descargan las canciones
                : Expanded(
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/whiteR.png"), // Cambiar a la imagen correcta
                          ),
                          title: Text(
                            song.name.isNotEmpty ? song.name : "Nombre canción",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Nombre cantante',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _stopSongAndDisconnect() {
    _songService.stopSong();
    _channel?.sink.close();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _stopSongAndDisconnect();
    _timer?.cancel();
    super.dispose();
  }
}
