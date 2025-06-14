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
    await db.execute(
      '''CREATE TABLE words(
        word TEXT PRIMARY KEY,
        prefix TEXT NOT NULL,
        root TEXT NOT NULL,
        suffix TEXT NOT NULL,
        meaning TEXT NOT NULL,
        explanation TEXT NOT NULL,
        chineseTranslation TEXT NOT NULL,
        category TEXT NOT NULL
      )''',
    );
  }

  Future<void> insertWord(MedWord word) async {
    final db = await _databaseService.database;
    await db.insert(
      'words',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<List<MedWord>> medWords() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (index) => MedWord.fromMap(maps[index]));
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
    await db.delete(
      'words',
      where: 'word = ?',
      whereArgs: [word],
    );
  }
}