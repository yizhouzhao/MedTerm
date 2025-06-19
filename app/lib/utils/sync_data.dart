import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/word.dart';
import '../services/database.dart';

class SyncData {
  static const baseUrl =
      'https://raw.githubusercontent.com/yizhouzhao/MedTerm/refs/heads/main/data/';
  static const wordListUrl = '${baseUrl}wordlist.json';
  static final DatabaseService databaseService = DatabaseService();

  static Future<String> getOnlineWordListVersion() async {
    final dio = Dio();
    final response = await dio.get(wordListUrl);
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;
    return data['version'] as String;
  }

  static Future<List<int>> getOnlineLessons() async {
    final dio = Dio();
    final response = await dio.get(wordListUrl);
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;
    print('[SyncData] data 2: $data');
    print('[SyncData] data 3: ${data['lessons']}');
    final lessons = (data['lessons'] as List).map((e) => e as int).toList();
    print('[SyncData] lessons 2: $lessons');
    return lessons;
  }

  static Future<void> downloadWordList(int lesson) async {
    final dio = Dio();
    final lessonUrl = '$baseUrl$lesson.json';
    print('[SyncData] lessonUrl: $lessonUrl');
    final response = await dio.get(lessonUrl);
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;

    List<MedWord> words =
        (data['words'] as List).map((e) => MedWord.fromMap(e)).toList();
    for (var word in words) {
      final updatedWord = word.copyWith(lesson: lesson);
      await databaseService.insertWord(updatedWord);
      print(
        '[SyncData] inserted word: ${updatedWord.word} ${updatedWord.lesson}',
      );
    }

    // print all words in database
    final allWords = await databaseService.getWords(lesson);
    print(
      '[SyncData]$lesson words: ${allWords.map((e) => e.chineseTranslation).join(', ')}',
    );

    final userWordsWithMemory = await databaseService.getUserWordsWithMemory(
      lesson,
    );
    print(
      '[SyncData]$lesson user words with memory: ${userWordsWithMemory.map((e) => e['word']).join(', ')}',
    );
  }

  static Future<void> resetDatabase() async {
    await databaseService.resetDatabase();
  }
}
