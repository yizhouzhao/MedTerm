import 'package:flutter/cupertino.dart';

import '../services/database.dart';
import '../styles.dart';
import '../widgets/word_line.dart';
import '../models/word.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word});

  final String word;
  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context, String word) {
    return CupertinoPage(
      restorationId: 'router.details.$word',
      child: WordDetailScreen(word: word),
      title: 'Word Detail',
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: 'router.details.$word',
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Words'),
          previousPageTitle: 'Home',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<MedWord?>(
            future: databaseService.getWord(word),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              print('[WordDetailScreen] isLoading: $isLoading');
              return (isLoading)
                  ? const CupertinoActivityIndicator()
                  : snapshot.data == null
                  ? const Text('Word not found')
                  : WordLine(word: snapshot.data!.word, memoryLevel: 0);
            },
          ),
        ),
      ),
    );
  }
}
