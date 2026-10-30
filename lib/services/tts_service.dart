import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static TTSService? _instance;
  static TTSService get instance => _instance ??= TTSService._();

  TTSService._();

  late FlutterTts _flutterTts;
  bool _isEnabled = true;

  Future<void> init() async {
    _flutterTts = FlutterTts();

    // Configurer la langue (français)
    await _flutterTts.setLanguage('fr-FR');
    print('TTS: Language set to fr-FR');

    // Configurer la vitesse de parole (0.5 = plus lent, 1.0 = normal)
    await _flutterTts.setSpeechRate(0.5);
    print('TTS: Speech rate set to 0.5');

    // Configurer le volume (0.0 à 1.0)
    await _flutterTts.setVolume(1.0);
    print('TTS: Volume set to 1.0');

    // Configurer la hauteur de la voix
    await _flutterTts.setPitch(1.0);
    print('TTS: Pitch set to 1.0');

    print('TTS: Initialization completed');
  }

  Future<void> speak(String text) async {
    print('TTS: speak() called with text: "$text"');
    print('TTS: isEnabled = $_isEnabled');

    if (!_isEnabled || text.isEmpty) {
      print('TTS: Speaking disabled or text empty, returning');
      return;
    }

    // Arrêter toute lecture en cours avant de commencer une nouvelle
    await _flutterTts.stop();
    print('TTS: Stopped previous speech');

    await _flutterTts.speak(text);
    print('TTS: Speaking text');
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;
}
