import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/word.dart';
import '../services/database.dart';

class SyncData {
  static const baseUrl = 'https://raw.githubusercontent.com/yizhouzhao/MedTerm/refs/heads/main/data/';
  static const wordListUrl = '${baseUrl}wordlist.json';


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
    final categories = (data['categories'] as List).map((e) => e.toString()).toList();
    return categories;
  }

  static Future<void> downloadWordList(BodySystem bodySystem) async {
    final dio = Dio();
    final categoryUrl = '${baseUrl}${bodySystem.name}.json';
    print('categoryUrl: $categoryUrl');
    final response = await dio.get(categoryUrl);
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;
    
    final databaseService = DatabaseService();
    List<MedWord> words = (data['words'] as List).map((e) => MedWord.fromMap(e)).toList();
    for (var word in words) {
      await databaseService.insertWord(word);
    }
  }
}