import 'dart:async';
import 'package:ChaatBar/model/db/dao.dart';
import 'package:ChaatBar/model/response/rf_bite/favoriteDataDB.dart';
import 'package:ChaatBar/model/response/rf_bite/productDataDB.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../response/rf_bite/categoryDataDB.dart';
import '../response/rf_bite/dashboardDataResponse.dart';
import '../response/rf_bite/productListResponse.dart';
import 'list_converter.dart';

part 'ChaatBarDatabase.g.dart'; // the generated code will be there

@TypeConverters([ListConverter, ProductSizeListConverter])
@Database(version: 1, entities: [CategoryDataDB,ProductDataDB, ProductData, FavoritesDataDb, DashboardDataResponse ])
abstract class ChaatBarDatabase extends FloorDatabase {
  CartDataDao get cartDao;
  FavoritesDataDao get favoritesDao;
  CategoryDataDao get categoryDao;
  ProductsDataDao get productDao;
  DashboardDao get dashboardDao;
}