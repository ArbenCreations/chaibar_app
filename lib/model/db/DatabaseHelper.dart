import 'package:ChaiBar/model/db/ChaiBarDB.dart';
import 'package:floor/floor.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static ChaiBarDB? _database;

  DatabaseHelper._internal();

  Future<ChaiBarDB> get database async {
    if (_database != null) return _database!;
    _database = await $FloorChaiBarDB
        .databaseBuilder('basic_structure_database.db')
        .addMigrations([migration1to2, migration2to3, migration3to4]).build();
    return _database!;
  }
}

final Migration migration1to2 = Migration(1, 2, (database) async {
  final result = await database.rawQuery(
    "PRAGMA table_info(ProductData)",
  );
  final columnExists = result.any((col) => col['name'] == 'userVote');
  if (!columnExists) {
    await database.execute('ALTER TABLE ProductData ADD COLUMN userVote TEXT');
  }
});

final Migration migration2to3 = Migration(2, 3, (database) async {
  final result = await database.rawQuery(
    "PRAGMA table_info(DashboardDataResponse)",
  );
  final columnExists = result.any((col) => col['name'] == 'activeOrderCounts');
  if (!columnExists) {
    await database.execute('ALTER TABLE DashboardDataResponse ADD COLUMN activeOrderCounts INTEGER');
  }
});


final Migration migration3to4 = Migration(3, 4, (database) async {
  final result = await database.rawQuery(
    "PRAGMA table_info(ProductDataDB)",
  );
  final columnExists = result.any((col) => col['name'] == 'addOnIdsList');
  if (!columnExists) {
    await database.execute('ALTER TABLE ProductDataDB ADD COLUMN addOnIdsList TEXT');
  }
});

