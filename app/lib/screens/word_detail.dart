import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/word.dart';
import '../services/database.dart';
import '../styles.dart';
import '../data/app_state.dart';
import '../widgets/word_sound.dart';
import '../data/preferences.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word});

  final String word;
  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context, String word) {
    return CupertinoPage(
      restorationId: 'router.details.$word',
      child: WordDetailScreen(word: word),
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = CupertinoTheme.brightnessOf(context);
    final appState = Provider.of<AppState>(context, listen: false);
    final prefs = Provider.of<Preferences>(context, listen: false);
    return RestorationScope(
      restorationId: 'router.details.$word',
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          previousPageTitle: 'Word List',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<MedWord?>(
            future: databaseService.getWord(word),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              final MedWord? medWord = snapshot.data;
              // print('[WordDetailScreen] isLoading: $isLoading');
              return (isLoading)
                  ? const CupertinoActivityIndicator()
                  : medWord == null
                  ? const Text('Word not found')
                  : SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WordSound(word: medWord.word),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.activeOrange
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Meaning',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.activeOrange,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          medWord.meaning,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (prefs.showTranslation ?? false)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemTeal
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Chinese Translation',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: CupertinoColors.systemTeal,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            prefs.translationType ==
                                                    'traditional'
                                                ? medWord
                                                    .traditionalChineseTranslation
                                                : medWord.chineseTranslation,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (prefs.showTranslation ?? false)
                                    const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemIndigo
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Word Structure',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.systemIndigo,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Prefix: ${medWord.prefix} \nRoot: ${medWord.root}\nSuffix: ${medWord.suffix}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FlashcardControls(
                          word: medWord.word,
                          onRemember: () async {
                            await databaseService.addUserWordMemory(
                              medWord.word,
                              1,
                            );
                          },
                          onDontRemember: () async {
                            await databaseService.addUserWordMemory(
                              medWord.word,
                              -1,
                            );
                          },
                          onNext: () {
                            int nextIndex = appState.getNextMedWordIndex(
                              medWord.word,
                            );
                            context.pushReplacement(
                              '/word/${appState.getMedWords()[nextIndex].word}',
                            );
                          },
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }
}

class FlashcardControls extends StatelessWidget {
  final String word;
  final VoidCallback onRemember;
  final VoidCallback onDontRemember;
  final VoidCallback onNext;

  const FlashcardControls({
    super.key,
    required this.word,
    required this.onRemember,
    required this.onDontRemember,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CupertinoButton(
            onPressed: () {
              onDontRemember();
              onNext();
            },
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 32,
                  color: CupertinoColors.destructiveRed,
                ),
                SizedBox(height: 4),
                Text(
                  'Don\'t Remember',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.destructiveRed,
                  ),
                ),
              ],
            ),
          ),
          // add the separator as a gray rectangle
          Container(width: 1, height: 24, color: CupertinoColors.systemGrey),
          CupertinoButton(
            onPressed: () {
              onRemember();
              onNext();
            },
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.activeGreen,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  'Remember',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
              ],
            ),
          ),
          // add the separator as a gray rectangle
          Container(width: 1, height: 24, color: CupertinoColors.systemGrey),
          CupertinoButton(
            onPressed: onNext,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.arrow_right_circle_fill,
                  color: CupertinoColors.activeBlue,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
