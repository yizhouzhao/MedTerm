import '../models/word.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'flutter_sqflite_database.db');

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE TABLE statement for words
    await db.execute('''CREATE TABLE words(
        word TEXT PRIMARY KEY,
        prefix TEXT NOT NULL,
        root TEXT NOT NULL,
        suffix TEXT NOT NULL,
        meaning TEXT NOT NULL,
        explanation TEXT NOT NULL,
        chineseTranslation TEXT NOT NULL,
        category TEXT NOT NULL
      )''');
    // Run the CREATE TABLE statement for User memory
    await db.execute('''CREATE TABLE user_memory(
        word TEXT PRIMARY KEY,
        memory_level INTEGER NOT NULL
      )''');
  }

  Future<void> insertWord(MedWord word) async {
    final db = await _databaseService.database;
    await db.insert(
      'words',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MedWord?> getWord(String word) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'word = ?',
      whereArgs: [word],
    );
    if (maps.isEmpty) return null;
    return MedWord.fromMap(maps[0]);
  }

  Future<List<MedWord>> words() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (index) => MedWord.fromMap(maps[index]));
  }

  Future<MedWord?> word(String word) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'word = ?',
      whereArgs: [word],
    );
    if (maps.isEmpty) return null;
    return MedWord.fromMap(maps[0]);
  }

  Future<List<MedWord>> getWords(String? category) async {
    final db = await _databaseService.database;
    try {
      final maps = await db.query(
        'words',
        where: category != null ? 'category = ?' : null,
        whereArgs: category != null ? [category] : null,
      );
      return maps.map((map) => MedWord.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching words for category $category: $e');
      return []; // Return empty list on error
    }
  }

  Future<void> updateWord(MedWord word) async {
    final db = await _databaseService.database;
    await db.update(
      'words',
      word.toMap(),
      where: 'word = ?',
      whereArgs: [word.word],
    );
  }

  Future<void> deleteWord(String word) async {
    final db = await _databaseService.database;
    await db.delete('words', where: 'word = ?', whereArgs: [word]);
  }

  Future<void> insertUserMemory(String word, int memoryLevel) async {
    final db = await _databaseService.database;
    await db.insert('user_memory', {'word': word, 'memory_level': memoryLevel});
  }

  Future<void> updateUserMemory(String word, int memoryLevel) async {
    final db = await _databaseService.database;
    await db.update(
      'user_memory',
      {'memory_level': memoryLevel},
      where: 'word = ?',
      whereArgs: [word],
    );
  }

  Future<void> deleteUserMemory(String word) async {
    final db = await _databaseService.database;
    await db.delete('user_memory', where: 'word = ?', whereArgs: [word]);
  }

  Future<int> getUserWordMemory(String word) async {
    final db = await _databaseService.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'user_memory',
        where: 'word = ?',
        whereArgs: [word],
        limit: 1, // Optimize: Stop after first match
      );
      if (maps.isEmpty) return 0; // No record found
      // Safely cast to int (handle NULL/type mismatch)
      final memoryLevel = maps.first['memory_level'] as int?;
      return memoryLevel ?? 0; // Default to 0 if NULL
    } catch (e) {
      // Handle errors (e.g., database closed, table missing)
      print('Error querying user_memory: $e');
      return 0; // Or rethrow if critical
    }
  }

  Future<List<Map<String, dynamic>>> getUserWordsWithMemory(String category) async {
    final words = await getWords(category);
    final futures = words.map((word) async => {
      'word': word.word,
      'memory_level':  await getUserWordMemory(word.word)
    });
    return Future.wait(futures);
  }

  Future<List<Map<String, dynamic>>> getUserUnfamiliarWords() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('user_memory', where: 'memory_level < 0');
    return maps;
  }

  Future<void> addUserWordMemory(String word, int memoryLevel) async {
    final db = await _databaseService.database;
    await db.insert(
      'user_memory',
      {'word': word, 'memory_level': memoryLevel},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('[DatabaseService] Added user word memory: $word, $memoryLevel');
  }
}
