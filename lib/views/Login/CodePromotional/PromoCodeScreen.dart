import 'package:app_worbun_1k/views/Home/tabBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PromoCodeScreen extends StatefulWidget {
  final String email;

  PromoCodeScreen({required this.email});

  @override
  _PromoCodeScreenState createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isApplying = false; // Variable para estado de carga de Aplicar Código
  bool _isSkipping = false; // Variable para estado de carga de Omitir

  // Método para aplicar el código promocional
  void _applyPromoCode() async {
    setState(() {
      _isApplying = true; // Activar estado de carga
    });

    final promoCode = _promoCodeController.text;

    if (promoCode.isEmpty) {
      print('Por favor, ingresa un código promocional.');
      setState(() {
        _isApplying = false; // Desactivar estado de carga
      });
      return;
    }

    // Llamada GET para obtener el ID del usuario con el correo
    final userIdUrl = Uri.parse(
        'https://demo4-production-7601.up.railway.app/api/users/find-id?email=${widget.email}');
    final userIdResponse = await http.get(userIdUrl);

    if (userIdResponse.statusCode == 200) {
      final userId = userIdResponse.body;

      // Llamada POST para aplicar el código promocional al usuario
      final promoApplyUrl = Uri.parse(
          'https://demo4-production-7601.up.railway.app/api/promo/apply?userId=$userId&code=$promoCode');
      final response = await http.post(promoApplyUrl);

      if (response.statusCode == 200) {
        print('Código promocional aplicado con éxito.');
        // Redirige a la pantalla principal de la app
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TabBarApp(email: widget.email)),
        );
      } else {
        print('Error al aplicar el código promocional.');
      }
    } else {
      print('Error al obtener el ID del usuario.');
    }

    setState(() {
      _isApplying = false; // Desactivar estado de carga
    });
  }

  // Método para omitir la aplicación del código y continuar
  void _skipPromoCode() async {
    setState(() {
      _isSkipping = true; // Activar estado de carga
    });

    await Future.delayed(Duration(seconds: 2)); // Simulación de carga

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabBarApp(email: widget.email)),
    );

    setState(() {
      _isSkipping = false; // Desactivar estado de carga
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Oculta el teclado al hacer tap en cualquier parte
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Color(0xFF28E7C5),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título
                  Column(
                    children: [
                      Text(
                        'Código Promocional',
                        style: TextStyle(
                          color: Color(0xFF28E7C5),
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        'Ingresa tu código promocional',
                        style: TextStyle(
                          color: Color(0xFF28E7C5),
                          fontSize: 23,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Campo de Código Promocional
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Código promocional',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _promoCodeController,
                    decoration: InputDecoration(
                      labelText: 'Ingresa tu código promocional',
                      filled: true,
                      fillColor: Colors.white,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20),

                  // Botón "Aplicar Código" con Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            width: 2,
                            color: Colors.transparent,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB6FF00),
                              Color(0xFF6942E2),
                              Color(0xFF28E7C5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isApplying
                              ? null
                              : _applyPromoCode, // Llama a la función que aplica el código promocional
                          child: _isApplying
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Aplicar Código',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Botón "Omitir" con Progress Indicator y relleno de 3 colores
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB6FF00),
                              Color(0xFF6942E2),
                              Color(0xFF28E7C5),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isSkipping ? null : _skipPromoCode,
                          child: _isSkipping
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Omitir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
