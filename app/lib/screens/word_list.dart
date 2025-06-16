import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';
import '../styles.dart';
import '../widgets/word_line.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, required this.bodySystemName});

  final String bodySystemName;
  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context, String bodySystemName) {
    return CupertinoPage(
      restorationId: 'router.systems.$bodySystemName',
      child: WordListScreen(bodySystemName: bodySystemName),
      title: '$bodySystemName Word List',
    );
  }

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: widget.bodySystemName,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Words'),
          previousPageTitle: 'Home',
        ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: WordListScreen.databaseService.getUserWordsWithMemory(widget.bodySystemName),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return (ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return WordLine(
                        word: snapshot.data?[index]['word'] ?? '', 
                        memoryLevel: snapshot.data?[index]['memory_level'] ?? 0
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

class NotebookWordListScreen extends StatelessWidget {
  const NotebookWordListScreen({super.key});

  static final DatabaseService databaseService = DatabaseService();

  static Page<void> pageBuilder(BuildContext context) {
    return CupertinoPage(
      restorationId: 'router.notebook',
      child: NotebookWordListScreen(),
      title: 'Notebook',
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = CupertinoTheme.brightnessOf(context);
    return RestorationScope(
      restorationId: 'router.notebook',
      child: CupertinoPageScaffold(
        // navigationBar: const CupertinoNavigationBar(
        //   middle: Text('Notebook'),
        //   previousPageTitle: 'Home',
        // ),
        backgroundColor: Styles.scaffoldBackground(brightness),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: databaseService.getUserUnfamiliarWords(),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              print('[NotebookWordListScreen] isLoading: $isLoading');
              return (isLoading)
                  ? const CupertinoActivityIndicator()
                  : (ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return WordLine(word: snapshot.data?[index]['word'] ?? '', memoryLevel: snapshot.data?[index]['memory_level'] ?? 0);
                    },
                  ));
            },
          ),
        ),
      ),
    );
  }
}