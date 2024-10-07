import 'package:app_worbun_1k/crossplatform/Song.dart';
import 'package:app_worbun_1k/crossplatform/SongService.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';

class SongListScreen extends StatefulWidget {
  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  List<Song> _songs = [];
  bool _isLoading = false;
  IOWebSocketChannel? _channel; // Conexión de WebSocket
  final SongService _songService = SongService();
  int? _djId;

  // Variables para mostrar en la interfaz
  DateTime? ntpTime;
  int? playbackTime;
  int? timeDifference;

  // Método para obtener el ID del DJ desde el roomCode
  Future<void> _fetchDjId(String roomCode) async {
    final url =
        'https://backend-crossplatoform-railway-production.up.railway.app/api/rooms/owner-by-roomcode/$roomCode';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _djId = data['id']; // Guardamos el ID del DJ
        });
      } else {
        throw Exception('Error al obtener el ID del DJ.');
      }
    } catch (e) {
      print('Error al obtener el DJ ID: $e');
    }
  }

  // Método para descargar canciones y conectar a la sala
  Future<void> _validateAndFetchSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final roomCode = _roomCodeController.text;

      // 1. Obtener el ID del DJ basado en el roomCode
      await _fetchDjId(roomCode);

      if (_djId != null) {
        // 2. Descargar las canciones usando el roomCode y el ID del DJ
        final songs = await _songService.fetchSongs(roomCode, _djId.toString());
        setState(() {
          _songs = songs;
        });

        // 3. Conectar a la sala
        connectToWebSocket();
      } else {
        print('Error: No se pudo obtener el ID del DJ.');
      }
    } catch (e) {
      print(e);
      // Manejar el error de manera adecuada
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void connectToWebSocket() {
    final roomCode = _roomCodeController.text;
    // Conectar usando la URL con roomCode
    _channel = IOWebSocketChannel.connect(
      Uri.parse(
          'wss://backend-crossplatoform-railway-production.up.railway.app/ws?roomCode=$roomCode'),
    );

    // Escuchar mensajes del WebSocket
    _channel!.stream.listen(
      (message) {
        onMessageReceived(message); // Maneja los mensajes recibidos
      },
      onError: (error) {
        print('Error en WebSocket: $error');
      },
      onDone: () {
        print('Conexión WebSocket cerrada.');
      },
    );

    print('Conectado al servidor WebSocket en la sala: $roomCode');
  }

  void onMessageReceived(String message) async {
    print('Mensaje recibido: $message');

    // Parsear el mensaje JSON
    var playMessage = jsonDecode(message);

    // Verifica que el mensaje recibido corresponda al roomCode actual y la acción sea "PLAY"
    if (true) {
      DateTime ntpTimeLocal;
      try {
        ntpTimeLocal = await NTP.now();
      } catch (e) {
        print('Error al obtener la hora del servidor NTP: $e');
        return;
      }

      // Obtener el songId desde el mensaje
      int songId = int.parse(playMessage['songId']);

      // Buscar la canción en la lista de canciones
      Song? songToPlay = _songs.firstWhere(
        (song) => song.id == songId,
        orElse: () => Song.empty(),
      );

      if (songToPlay != null) {
        _songService.playSong(songToPlay);
      } else {
        print('No se encontró la canción con ID: $songId');
      }
    } else {
      print('El mensaje no corresponde al room actual o la acción no es PLAY');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canciones disponibles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomCodeController,
              decoration: InputDecoration(labelText: 'Código de Sala'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateAndFetchSongs,
              child: Text('Validar y Filtrar Canciones'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                          title: Text(song.name),
                          // Se eliminó el botón de "Reproducir"
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _channel?.sink
          .close(); // Cerrar la conexión WebSocket cuando se destruya la pantalla
    } catch (e) {
      print('Error al cerrar el WebSocket: $e');
    }
    super.dispose();
  }
}
