import 'dart:convert';
import 'dart:io';
import 'package:app_worbun_1k/crossplatform/Song.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data'; // Importar para Uint8List
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class SongService {
  AudioPlayer? _audioPlayer;
  int? _currentlyPlayingId;
  String baseUrl = 'https://rumba-music2.azurewebsites.net/';

  Future<List<Song>> fetchSongs(String roomCode, String userId) async {
    final response = await http.get(
        Uri.parse('${baseUrl}api/rooms/validate-and-filter/$roomCode/$userId'));

    print('Respuesta del servidor: ${response.body}'); // Para depurar

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> songJson = jsonDecode(response.body);
      return songJson.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar canciones');
    }
  }

  Future<void> playSong(Song song) async {
    if (_audioPlayer != null && _currentlyPlayingId == song.id) {
      return; // La canción ya está sonando
    }

    if (_audioPlayer != null) {
      await _audioPlayer?.stop(); // Detener la canción anterior
    }

    _audioPlayer = AudioPlayer();
    _currentlyPlayingId = song.id;

    // Verificar si los datos existen
    if (song.fileData.isNotEmpty) {
      try {
        // Obtener el directorio temporal para almacenar el archivo
        Directory tempDir = await getTemporaryDirectory();
        String tempPath =
            '${tempDir.path}/${song.name}.mp3'; // Ajusta la extensión según el formato de la canción
        File tempFile = File(tempPath);

        // Escribir los datos binarios en el archivo temporal
        await tempFile.writeAsBytes(song.fileData);

        // Reproducir el archivo desde el sistema de archivos
        await _audioPlayer?.play(DeviceFileSource(tempFile.path));
      } catch (e) {
        print("Error al reproducir la canción: $e");
      }
    } else {
      print("Error: Los datos de la canción están vacíos");
    }
  }

  Future<void> stopSong() async {
    if (_audioPlayer != null) {
      await _audioPlayer?.stop();
      _currentlyPlayingId = null;
    }
  }

  /// Método para seleccionar música, preparar el archivo y enviarlo a un endpoint
  Future<String> selectAndUploadMusic(String userId) async {
    // Seleccionar música local
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp3',
        'wav',
        'm4a',
        'aac'
      ], // Limitar a formatos de música
    );

    if (result != null) {
      String localMusicPath = result.files.single.path!;
      String musicTitle = path.basename(localMusicPath);
      Uint8List musicData = await File(localMusicPath).readAsBytes();

      print('Música seleccionada: $musicTitle');

      // Preparar la solicitud multipart
      var request = http.MultipartRequest(
          'POST', Uri.parse('${baseUrl}api/songs/upload/$userId'));

      // Adjuntar el archivo de música
      request.files.add(http.MultipartFile.fromBytes('file', musicData,
          filename: musicTitle));

      // Enviar la solicitud al servidor
      var response = await request.send();

      // Verificar la respuesta del servidor
      if (response.statusCode == 200) {
        print(
            'Canción $musicTitle subida correctamente con DJ con ID: $userId');
        return "Canción ${musicTitle} subida correctamente";
      } else {
        print('Error al subir la canción: ${response.statusCode}');

        return "Error al subir la canción";
      }
    } else {
      print('No se seleccionó ninguna música.');
      return "No se seleccionó ninguna canción.";
    }
  }
}
