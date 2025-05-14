import 'package:ChaiBar/model/db/ChaiBarDB.dart';
import 'package:ChaiBar/model/db/DatabaseHelper.dart';

import 'dataBaseDao.dart';

class DBService {
  static final DBService _instance = DBService._internal();

  late final ChaiBarDB _db;
  bool _initialized = false;

  late final CartDataDao cartDao;
  late final FavoritesDataDao favoritesDao;
  late final CategoryDataDao categoryDao;
  late final ProductsDataDao productDao;
  late final DashboardDao dashboardDao;

  DBService._internal();

  static DBService get instance => _instance;

  /// Must be called once, usually at app startup or in main screen.
  Future<void> init() async {
    if (_initialized) return;
    _db = await DatabaseHelper().database;

    cartDao = _db.cartDao;
    favoritesDao = _db.favoritesDao;
    categoryDao = _db.categoryDao;
    productDao = _db.productDao;
    dashboardDao = _db.dashboardDao;

    _initialized = true;
  }
}
