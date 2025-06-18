import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';
import '../styles.dart';
import '../widgets/word_line.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, this.category});

  final String? category;
  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context, String? category) {
    return CupertinoPage(
      restorationId: 'router.systems.${category ?? 'unfamiliar'}',
      child: WordListScreen(category: category),
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
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: 'router.systems.${widget.category ?? 'unfamiliar'}',
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Words'),
          previousPageTitle: 'Home',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: WordListScreen.databaseService.getUserWordsWithMemory(
              widget.category,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
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
