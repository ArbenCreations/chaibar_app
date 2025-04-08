import 'dart:convert';
import 'dart:io';
import '/model/services/baseService.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import '../../utils/Helper.dart';
import '../../utils/apis/app_exception.dart';

class ChaiBarCustomerService extends BaseService {
  String? _token;

  Future<void> _initializeToken() async {
    Helper.getUserToken().then((onValue) {
      _token = onValue; //?? VendorData();
    });
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    await _initializeToken();
    return {
      'Content-Type': isMultipart ? 'multipart/form-data' : 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_token',
      'Accept-Language': 'en',
      'App-Type': 'mobile',
    };
  }

  Future<Map<String, String>> getCloverHeaders(String auth) async {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $auth',
    };
  }

  Future<Map<String, String>> getCloverTokenHeader(String apiKey) async {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'apikey': '$apiKey',
    };
  }

  void _logRequest(String url, Map<String, String> headers, dynamic body) {
    print('Request: $url');
    print('Headers: $headers');
    if (body != null) print('Body: ${jsonEncode(body)}');
  }

  void _logResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() request) async {
    try {
      await Future.delayed(Duration(milliseconds: 2));
      final response = await request();
      _logResponse(response);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  Future<dynamic> sendRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _sendRequest(() {
      Uri uri = Uri.parse(getFullUrl(url));
      switch (method) {
        case 'POST':
          return http.post(uri, headers: headers, body: jsonEncode(body));
        case 'PUT':
          return http.put(uri, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          return http.delete(uri, headers: headers, body: jsonEncode(body));
        default:
          return http.get(uri, headers: headers);
      }
    });
  }

  @override
  Future<dynamic> postResponse(String url, dynamic requestBody) async {
    var headers = await _getHeaders();
    _logRequest(url, headers, requestBody);
    return sendRequest(url: url, method: 'POST', headers: headers, body: requestBody);
  }

  @override
  Future<dynamic> putResponse(String url, dynamic requestBody) async {
    var headers = await _getHeaders();
    _logRequest(url, headers, requestBody);
    return sendRequest(url: url, method: 'PUT', headers: headers, body: requestBody);
  }

  @override
  Future<dynamic> deleteResponse(String url, dynamic requestBody) async {
    var headers = await _getHeaders();
    _logRequest(url, headers, requestBody);
    return sendRequest(url: url, method: 'DELETE', headers: headers, body: requestBody);
  }

  @override
  Future<dynamic> getResponse(String url) async {
    var headers = await _getHeaders();
    _logRequest(url, headers, null);
    return sendRequest(url: url, method: 'GET', headers: headers);
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 422:
        return jsonDecode(response.body);
      case 400:
      case 500:
        var responseBody = jsonDecode(response.body);
        throw BadRequestException(responseBody['message'] ?? 'Error');
      case 401:
      case 403:
      case 404:
        var responseBody = jsonDecode(response.body);
        throw FetchDataException(responseBody['message'] ?? 'Error');
      default:
        throw FetchDataException('Unexpected error: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future getCloverResponse(String url, String auth) async {
    dynamic responseJson;
    try {
      await Future.delayed(Duration(milliseconds: 2));
      var headers = await getCloverHeaders(auth);

      printRequestDetails(url, headers, {});

      final response = await http.get(Uri.parse(url), headers: headers);
      responseJson = returnResponse(response);
      printResponseDetails(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }


  void printRequestDetails(
      String url, Map<String, String> headers, dynamic body) {
    print('Request URL: $url');
    print('Request Headers: $headers');
    if (body != null) {
      print('Request Body: ${jsonEncode(body)}');
    }
  }

  void printResponseDetails(http.Response response) {
    print('Response Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    try {
      var responseBody = jsonDecode(response.body);
      print('Success: ${responseBody['success']}');
      print('Message: ${responseBody['message']}');
      print('Status: ${responseBody['status']}');
      print('Data: ${responseBody['data']}');
    } catch (e) {
      print('Error parsing response body: $e');
    }
  }



  @visibleForTesting
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 422:
        var responseBody = jsonDecode(response.body);
        print("Message >>::${responseBody['statusCode']}");
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 401:
      //final responseBody = response;
        var responseBody = jsonDecode(response.body);
        print("Message >>::${responseBody['message']}");
        dynamic responseJson = jsonDecode(responseBody['message']);
        return responseJson;
    //throw UnauthorisedException(response.body.toString());
      case 403:
        {
          //var responseBody = jsonDecode(response);
          final responseBody = response;
          print("Message ${responseBody}");
          dynamic responseJson = jsonDecode(response.body);
          return responseJson;
          // throw UnauthorisedException("${responseBody['message']}");
        }
      case 404:
      //final responseBody = response;
        var responseBody = jsonDecode(response.body);
        print("Message >>::${responseBody['message']}");
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
    //throw UnauthorisedException(response.body.toString());
      case 500:
        throw BadRequestException(response.body.toString());
      default:
        throw FetchDataException('Error occured while communication with server' +
            ' with status code : ${response.statusCode} ${response.body.toString()}');
    }
  }


  @override
  Future<dynamic> postCloverResponse(
      String url, String apiKey, dynamic requestBody) async {
    dynamic responseJson;
    try {
      await Future.delayed(Duration(milliseconds: 2));
      var headers = await getCloverTokenHeader(apiKey);

      printRequestDetails(url, headers, requestBody);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      responseJson = returnResponse(response);
      printResponseDetails(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  @override
  Future<dynamic> postCloverFinalPaymentResponse(
      String url, String auth, dynamic requestBody) async {
    dynamic responseJson;
    try {
      await Future.delayed(Duration(milliseconds: 2));
      var headers = await getCloverHeaders(auth);

      printRequestDetails(url, headers, requestBody);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      responseJson = returnResponse(response);
      printResponseDetails(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }


}
