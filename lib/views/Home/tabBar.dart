import 'package:app_worbun_1k/views/Home/principalView.dart';
import 'package:app_worbun_1k/views/Home/purchase/purchaseView.dart';
import 'package:flutter/material.dart';

class TabBarApp extends StatefulWidget {

  final String email; // Parámetro que recibirá el correo electrónico

  TabBarApp({required this.email}); //
  @override
  _TabBarAppState createState() => _TabBarAppState();
}

class _TabBarAppState extends State<TabBarApp> {
  int _selectedIndex = 0;

List<Widget> _widgetOptions() {
    return <Widget>[
      RumberoScreen(), // Pasando el email a RumberoScreen
      PurchaseView(),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vista principal que cambia con el TabBar
          Center(
            child: _widgetOptions().elementAt(_selectedIndex),
            // child: _widgetOptions.elementAt(_selectedIndex),
          ),
          // TabBar flotante
          Positioned(
            bottom: 10.0, // Espacio para flotante
            left: 35.0, // Margen lateral izquierdo
            right: 35.0, // Margen lateral derecho
            child: SafeArea(
              child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: 10.0), // Padding del TabBar
                decoration: BoxDecoration(
                  color: Colors.grey.shade800, // Color de fondo gris
                  borderRadius:
                      BorderRadius.circular(60.0), // Bordes redondeados
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabBarItem("assets/signalMusic.png", "Inicio", 0),
                    //     _buildTabBarItem("assets/libraryMusic.png", "Mi música", 1),
                    _buildTabBarItem("assets/whiteR.png", "Pro", 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarItem(String iconPath, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20.0 : 0.0,
            vertical: isSelected
                ? 8.0
                : 0.0), // Ajuste dinámico del espacio horizontal
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black
              : Colors.transparent, // Fondo negro si está seleccionado
          borderRadius:
              BorderRadius.circular(20.0), // Bordes redondeados para el fondo
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono siempre visible
            Image.asset(
              iconPath,
              width: 30,
              height: 30,
              color: isSelected ? const Color(0xFF28E7C5) : Colors.white,
            ),
            // El texto solo aparece si está seleccionado
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0), // Espacio entre ícono y texto
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF28E7C5) : Colors.transparent,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
