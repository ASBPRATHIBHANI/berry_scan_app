import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('berryscan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // specific types for SQLite
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE users ( 
  id $idType, 
  firstName $textType,
  lastName $textType,
  email $textType,
  password $textType
  )
''');
  }

  // --- CRUD OPERATIONS ---

  // 1. Register User
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  // 2. Login User (Check if email & password match)
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: [
        'id',
        'firstName',
        'lastName',
        'email',
      ], // Don't return password
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  // 3. ✅ NEW: Get Last Logged-in/Registered User (For Home Screen)
  Future<Map<String, dynamic>?> getLastUser() async {
    final db = await instance.database;
    // Get the last row added to the users table
    final maps = await db.query(
      'users',
      orderBy: 'id DESC', // Get the newest one
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }
}
