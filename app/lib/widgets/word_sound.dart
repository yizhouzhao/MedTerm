import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../data/preferences.dart';

class WordSound extends StatefulWidget {
  const WordSound({super.key, required this.word});

  final String word;

  @override
  State<WordSound> createState() => _WordSoundState();
}

class _WordSoundState extends State<WordSound> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAutoRead();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _checkAutoRead() async {
    final prefs = Provider.of<Preferences>(context, listen: false);
    if (prefs.autoRead == true) {
      // Add a small delay to ensure TTS is initialized
      await Future.delayed(const Duration(milliseconds: 500));
      await _speak(widget.word);
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.word,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.speaker_2_fill,
            color: CupertinoColors.systemOrange,
            size: 28,
          ),
          onPressed: () => _speak(widget.word),
        ),
      ],
    );
  }
}
