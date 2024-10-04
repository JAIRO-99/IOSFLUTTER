import 'package:app_worbun_1k/crossplatform/ShareMusicScreen.dart';
import 'package:app_worbun_1k/crossplatform/SongListScreen.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona tu rol'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Qué te gustaría hacer?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navegar a la vista de oyente
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SongListScreen()),
                  );
                },
                child: Text('Soy Oyente'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navegar a la vista para compartir música (Aún no implementada)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShareMusicScreen()), // Aquí iría la pantalla para compartir música
                  );
                },
                child: Text('Quiero Compartir Música'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


