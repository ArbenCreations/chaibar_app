import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '/model/db/dataBaseDao.dart';
import '/model/response/favoriteDataDB.dart';
import '/model/response/productDataDB.dart';
import '../response/categoryDataDB.dart';
import '../response/dashboardDataResponse.dart';
import '../response/productListResponse.dart';
import 'listConverter.dart';

part 'ChaiBarDB.g.dart'; // the generated code will be there

@TypeConverters([ListConverter, ProductSizeListConverter])
@Database(version: 4, entities: [
  CategoryDataDB,
  ProductDataDB,
  ProductData,
  FavoritesDataDb,
  DashboardDataResponse
])
abstract class ChaiBarDB extends FloorDatabase {
  CartDataDao get cartDao;

  FavoritesDataDao get favoritesDao;

  CategoryDataDao get categoryDao;

  ProductsDataDao get productDao;

  DashboardDao get dashboardDao;
}
