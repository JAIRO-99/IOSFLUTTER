import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://rumba-music2.azurewebsites.net';

  /// Registra un usuario como DJ
  Future<void> registerUser(String name) async {
    final url = Uri.parse('$baseUrl/api/users/register');
    final body = jsonEncode({"name": name, "role": "DJ"});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Usuario registrado exitosamente.');
      } else {
        print('Error al registrar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al registrar el usuario: $e');
    }
  }

  /// Busca el ID del DJ por su correo
  Future<int?> getDjIdByEmail(String email) async {
    final url = Uri.parse('$baseUrl/api/users/search/$email');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ID del DJ en search dentro del http: ${data['id']}');
        return data['id']; // Devuelve el ID del DJ
      } else {
        print('Error al buscar el DJ: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión al buscar el DJ: $e');
      return null;
    }
  }

  /// Crea una sala para el DJ por su ID y devuelve el código de acceso
  Future<int?> createRoomForDj(int djId) async {
    final url = Uri.parse('$baseUrl/api/rooms/create/$djId');

    try {
      final response = await http.post(url);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final code = int.tryParse(response
            .body); // Convertir el cuerpo de la respuesta en un número entero
        return code; // Devuelve el código de acceso de la sala
      } else {
        print('Error al crear la sala: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión al crear la sala: $e');
      return null;
    }
  }

  /// Registra un DJ, busca su ID y crea una sala devolviendo el código de acceso
  Future<int?> registerDjAndCreateRoom(String email) async {
    // 1. Registrar el usuario como DJ
    await registerUser(email);

    // 2. Obtener el ID del DJ por su correo
    final djId = await getDjIdByEmail(email);
    if (djId == null) {
      print('No se pudo obtener el ID del DJ.');
      return null;
    }

    // 3. Crear la sala y obtener el código de acceso
    final accessCode = await createRoomForDj(djId);
    if (accessCode == null) {
      print('No se pudo crear la sala.');
      return null;
    }

    return accessCode; // Devuelve el código de acceso
  }
}
