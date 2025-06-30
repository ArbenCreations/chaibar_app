import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/response/productDataDB.dart';
import '../model/response/productListResponse.dart';

String extractNames(String fullName, bool isFirst) {
  List<String> nameParts = fullName.trim().split(' ');
  String firstName = nameParts.isNotEmpty ? nameParts.first : '';
  String lastName = nameParts.length > 1 ? nameParts.last : '';

  if (isFirst) {
    return firstName;
  } else {
    return lastName;
  }
}


bool isKeyboardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}


String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  if (input.contains("_")) {
    var replacedInput = input.replaceAll("_", " ");
    input = replacedInput;
  }
  return input[0].toUpperCase() + input.substring(1);
}


String nonCapitalizeString(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input.toLowerCase();
}

String convertDateFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);

  DateTime parsedDate = DateTime.parse(localTime);
  String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

  return formattedDate;
}

String convertUtcDateToLocal(String utcTime) {
  if (utcTime.isEmpty) {
    return utcTime;
  }
  DateTime utcDateTime = DateTime.parse(utcTime);
  DateTime localDateTime = utcDateTime.toLocal();
  return "${localDateTime.toString()}";
}

String convertDateTimeFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);

  DateTime parsedDate = DateTime.parse(localTime);
  String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);

  return formattedDate;
}
String convertTimeFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);

  DateTime parsedDate = DateTime.parse(localTime);
  String formattedDate = DateFormat('hh:mm a').format(parsedDate);

  return formattedDate;
}


String convertTime(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);
  DateTime date = DateTime.parse(localTime); // Example date and time
  String formattedTime =
      DateFormat('hh:mm a').format(date); // This will output "02:30 PM"
  return formattedTime;
}

void hideKeyBoard() {
  FocusManager.instance.primaryFocus?.unfocus();
}


bool hasMinLength(String value) {
  return value.length >= 8;
}

String safeUrl(String? url) {
  return (url == null || url.trim().isEmpty) ? "https://thechaibar.ca/" : url;
}

ProductDataDB getProductDataObject(ProductData item, int vendorId) {
  return ProductDataDB(
      description: item.description,
      imageUrl: item.imageUrl,
      addOnIdsList: item.addOnIdsList,
      categoryName: item.categoryName,
      addOnType: item.addOnType,
      addOn: item.addOn,
      deposit: item.deposit,
      price: item.price,
      productCategoryId: item.productCategoryId,
      productId: item.id,
      qtyLimit: item.qtyLimit,
      isBuy1Get1: item.isBuy1Get1,
      salePrice: item.salePrice,
      shortDescription: item.shortDescription,
      status: item.status,
      title: item.title,
      vendorId: vendorId,
      franchiseId: item.franchiseId,
      quantity: item.quantity,
      theme: item.theme,
      vendorName: item.vendorName,
      addedToCartAt: "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
      productSizesList: item.productSizesList);
}

ProductData getCartDataObject(ProductDataDB item, int vendorId) {
  return ProductData(
    quantity: int.parse("${item.quantity}"),
    vendorId: vendorId,
    franchiseId: item.franchiseId,
    title: item.title,
    status: item.status,
    shortDescription: item.shortDescription,
    salePrice: item.salePrice,
    qtyLimit: item.qtyLimit,
    isBuy1Get1: item.isBuy1Get1,
    productCategoryId: item.productCategoryId,
    price: item.price,
    deposit: item.deposit,
    categoryName: item.categoryName,
    addOn: item.addOn,
    imageUrl: item.imageUrl,
    description: item.description,
    createdAt: "",
    environmentalFee: "",
    featured: false,
    gst: null,
    id: item.productId,
    theme: item.theme,
    vendorName: item.vendorName,
    pst: null,
    updatedAt: "",
    vpt: null,
    addOnIdsList: item.addOnIdsList,
    addOnType: item.addOnType,
    productSizesList: item.productSizesList,
  );
}










