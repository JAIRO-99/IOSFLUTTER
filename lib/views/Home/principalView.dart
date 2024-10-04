import 'package:app_worbun_1k/crossplatform/AppDatabase.dart';
import 'package:app_worbun_1k/views/Home/djViews/controlMusicView.dart';
import 'package:app_worbun_1k/views/Home/djViews/receptorView/receptorView.dart';
import 'package:app_worbun_1k/views/Login/ApiService.dart';
import 'package:app_worbun_1k/views/Login/login.dart';
import 'package:flutter/material.dart';

// class RumberoScreen extends StatefulWidget {
//   final String email; // Parámetro que recibirá el correo electrónico

//   RumberoScreen({required this.email}); // Constructor

//   @override
//   _RumberoScreenState createState() => _RumberoScreenState();
// }

// class _RumberoScreenState extends State<RumberoScreen> {
//   String? _token;
//   String? _email;
//   String? _accessCode;
//   ApiService apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     _loadCredentials();
//   }

// Future<void> _loadCredentials() async {
//   // Obtener las credenciales desde la base de datos
//   final credentials = await AppDatabase().getCredentials();

//   print("El email es: ${widget.email}");

//   if (credentials == null) {


//     // Si no existen credenciales, registrar el usuario y crear una sala
//     print("Credenciales no existen, creando...");
//     await _createAndSaveRoomCode();
//   } else {
//         // Verificar si 'accessCode' existe
//     if (credentials["accessCode"] != null) {
//       print("El accessCode es: ${credentials["accessCode"]}");
//     } else {
//       // Si 'accessCode' no existe, registrar el usuario y crear una sala
//       print("AccessCode no existe, creando...");
//       await _createAndSaveRoomCode();
//     }
//   }
// }

// // Función para registrar el usuario y crear una sala para el DJ
// Future<void> _createAndSaveRoomCode() async {
//   // Registrar el usuario con el email
//   await apiService.registerUser(widget.email);
  
//   // Obtener el ID del DJ a partir del email
//   int? djId = await apiService.getDjIdByEmail(widget.email);
  
//   if (djId != null) {
//     // Crear una sala para el DJ y obtener el roomCode
//     int? roomCode = await apiService.createRoomForDj(djId);

//     if (roomCode != null) {
//       // Guardar las credenciales en la base de datos
//       await AppDatabase().saveCredentials('', widget.email, roomCode.toString());
//       print("Se ha creado la sala con el roomCode: $roomCode");
//     } else {
//       print("Error al crear la sala para el DJ");
//     }
//   } else {
//     print("Error al obtener el DJ ID");
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     // Obtenemos el tamaño de la pantalla
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Icon(
//               Icons.confirmation_num,
//               color: Colors.white,
//               size: 30,
//             ),
//             SizedBox(width: 10),
//           ],
//         ),
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 40.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: screenHeight * 0.02),

//               // Subtítulo
//               Text(
//                 "¿Qué tipo de rumbero eres?",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: screenWidth * 0.08, // Tamaño relativo
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.01),

//               // Texto más abajo
//               Text(
//                 "Escoge tu modo",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: screenWidth * 0.06, // Tamaño relativo
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.03),

//               // Primer rectángulo
//               RumberoOption(
//                 imagePath: 'assets/djLogo.png',
//                 label: 'Controla la música',
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => Controlmusicview(),
//                     ),
//                   );
//                 },
//               ),
//               SizedBox(height: screenHeight * 0.03), // Espacio relativo

//               RumberoOption2(
//                 imagePath: 'assets/hearMusic.png',
//                 label: 'Escucha la música',
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CustomView(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class RumberoScreen extends StatelessWidget {
  // Método para manejar el logout
  Future<void> _logout(BuildContext context) async {
    await AppDatabase().deleteAndRecreateDatabase(); // Eliminar las credenciales
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redirigir a la pantalla de login
      (Route<dynamic> route) => false, // Remover todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _logout(context), // Llamar al método de logout al presionar el icono
              child: Icon(
                Icons.logout,
                color: Colors.white,
                size: 30,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Subtítulo
              Text(
                "¿Qué tipo de rumbero eres?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.08, // Tamaño relativo
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Texto más abajo
              Text(
                "Escoge tu modo",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.06, // Tamaño relativo
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Primer rectángulo
              RumberoOption(
                imagePath: 'assets/djLogo.png',
                label: 'Controla la música',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Controlmusicview(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.03), // Espacio relativo

              RumberoOption2(
                imagePath: 'assets/hearMusic.png',
                label: 'Escucha la música',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personalizado para las opciones de rumbero
class RumberoOption extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  RumberoOption({
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Ajustamos el tamaño dinámico según la pantalla
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.25, // Altura relativa al tamaño de la pantalla
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: [
            Color(0xFF6942E2),
            Color(0xFF28E7C5),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // Imagen
          Positioned(
            top: 0,
            left: -50,
            right: 0,
            child: Image.asset(
              imagePath,
              height: screenHeight * 0.18, // Tamaño relativo
              fit: BoxFit.contain,
            ),
          ),
          // Texto en la parte inferior izquierda
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Botón de navegación en la parte inferior derecha
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.white,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Segunda opción con el mismo estilo
class RumberoOption2 extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  RumberoOption2({
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.25, // Altura relativa
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: [
            Color(0xFFB6FF00),
            Color(0xFF28E7C5),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // Imagen
          Positioned(
            top: 0,
            left: -20,
            right: 0,
            child: Image.asset(
              imagePath,
              height: screenHeight * 0.18,
              fit: BoxFit.contain,
            ),
          ),
          // Texto en la parte inferior izquierda
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Botón de navegación en la parte inferior derecha
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.white,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
