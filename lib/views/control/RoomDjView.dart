import 'dart:async';

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

class RoomDjView extends StatefulWidget {
  @override
  _RoomDjViewState createState() => _RoomDjViewState();
}

class _RoomDjViewState extends State<RoomDjView> {
  final SongService _songService = SongService();
  List<Song> _songs = []; // Lista de canciones obtenidas
  bool _isLoading = true;
  IOWebSocketChannel? _channel; // Conexión de WebSocket
  Map<int, bool> _songPlayStates = {};
  int? _currentPlayingSongId;

  // Variables para almacenar los datos recuperados de la base de datos
  String? _token;
  String? _email;
  String? _accessCode;
  int _selectedDjId = 0;

  String _fullText = "Obteniendo canciones...";
  String _currentText = "";
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCredentialsAndSongs(); // Cargar credenciales, canciones, y conectar al WebSocket
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

  Future<void> _loadCredentialsAndSongs() async {
    // Obtener credenciales desde la base de datos
    final credentials = await AppDatabase().getCredentials();

    if (credentials != null) {
      setState(() {
        _token = credentials['token'];
        _email = credentials['email'];
        _accessCode = credentials['accessCode'];
      });

      print("correo: $_email");

      // Obtener el ID del DJ
      if (_email != null) {
        await _fetchDjId(_email!);
      }

      // Descargar canciones y conectar al WebSocket
      if (_accessCode != null && _selectedDjId != 0) {
        await _fetchSongsWithRetries(_accessCode!, _selectedDjId);
        await _connectToWebSocket(_accessCode!);
      }
    }
  }

  // Obtener el ID del DJ desde el backend
  Future<void> _fetchDjId(String email) async {
    final url =
        'https://rumba-music2.azurewebsites.net/api/users/search/$email';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'FlutterApp/1.0',
      });
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

  // Descargar las canciones con reintentos
  Future<void> _fetchSongsWithRetries(String roomCode, int djId) async {
    int retryCount = 0;
    const int maxRetries = 3;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _fetchSongs(roomCode, djId);
        success = true;
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

  // Descargar las canciones con un tiempo de espera de 3 minutos
  Future<void> _fetchSongs(String roomCode, int djId) async {
    final url =
        'https://rumba-music5.azurewebsites.net/api/rooms/validate-and-filter/$roomCode/$djId';

    try {
      // Agregar un tiempo de espera de 3 minutos (180 segundos)
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final List<dynamic> songsJson = json.decode(response.body);
        setState(() {
          _songs = songsJson.map((json) => Song.fromJson(json)).toList();
          _isLoading = false;
          for (var song in _songs) {
            _songPlayStates[song.id] =
                false; // Por defecto, ninguna canción está reproduciéndose
          }
        });
      } else {
        throw Exception(
            'Error al descargar canciones. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error durante la solicitud de canciones: $e');
    }
  }

  // Conectar al WebSocket
  Future<void> _connectToWebSocket(String roomCode) async {
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

        // Evitar reproducción paralela: detener cualquier canción que esté sonando
        if (_currentPlayingSongId != null && _currentPlayingSongId != songId) {
          await _songService.stopSong(); // Detener la canción anterior
          print('Canción anterior detenida.');
          _currentPlayingSongId =
              null; // Limpiar la referencia de la canción anterior
        }

        if (delayMillis > 0) {
          // Esperar hasta la hora programada para iniciar la reproducción
          await Future.delayed(Duration(milliseconds: delayMillis));
        }

        // Reproducir la nueva canción
        await _songService.playSong(songToPlay);
        print('Reproduciendo nueva canción: $songId');
        _currentPlayingSongId =
            songId; // Actualizar la canción actual que está en reproducción
      } else if (action == 'STOP') {
        // Si la acción es STOP, detener la música
        await _songService
            .stopSong(); // Detener cualquier canción que esté reproduciéndose
        print('Canción detenida: ID $songId');
        _currentPlayingSongId =
            null; // Limpiar la referencia de la canción detenida
      }
    }
  }

  // Obtener hora sincronizada desde NTP
  Future<DateTime> _getSynchronizedTime() async {
    return await NTP.now(); // Obtener la hora exacta desde el servidor NTP
  }

  // Enviar señal de reproducción con tiempo sincronizado
  void _sendPlaySignal(int songId, String roomCode) async {
    if (_channel != null) {
      // Obtener hora sincronizada y calcular un tiempo futuro (5 segundos después)
      DateTime synchronizedTime = await _getSynchronizedTime();
      int startTime = synchronizedTime.millisecondsSinceEpoch + 2000;

      final playMessage = jsonEncode({
        'songId': songId.toString(),
        'roomCode': roomCode,
        'startTime':
            startTime.toString(), // Enviar la hora de inicio en milisegundos
        'action': 'PLAY',
      });

      _channel!.sink.add(playMessage);
      print('Mensaje enviado: $playMessage');
    } else {
      print('Error: WebSocket no está conectado.');
    }
  }

  void _sendStopSignal(int songId, String roomCode) async {
    if (_channel != null) {
      // Obtener hora sincronizada y establecer un tiempo futuro (1 año después)
      DateTime synchronizedTime = await _getSynchronizedTime();
      int startTime = synchronizedTime.millisecondsSinceEpoch +
          Duration(days: 365).inMilliseconds;

      final stopMessage = jsonEncode({
        'songId': songId.toString(),
        'roomCode': roomCode,
        'startTime':
            startTime.toString(), // Tiempo futuro para evitar reproducción
        'action': 'STOP',
      });

      _channel!.sink.add(stopMessage);
      print('Mensaje STOP enviado: $stopMessage');
    } else {
      print('Error: WebSocket no está conectado.');
    }
  }

  Future<void> _selectMusic() async {
    if (_selectedDjId == 0) {
      print('El ID del DJ no ha sido obtenido correctamente.');
      return;
    }

    // 1. Subir la canción
    final result =
        await _songService.selectAndUploadMusic(_selectedDjId.toString());

    if (result != "no se escogio ninguna cancion") {
      if (result.isNotEmpty) {
        print('Canción subida: $result');

        // 3. Detener cualquier canción que esté reproduciéndose actualmente
        try {
          await _songService.stopSong(); // Detener la reproducción actual
          print('Canción detenida correctamente.');
          _currentPlayingSongId =
              null; // Limpiar la referencia de la canción anterior
        } catch (e) {
          print('Error al detener la canción: $e');
          return; // Detenemos el flujo si ocurre un error
        }

        // 4. Volver a descargar la lista de canciones
        // NOE S NECESARIO PORQUE YA SE HACE EN EL SIGUIENTE PASO
        // if (_accessCode != null) {
        //   try {
        //     await _fetchSongsWithRetries(_accessCode!, _selectedDjId);
        //     print('Canciones actualizadas.');
        //   } catch (e) {
        //     print('Error al actualizar las canciones: $e');
        //     return; // Detenemos el flujo si ocurre un error
        //   }
        // }

        // 5. Recargar la vista por completo
        Navigator.of(context).pop(); // Salir de la vista actual
        //await Future.delayed(Duration(milliseconds: 200)); // Pequeña demora
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RoomDjView())); // Volver a entrar a la vista
      } else {
        print('Error al subir la canción o no se seleccionó ninguna canción.');
      }
    } else {
      print('No se seleccionó ninguna música.');
    }
  }

  void _resetView() {
    // Limpiar la lista de canciones y los estados de reproducción
    setState(() {
      _songs = []; // Limpiar las canciones actuales
      _songPlayStates.clear(); // Limpiar los estados de reproducción
      _isLoading = true; // Mostrar indicador de carga
    });

    // Recargar las canciones y reconectar el WebSocket
    _loadCredentialsAndSongs(); // Volver a cargar las credenciales y las canciones
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
            SizedBox(height: 16),
            Column(
              children: [
                // IconButton(
                //   icon: Icon(Icons.play_arrow, color: const Color(0xFF28E7C5)),
                //   iconSize: 120,
                //   onPressed: () {
                //     print('Play button pressed for item');
                //   },
                // ),
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% del ancho de la pantalla
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width *
                          0.05), // margen izquierdo y derecho para centrar la imagen
                  child: Image.asset(
                    'assets/rumba.png',
                    fit: BoxFit
                        .contain, // Mantiene la relación de aspecto original y ajusta la altura automáticamente
                  ),
                ),
                Text(
                  'Pon algo de música de tu biblioteca, luego presiona el botón de reproduccción',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 30),
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
                        ),
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
                : Expanded(
                    // Asegurarse de que el ListView no cause overflow
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage("assets/whiteR.png"),
                            ),
                            title: Text(
                              song.name.isNotEmpty
                                  ? song.name
                                  : "Nombre canción",
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Nombre cantante',
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                _songPlayStates[song.id] == true
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                bool isPlaying =
                                    _songPlayStates[song.id] ?? false;

                                if (!isPlaying) {
                                  // Si ya hay una canción reproduciéndose, detenerla y actualizar su ícono a 'play'
                                  if (_currentPlayingSongId != null &&
                                      _currentPlayingSongId != song.id) {
                                    setState(() {
                                      _songPlayStates[_currentPlayingSongId!] =
                                          false;
                                    });
                                    await _songService
                                        .stopSong(); // Detener la canción anterior
                                    _sendStopSignal(_currentPlayingSongId!,
                                        _accessCode!); // Enviar señal de STOP para la canción anterior
                                    _currentPlayingSongId =
                                        null; // Limpiar la referencia de la canción anterior
                                  }

                                  // Iniciar reproducción de la nueva canción
                                  setState(() {
                                    _currentPlayingSongId = song
                                        .id; // Actualizar la canción que está en reproducción
                                    _songPlayStates[song.id] = true;
                                  });
                                  _sendPlaySignal(song.id,
                                      _accessCode!); // Enviar señal de PLAY para la nueva canción
                                  print('Play button pressed for item $index');
                                } else {
                                  // Si la canción ya está en reproducción, detenerla
                                  setState(() {
                                    _songPlayStates[song.id] = false;
                                    _currentPlayingSongId =
                                        null; // Ninguna canción está en reproducción ahora
                                  });
                                  await _songService
                                      .stopSong(); // Detener la música localmente
                                  _sendStopSignal(song.id,
                                      _accessCode!); // Enviar señal de STOP a los clientes
                                  print('Pause button pressed for item $index');
                                }
                              },
                            ));
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(1.0), // Espacio alrededor del ícono
            decoration: BoxDecoration(
              color: Color(0xFF28E7C5), // Color de fondo del botón
              shape: BoxShape.circle, // Forma redonda
            ),
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 40.0, // Aumentar tamaño del ícono
                color: Colors.white, // Color del ícono
              ),
              onPressed: () {
                _selectMusic();
                print('Agregar cancion');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Asegurarse de detener la reproducción de cualquier canción
    _stopSongAndDisconnect();

    // Cerrar la conexión de WebSocket si está activa
    _channel?.sink.close();
    _timer?.cancel();

    super.dispose(); // Llamar siempre al dispose original
  }

  void _stopSongAndDisconnect() async {
    await _songService.stopSong(); // Detener cualquier reproducción en curso
    await _channel?.sink.close(); // Cerrar la conexión WebSocket
    print('Reproducción detenida y WebSocket cerrado.');
  }
}
