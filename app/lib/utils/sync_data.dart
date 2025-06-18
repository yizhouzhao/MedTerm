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

  static Future<List<String>> getOnlineCategories() async {
    final dio = Dio();
    final response = await dio.get(wordListUrl);
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;
    print('[SyncData] data: $data');
    final categories =
        (data['categories'] as List).map((e) => e.toString()).toList();
    return categories;
  }

  static Future<void> downloadWordList(BodySystem bodySystem) async {
    final dio = Dio();
    final categoryUrl = '$baseUrl${bodySystem.name}.json';
    print('[SyncData] categoryUrl: $categoryUrl');
    final response = await dio.get(categoryUrl);
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;

    List<MedWord> words =
        (data['words'] as List).map((e) => MedWord.fromMap(e)).toList();
    for (var word in words) {
      final updatedWord = word.copyWith(category: bodySystem);
      await databaseService.insertWord(updatedWord);
      print(
        '[SyncData] inserted word: ${updatedWord.word} ${updatedWord.category}',
      );
    }

    // print all words in database
    final allWords = await databaseService.getWords(bodySystem.name);
    print(
      '[SyncData]${bodySystem.name} words: ${allWords.map((e) => e.chineseTranslation).join(', ')}',
    );

    final userWordsWithMemory = await databaseService.getUserWordsWithMemory(
      bodySystem.name,
    );
    print(
      '[SyncData]${bodySystem.name} user words with memory: ${userWordsWithMemory.map((e) => e['word']).join(', ')}',
    );
  }

  static Future<void> resetDatabase() async {
    await databaseService.resetDatabase();
  }
}
