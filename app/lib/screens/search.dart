import 'package:flutter/cupertino.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.restorationId});

  final String restorationId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _flutterTts = FlutterTts();
  String _translatedText = '';
  String _meaningText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<String> _getDefinition(String word) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[0]['meanings'][0]['definitions'][0]['definition'];
      }
      return 'No definition found';
    } catch (e) {
      return 'Failed to fetch definition';
    }
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) {
      setState(() {
        _translatedText = '';
        _meaningText = '';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final translation = await _translator.translate(
        text,
        from: 'en',
        to: 'zh-cn',
      );
      final meaning = await _getDefinition(text);
      setState(() {
        _translatedText = translation.text;
        _meaningText = meaning;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Translation failed. Please try again.';
        _meaningText = 'Definition not available';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // navigationBar: const CupertinoNavigationBar(
      //   middle: Text('Dictionary'),
      // ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Enter a word to translate',
                onSubmitted: _translateText,
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      _translatedText = '';
                    });
                  }
                },
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CupertinoActivityIndicator()
              else if (_translatedText.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Translation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.activeGreen,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(
                                  CupertinoIcons.speaker_2_fill,
                                  color: CupertinoColors.activeGreen,
                                ),
                                onPressed: () => _speak(_searchController.text),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _translatedText,
                            style: const TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Meaning',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _meaningText,
                            style: const TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
