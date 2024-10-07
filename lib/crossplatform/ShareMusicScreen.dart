import 'package:app_worbun_1k/crossplatform/AppDatabase.dart';
import 'package:app_worbun_1k/crossplatform/Song.dart';
import 'package:app_worbun_1k/crossplatform/SongService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para manejar JSON
import 'dart:typed_data'; // Para usar Uint8List
import 'package:web_socket_channel/io.dart';

class ShareMusicScreen extends StatefulWidget {
  @override
  _ShareMusicScreenState createState() => _ShareMusicScreenState();
}

class _ShareMusicScreenState extends State<ShareMusicScreen> {
  String _selectedSongTitle = 'No hay canción seleccionada';
  int _selectedDjId = 0;
  Uint8List? _musicData;
  final SongService _songService = SongService();
  List<Song> _songs = [];
  bool _isLoading = false;
  IOWebSocketChannel? _channel; // Conexión de WebSocket

  // Variables para almacenar los datos recuperados de la base de datos
  String? _token;
  String? _email;
  String? _accessCode;

  // Método para cargar los datos desde la base de datos
  Future<void> _loadCredentialsFromDatabase() async {
    final credentials = await AppDatabase().getCredentials();

    if (credentials != null) {
      setState(() {
        _token = credentials['token'];
        _email = credentials['email'];
        _accessCode = credentials['accessCode'];
      });

      // Llamamos al método para obtener el ID del DJ usando el correo
      if (_email != null) {
        await _fetchDjId(_email!);
      }

      // Conectamos a la sala WebSocket usando el accessCode (roomCode)
      if (_accessCode != null) {
        await _fetchSongs(_accessCode!, _selectedDjId);
        await _connectToWebSocket(_accessCode!);
      }
    }
  }

  // Método para obtener el ID del DJ desde el backend
  Future<void> _fetchDjId(String email) async {
    final url =
        'https://backend-crossplatoform-railway-production.up.railway.app/api/users/search/$email';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedDjId = data['id'];
        });
      } else {
        throw Exception(
            'No se pudo encontrar el DJ con el correo proporcionado.');
      }
    } catch (e) {
      print('Error obteniendo el DJ ID: $e');
    }
  }

  // Conectar a la sala usando el roomCode (accessCode)
  Future<void> _connectToWebSocket(String roomCode) async {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(
          'wss://backend-crossplatoform-railway-production.up.railway.app/ws?roomCode=$roomCode'),
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

    print('Conectado al servidor WebSocket en la sala: $roomCode');
  }

  // Método para manejar mensajes recibidos por WebSocket
  void _onMessageReceived(String message) {
    print('Mensaje recibido: $message');
    var playMessage = jsonDecode(message);

    int songId = int.parse(playMessage['songId']);

    Song? songToPlay = _songs.firstWhere(
      (song) => song.id == songId,
      orElse: () => Song.empty(),
    );

    if (songToPlay != null) {
      _songService.playSong(songToPlay);
    } else {
      print('No se encontró la canción con ID: $songId');
    }
  }

  // Método para descargar las canciones desde el backend
  Future<void> _fetchSongs(String roomCode, int djId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await _songService.fetchSongs(roomCode, djId.toString());
      setState(() {
        _songs = songs;
      });
    } catch (e) {
      print('Error al obtener canciones: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para enviar la señal de reproducción a través del WebSocket
  void _sendPlaySignal(int songId, String roomCode) {
    if (_channel != null) {
      final playMessage = jsonEncode({
        'songId': songId.toString(),
        'roomCode': roomCode,
        'action': 'PLAY',
      });

      _channel!.sink.add(playMessage);
      print('Mensaje enviado: $playMessage');
    } else {
      print('Error: WebSocket no está conectado.');
    }
  }

  // Método para seleccionar música y subirla
  Future<void> _selectMusic() async {
    if (_selectedDjId == 0) {
      print('El ID del DJ no ha sido obtenido correctamente.');
      return;
    }

    final result =
        await _songService.selectAndUploadMusic(_selectedDjId.toString());

    setState(() {
      _selectedSongTitle =
          result; // Asignamos el título de la canción seleccionada
    });

    // Actualizamos la lista de canciones
    if (_accessCode != null) {
      await _fetchSongs(_accessCode!, _selectedDjId);
      await _connectToWebSocket(_accessCode!);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCredentialsFromDatabase(); // Cargar credenciales, conectar a la sala y descargar canciones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compartir Música'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                          title: Text(song.name),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _sendPlaySignal(song.id, _accessCode!);
                            },
                            child: Text('Reproducir'),
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectMusic,
              child: Text('Seleccionar Canción'),
            ),
            SizedBox(height: 20),
            // Mostrar los datos almacenados (Token, Email, Código de Acceso)
            Text('Token: ${_token ?? "No cargado"}'),
            Text('Email: ${_email ?? "No cargado"}'),
            Text('Código de Acceso: ${_accessCode ?? "No cargado"}'),
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
