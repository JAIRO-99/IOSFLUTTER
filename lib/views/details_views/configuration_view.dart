import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfiguracionView extends StatelessWidget {
  Future<void> _mostrarAlerta(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar cuenta'),
          content: Text(
              'Se redireccionará a nuestra página web para que puedas eliminar tu cuenta'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      const url = 'https://rumbasound.com/delete-account';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'No se pudo abrir la URL';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Configuración',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Eliminar cuenta',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onTap: () => _mostrarAlerta(context),
          ),
        ],
      ),
    );
  }
}
