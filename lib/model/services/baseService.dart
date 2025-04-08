import 'dart:io';

abstract class BaseService {
  static const String baseUrl = "https://chaibar.utellorders.ca/";

  String getFullUrl(String endpoint) => "$baseUrl$endpoint";

  Future<dynamic> sendRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
  });

  Future<dynamic> postResponse(String url, dynamic requestBody);

  Future<dynamic> postCloverResponse(String url, String apiKey, dynamic phoneRequest);

  Future<dynamic> postCloverFinalPaymentResponse(String url, String apiKey, dynamic phoneRequest);

  Future<dynamic> putResponse(String url, dynamic requestBody);

  Future<dynamic> putCloverResponse(String url, String apiKey, dynamic requestBody) {
    return sendRequest(url: url, method: 'PUT', headers: {'Authorization': 'Bearer $apiKey'}, body: requestBody);
  }

  Future<dynamic> getResponse(String url);

  Future<dynamic> getCloverResponse(String url, String auth);

  Future<dynamic> deleteResponse(String url, dynamic requestBody);

}
