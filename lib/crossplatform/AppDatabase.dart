import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  Database? _database;

  // Nombre de la tabla
  final String tableCredentials = 'credentials';

  // Columnas de la tabla
  final String columnId = 'id';
  final String columnToken = 'token';
  final String columnEmail = 'email';
  final String columnAccessCode = 'accessCode';

  AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  // Método para inicializar y abrir la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableCredentials (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnToken TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnAccessCode TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Método 1: Guardar los datos cuando aún no existen
  Future<void> saveCredentials(String token, String email, String accessCode) async {
    final db = await database;

    await db.insert(
      tableCredentials,
      {
        columnToken: token,
        columnEmail: email,
        columnAccessCode: accessCode,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Si ya existe, lo reemplaza
    );
  }

  // Método 2: Actualizar los datos si existen
  Future<void> updateCredentials(String token, String email, String accessCode) async {
    final db = await database;

    await db.update(
      tableCredentials,
      {
        columnToken: token,
        columnEmail: email,
        columnAccessCode: accessCode,
      },
      where: '$columnId = ?',
      whereArgs: [1], // Asumiendo que hay solo una fila con id = 1
    );
  }

  // Método 3: Obtener los datos
  Future<Map<String, dynamic>?> getCredentials() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableCredentials,
      where: '$columnId = ?',
      whereArgs: [1], // Solo debe haber un registro
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Método 4: Eliminar toda la base de datos y recrearla
  Future<void> deleteAndRecreateDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    // Eliminar la base de datos
    await deleteDatabase(path);

    // Recrear la base de datos
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableCredentials (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnToken TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnAccessCode TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
