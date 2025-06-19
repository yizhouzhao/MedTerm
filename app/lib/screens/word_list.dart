import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../services/database.dart';
import '../styles.dart';
import '../widgets/word_line.dart';
import '../models/word.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, this.lesson});

  final int? lesson;
  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context, int? lesson) {
    return CupertinoPage(
      restorationId: 'router.systems.${lesson ?? '0'}',
      child: WordListScreen(lesson: lesson),
      title: 'Word List',
    );
  }

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = Provider.of<AppState>(context, listen: false);
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: 'router.systems.${widget.lesson ?? '0'}',
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Words'),
          previousPageTitle: 'Home',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: WordListScreen.databaseService.getUserWordsWithMemory(
              widget.lesson,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Future.wait(
                  snapshot.data!
                      .map(
                        (e) =>
                            WordListScreen.databaseService.getWord(e['word']),
                      )
                      .toList(),
                ).then((words) {
                  appState.setMedWords(words.whereType<MedWord>().toList());
                });
                return (ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return WordLine(
                      word: snapshot.data?[index]['word'] ?? '',
                      memoryLevel: snapshot.data?[index]['memory_level'] ?? 0,
                    );
                  },
                ));
              }
              return const CupertinoActivityIndicator();
            },
          ),
        ),
      ),
    );
  }
}
