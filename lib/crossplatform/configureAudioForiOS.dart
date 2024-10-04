import 'package:audioplayers/audioplayers.dart';
import 'dart:io'; // Importar Platform para verificar el sistema operativo

Future<void> configureAudioForiOS() async {
  if (Platform.isIOS) {
    // Configura la sesión de audio para iOS sin la opción 'defaultToSpeaker', ya que no es compatible con 'playback'
    await AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));
  }
}
