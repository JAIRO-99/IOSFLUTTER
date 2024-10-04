import 'dart:convert';
import 'dart:typed_data';

class Song {
  final int id;
  final String name;
  final String filePath;
  final Uint8List fileData;

  Song({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileData,
  });

  // Constructor vacío
  Song.empty()
      : id = 0,
        name = 'Canción Desconocida',
        filePath = '',
        fileData = Uint8List(0); // Datos vacíos

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? 0,  // Maneja caso nulo para id
      name: json['name'] ?? 'Desconocido',  // Maneja caso nulo para name
      filePath: json['filePath'] ?? '',  // Si es null, se asigna cadena vacía
      fileData: base64Decode(json['fileData']),  // Decodifica los datos binarios
    );
  }
}
