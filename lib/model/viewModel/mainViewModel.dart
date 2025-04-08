import 'dart:convert';

import 'package:ChaiBar/model/request/deleteProfileRequest.dart';

import '../request/addRewardPointsRequest.dart';
import '../request/getRewardPointsRequest.dart';
import '../request/itemReviewRequest.dart';
import '../response/addRewardPointsResponse.dart';
import '../response/getRewardPointsResponse.dart';
import '../response/getViewRewardPointsResponse.dart';
import '../response/itemReviewResponse.dart';
import '/model/main_repository.dart';
import '/model/request/TransactionRequest.dart';
import '/model/request/featuredListRequest.dart';
import '/model/request/getCouponListRequest.dart';
import '/model/request/getHistoryRequest.dart';
import '/model/request/getProductsRequest.dart';
import '/model/request/globalSearchRequest.dart';
import '/model/request/markFavoriteRequest.dart';
import '/model/request/signUpRequest.dart';
import '/model/request/vendorSearchRequest.dart';
import '/model/response/couponListResponse.dart';
import '/model/response/bannerListResponse.dart';
import '/model/response/categoryListResponse.dart';
import '/model/response/favoriteListResponse.dart';
import '/model/response/featuredListResponse.dart';
import '/model/response/getApiAccessKeyResponse.dart';
import '/model/response/getHistoryResponse.dart';
import '/model/response/globalSearchResponse.dart';
import '/model/response/locationListResponse.dart';
import '/model/response/productListResponse.dart';
import '/model/response/profileResponse.dart';
import '/model/response/signInResponse.dart';
import '/model/response/signUpInitializeResponse.dart';
import '/model/response/signUpVerifyResponse.dart';
import '/model/response/vendorSearchResponse.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/apis/api_response.dart';
import '../request/CardDetailRequest.dart';
import '../request/CreateOrderRequest.dart';
import '../request/createOtpChangePass.dart';
import '../request/editProfileRequest.dart';
import '../request/getCouponDetailsRequest.dart';
import '../request/otpVerifyRequest.dart';
import '../request/signInRequest.dart';
import '../request/signUpWithGoogleRequest.dart';
import '../request/successCallbackRequest.dart';
import '../request/verifyOtpChangePass.dart';
import '../response/ErrorResponse.dart';
import '../response/PaymentDetailsResponse.dart';
import '../response/createOrderResponse.dart';
import '../response/createOtpChangePassResponse.dart';
import '../response/dashboardDataResponse.dart';
import '../response/getCouponDetailsResponse.dart';
import '../response/markFavoriteResponse.dart';
import '../response/storeStatusResponse.dart';
import '../response/successCallbackResponse.dart';
import '../response/tokenDetailsResponse.dart';
import '../response/vendorListResponse.dart';

class MainViewModel with ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  ApiResponse get response {
    return _apiResponse;
  }

  Future<void> signInWithPass(String value, SignInRequest signInRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "${signInRequest.customer?.email}");
    notifyListeners();
    try {
      //print(signInRequest.customer.phoneNumber);
      SignInResponse signInResponse =
          await MainRepository().signInWithPass(value, signInRequest);
      print("Yess" + "${signInResponse.customer?.firstName}");
      //_apiResponse = ApiResponse.completed(signInResponse);
      if (signInResponse.status == 200 || signInResponse.status == 201) {
        _apiResponse = ApiResponse.completed(signInResponse);
      } else {
        _apiResponse = ApiResponse.error(signInResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print("signInResponse $e");
    }
    notifyListeners();
  }


  Future<void> signInWithGoogle(String value, SignUpWithGoogleRequest signUpWithGoogleRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "${signUpWithGoogleRequest.customer?.email}");
    notifyListeners();
    try {
      //print(signInRequest.customer.phoneNumber);
      SignInResponse signInResponse =
          await MainRepository().signInWithGoogle(value, signUpWithGoogleRequest);
      print("Yess" + "${signInResponse.customer?.firstName}");
      //_apiResponse = ApiResponse.completed(signInResponse);
      if (signInResponse.status == 200 || signInResponse.status == 201) {
        _apiResponse = ApiResponse.completed(signInResponse);
      } else {
        _apiResponse = ApiResponse.error(signInResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print("signInResponse $e");
    }
    notifyListeners();
  }

  Future<void> getApiAccessKey(String value, String auth) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "");
    notifyListeners();
    try {
      GetApiAccessKeyResponse getApiAccessKeyResponse =
          await MainRepository().getApiAccessKey(value, auth);
      print("Yess" + "${getApiAccessKeyResponse.apiAccessKey}");
      if (getApiAccessKeyResponse.apiAccessKey?.isNotEmpty == true ||
          getApiAccessKeyResponse.active == true) {
        _apiResponse = ApiResponse.completed(getApiAccessKeyResponse);
      } else {
        _apiResponse = ApiResponse.error("${getApiAccessKeyResponse.message}");
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print("signInResponse $e");
    }
    notifyListeners();
  }

  Future<void> getApiToken(
      String value, String apiKey, CardRequest cardRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "");
    notifyListeners();
    try {
      TokenDetailsResponse tokenDetailsResponse =
      await MainRepository().getApiToken(value, apiKey, cardRequest);
      print("Yess: ${tokenDetailsResponse.message}");

      if (tokenDetailsResponse.id?.isNotEmpty == true) {
        _apiResponse = ApiResponse.completed(tokenDetailsResponse);
      } else {
        _apiResponse = ApiResponse.error(tokenDetailsResponse.message);
      }
    } catch (e) {
      print("signInResponse: ${e.toString()}");
      _apiResponse = ApiResponse.error(e.toString());

      try {
        // Check if the error message contains JSON
        int jsonStartIndex = e.toString().indexOf('{');
        if (jsonStartIndex == -1) {
          throw FormatException("Invalid error format: JSON not found");
        }

        // Extract and clean the JSON string
        String jsonString = e.toString().substring(jsonStartIndex).trim();
        print("Extracted JSON: $jsonString");

        // Decode JSON safely
        final Map<String, dynamic> decodedJson = jsonDecode(jsonString);

        // Parse error response
        ErrorResponse errorResponse = ErrorResponse.fromJson(decodedJson);
        _apiResponse = ApiResponse.error(errorResponse.error.message);

        print("signInResponse: ${errorResponse.error.message}");
      } catch (jsonError) {
        print("JSON Parsing Error: $jsonError");
        _apiResponse = ApiResponse.error("An unexpected error occurred.");
      }
    }

    notifyListeners();
  }

  Future<void> getFinalPaymentApi(
      String value, String auth, TransactionRequest transactionRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "");
    notifyListeners();
    try {
      PaymentDetails paymentDetails = await MainRepository()
          .getFinalPaymentApi(value, auth, transactionRequest);
      print("Yess" + "${paymentDetails.id}");
      if (paymentDetails.id?.isNotEmpty == true) {
        _apiResponse = ApiResponse.completed(paymentDetails);
      } else {
        _apiResponse = ApiResponse.error("${paymentDetails.message}");
      }
    } catch (e) {
      // Deserialize JSON string to Dart object
      int jsonStartIndex = e.toString().indexOf('{');
      String jsonString = e.toString().substring(jsonStartIndex);
      final Map<String, dynamic> decodedJson = jsonDecode(jsonString);
      ErrorResponse errorResponse = ErrorResponse.fromJson(decodedJson);
      _apiResponse = ApiResponse.error("${errorResponse.error.message}");
      print("signInResponse ${errorResponse.error.message}");
    }
    notifyListeners();
  }

  Future<void> successCallback(String value, SuccessCallbackRequest successCallbackRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "${successCallbackRequest?.transactionId}");
    notifyListeners();
    try {
      //print(signInRequest.customer.phoneNumber);
      SuccessCallbackResponse successCallbackResponse =
          await MainRepository().successCallback(value, successCallbackRequest);
      print("Yess" + "${successCallbackResponse.order?.transactionId}");
      //_apiResponse = ApiResponse.completed(signInResponse);
      if (successCallbackResponse.status == 200 ||
          successCallbackResponse.status == 201) {
        print("success");
        _apiResponse = ApiResponse.completed(successCallbackResponse);
      } else {
        _apiResponse = ApiResponse.error(successCallbackResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
      print("signInResponse $e");
    }
    notifyListeners();
  }

  Future<void> signUpData(String value, SignUpRequest signUpRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "${signUpRequest.customer?.firstName}");
    notifyListeners();
    try {
      //print(signInRequest.customer.phoneNumber);
      SignUpInitializeResponse signUpInitializeResponse =
          await MainRepository().signUpData(value, signUpRequest);
      print("Yess" + "${signUpInitializeResponse.phoneNumber}");
      //_apiResponse = ApiResponse.completed(signInResponse);
      if (signUpInitializeResponse.status == 200 ||
          signUpInitializeResponse.status == 201) {
        print("success");
        _apiResponse = ApiResponse.completed(signUpInitializeResponse);
      } else {
        _apiResponse = ApiResponse.error(signUpInitializeResponse.message?.contains("401")  == true ? signUpInitializeResponse.data : signUpInitializeResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print("signInResponse $e");
    }
    notifyListeners();
  }

  Future<void> signUpOtpVerifyData(
      String value, OtpVerifyRequest otpVerifyRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    print("Yess" + "${otpVerifyRequest.customer.phoneNumber}");
    notifyListeners();
    try {
      //print(signInRequest.customer.phoneNumber);
      SignUpVerifyResponse signUpResponse =
          await MainRepository().signUpOtpVerifyData(value, otpVerifyRequest);
      print("Yess" + "${signUpResponse.customer?.firstName}");
      //_apiResponse = ApiResponse.completed(signInResponse);
      if (signUpResponse.status == 200 || signUpResponse.status == 201) {
        _apiResponse = ApiResponse.completed(signUpResponse);
      } else {
        _apiResponse = ApiResponse.error(signUpResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print("signInResponse $e");
    }
    notifyListeners();
  }

  Future<void> fetchLocationList(String value) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      LocationListResponse locationListResponse =
          await MainRepository().fetchLocationList(value);
      print("Yess" + locationListResponse.message.toString());
      if (locationListResponse.status == 200 ||
          locationListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(locationListResponse);
      } else {
        _apiResponse = ApiResponse.error(locationListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(" catch ${e}");
    }
    notifyListeners();
  }

  Future<void> fetchVendors(String value) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      VendorListResponse vendorListResponse =
          await MainRepository().fetchVendors(value);
      print("Yess" + vendorListResponse.message.toString());
      print("image" + "${vendorListResponse.vendors?[0].vendorImage}");

      //_apiResponse = ApiResponse.completed(countryListResponse);
      if (vendorListResponse.status == 200 ||
          vendorListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(vendorListResponse);
      } else {
        _apiResponse = ApiResponse.error(vendorListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(" catch ${e}");
    }
    notifyListeners();
  }

  Future<void> fetchBanners(String value) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      BannerListResponse bannerListResponse =
          await MainRepository().fetchBanners(value);
      print("Yess" + bannerListResponse.message.toString());
      print("image" + "${bannerListResponse.data?[0].title}");

      //_apiResponse = ApiResponse.completed(countryListResponse);
      if (bannerListResponse.status == 200 ||
          bannerListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(bannerListResponse);
      } else {
        _apiResponse = ApiResponse.error(bannerListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(" catch ${e}");
    }
    notifyListeners();
  }

  Future<void> fetchDashboardData(String value, int? vendorId) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      DashboardDataResponse dashboardDataResponse =
          await MainRepository().fetchDashBoardData(value, vendorId);
      print("FetchDashboardData" + dashboardDataResponse.message.toString());

      //_apiResponse = ApiResponse.completed(countryListResponse);
      if (dashboardDataResponse.status == 200 ||
          dashboardDataResponse.status == 201) {
        _apiResponse = ApiResponse.completed(dashboardDataResponse);
      } else {
        _apiResponse = ApiResponse.error(dashboardDataResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(" catch ${e}");
    }
    notifyListeners();
  }

  Future<void> fetchCategoriesList(String value, int? vendorId) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      CategoryListResponse categoryListResponse =
          await MainRepository().fetchProductCategoriesList(value, vendorId);
      print("FetchCategoriesList" + categoryListResponse.message.toString());

      //_apiResponse = ApiResponse.completed(countryListResponse);
      if (categoryListResponse.status == 200 ||
          categoryListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(categoryListResponse);
      } else {
        _apiResponse = ApiResponse.error(categoryListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(" catch ${e}");
    }
    notifyListeners();
  }

  Future<void> fetchFeaturedProductList(
      String value, FeaturedListRequest featuredListRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(featuredListRequest.featured);

      FeaturedListResponse featuredListResponse = await MainRepository()
          .fetchFeaturedProductList(value, featuredListRequest);
      print("Yess" + featuredListResponse.products.toString());
      if (featuredListResponse.status == 200 ||
          featuredListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(featuredListResponse);
      } else {
        print("viewmodel ${featuredListResponse.message}");
        _apiResponse = ApiResponse.error(featuredListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchFavoritesProductList(
      String value, MarkFavoriteRequest markFavRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      FavoriteListResponse favoriteListResponse = await MainRepository()
          .fetchFavoritesProductList(value, markFavRequest);
      print("Yess" + favoriteListResponse.products.toString());
      if (favoriteListResponse.status == 200 ||
          favoriteListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(favoriteListResponse);
      } else {
        print("viewmodel ${favoriteListResponse.message}");
        _apiResponse = ApiResponse.error(favoriteListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> markFavoriteData(
      String value, MarkFavoriteRequest markFavoriteRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(markFavoriteRequest.productId);

      MarkFavoriteResponse markFavoriteResponse =
          await MainRepository().markFavoriteData(value, markFavoriteRequest);
      print("MarkFavoriteData" + markFavoriteResponse.toString());
      if (markFavoriteResponse.status == 200 ||
          markFavoriteResponse.status == 201) {
        _apiResponse = ApiResponse.completed(markFavoriteResponse);
      } else {
        print("viewmodel ${markFavoriteResponse.message}");
        _apiResponse = ApiResponse.error(markFavoriteResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> removeFavoriteData(
      String value, MarkFavoriteRequest markFavRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      MarkFavoriteResponse markFavoriteResponse =
          await MainRepository().removeFavoriteData(value, markFavRequest);
      print("Yess" + markFavoriteResponse.toString());
      if (markFavoriteResponse.status == 200 ||
          markFavoriteResponse.status == 201) {
        _apiResponse = ApiResponse.completed(markFavoriteResponse);
      } else {
        print("viewmodel ${markFavoriteResponse.message}");
        _apiResponse = ApiResponse.error(markFavoriteResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchStoreStatus(String value) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      StoreStatusResponse storeStatusResponse =
          await MainRepository().fetchStoreStatus(value);
      if (storeStatusResponse.status == 200 ||
          storeStatusResponse.status == 201) {
        _apiResponse = ApiResponse.completed(storeStatusResponse);
      } else {
        print("viewmodel ${storeStatusResponse.message}");
        _apiResponse = ApiResponse.error(storeStatusResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchProfile(String value) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      ProfileResponse profileResponse =
          await MainRepository().fetchProfile(value);
      print("Yess" + profileResponse.firstName.toString());
      if (profileResponse.status == 200 || profileResponse.status == 201) {
        _apiResponse = ApiResponse.completed(profileResponse);
      } else {
        print("viewmodel ${profileResponse.message}");
        _apiResponse = ApiResponse.error(profileResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchRedeemPointsApi(String value) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      GetViewRewardPointsResponse profileResponse =
          await MainRepository().fetchRedeemPointsApi(value);
      if (profileResponse.status == 200 || profileResponse.status == 201) {
        _apiResponse = ApiResponse.completed(profileResponse);
      } else {
        print("viewmodel ${profileResponse.message}");
        _apiResponse = ApiResponse.error(profileResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> editProfile(
      String value, EditProfileRequest editProfileRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      ProfileResponse profileResponse =
          await MainRepository().editProfile(value, editProfileRequest);
      print("Yess" + profileResponse.firstName.toString());
      if (profileResponse.status == 200 || profileResponse.status == 201) {
        _apiResponse = ApiResponse.completed(profileResponse);
      } else {
        print("viewmodel ${profileResponse.message}");
        _apiResponse = ApiResponse.error(profileResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> deleteProfile(
      String value, DeleteProfileRequest deleteProfileRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      ProfileResponse profileResponse =
          await MainRepository().deleteProfile(value, deleteProfileRequest);
      print("Yess" + profileResponse.firstName.toString());
      if (profileResponse.status == 200 || profileResponse.status == 201) {
        _apiResponse = ApiResponse.completed(profileResponse);
      } else {
        print("viewmodel ${profileResponse.message}");
        _apiResponse = ApiResponse.error(profileResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchCouponList(
      String value, GetCouponListRequest getCouponListRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      print(getCouponListRequest.vendorId);
      CouponListResponse couponListResponse =
          await MainRepository().fetchCouponList(value, getCouponListRequest);
      print("Yess" + couponListResponse.status.toString());
      if (couponListResponse.status == 200 ||
          couponListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(couponListResponse);
      } else {
        print("viewmodel ${couponListResponse.message}");
        _apiResponse = ApiResponse.error(couponListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchProductList(
      String value, GetProductsRequest getProductRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(getProductRequest.categoryId);

      ProductListResponse productListResponse =
          await MainRepository().fetchProductList(value, getProductRequest);
      print("Yess" + productListResponse.products.toString());
      if (productListResponse.status == 200 ||
          productListResponse.status == 201) {
        _apiResponse = ApiResponse.completed(productListResponse);
      } else {
        print("viewmodel ${productListResponse.message}");
        _apiResponse = ApiResponse.error(productListResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchGlobalSearchResults(
      String value, GlobalSearchRequest globalSearchRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(globalSearchRequest.query);

      GlobalSearchResponse globalSearchResponse = await MainRepository()
          .fetchGlobalSearchResults(value, globalSearchRequest);
      print("Yess" + "${globalSearchResponse.data?[0].product?.title}");
      if (globalSearchResponse.status == 200 ||
          globalSearchResponse.status == 201) {
        _apiResponse = ApiResponse.completed(globalSearchResponse);
      } else {
        print("viewmodel ${globalSearchResponse.message}");
        _apiResponse = ApiResponse.error(globalSearchResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchVendorSearchResults(
      String value, VendorSearchRequest vendorSearchRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(vendorSearchRequest.query);

      VendorSearchResponse vendorSearchResponse = await MainRepository()
          .fetchVendorSearchResults(value, vendorSearchRequest);
      print("Yess" + "${vendorSearchResponse.data?[0].title}");
      if (vendorSearchResponse.status == 200 ||
          vendorSearchResponse.status == 201) {
        _apiResponse = ApiResponse.completed(vendorSearchResponse);
      } else {
        print("viewmodel ${vendorSearchResponse.message}");
        _apiResponse = ApiResponse.error(vendorSearchResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchCouponDetails(
      String value, GetCouponDetailsRequest getCouponDetailsRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(getCouponDetailsRequest.couponCode);

      CouponDetailsResponse couponDetailsResponse = await MainRepository()
          .fetchCouponDetails(value, getCouponDetailsRequest);
      print("Yess" + "${couponDetailsResponse.discount}");
      if (couponDetailsResponse.status == 200 ||
          couponDetailsResponse.status == 201) {
        _apiResponse = ApiResponse.completed(couponDetailsResponse);
      } else {
        print("viewmodel ${couponDetailsResponse.message}");
        _apiResponse = ApiResponse.error(couponDetailsResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> fetchRewardPointsDetails(
      String value, GetRewardPointsRequest getRewardPointsRequest) async
  {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      GetRewardPointsResponse response = await MainRepository()
          .fetchRewardPointsDetails(value, getRewardPointsRequest);
      print("Yess" + "${response.totalPoints}");
      if (response.status == 200 ||
          response.status == 201) {
        _apiResponse = ApiResponse.completed(response);
      } else {
        print("viewmodel ${response.message}");
        _apiResponse = ApiResponse.error(response.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> addRewardPointsDetails(
      String value, AddRewardPointsRequest addRewardPointsRequest) async
  {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      AddRewardPointsResponse? response = await MainRepository()
          .addRewardPointsDetails(value, addRewardPointsRequest);
      if (response?.status == 200 ||
          response?.status == 201) {
        print("addRewardPointsRequest ${response?.pointsEarned}");
        _apiResponse = ApiResponse.completed(response);
      } else {
        print("viewmodel ${response?.message}");
        _apiResponse = ApiResponse.error(response?.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> placeOrder(
      String value, CreateOrderRequest createOrderRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    //String requestAsString = phoneRequestToString(request);
    notifyListeners();
    try {
      print(createOrderRequest.order.phoneNumber);

      CreateOrderResponse createOrderResponse =
          await MainRepository().placeOrder(value, createOrderRequest);
      print("Yess" + "${createOrderResponse.order?.id}");
      if (createOrderResponse.responseStatus == 200 ||
          createOrderResponse.responseStatus == 201) {
        _apiResponse = ApiResponse.completed(createOrderResponse);
      } else {
        print("viewmodel ${createOrderResponse.message}");
        _apiResponse = ApiResponse.error(createOrderResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> CreateOtpChangePass(String value,
      CreateOtpChangePassRequest createOtpChangePassRequest) async {
    _apiResponse = ApiResponse.loading('Loading');

    notifyListeners();
    try {
      print(createOtpChangePassRequest.email);

      CreateOtpChangePassResponse createOtpChangePassResponse =
          await MainRepository()
              .CreateOtpChangePass(value, createOtpChangePassRequest);
      print("Yess" + "${createOtpChangePassResponse.email}");

      if (createOtpChangePassResponse.status == 200 ||
          createOtpChangePassResponse.status == 201) {
        _apiResponse = ApiResponse.completed(createOtpChangePassResponse);
      } else {
        _apiResponse = ApiResponse.error(createOtpChangePassResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> itemReviewRequestApi(String value,
      ItemReviewRequest createOtpChangePassRequest) async {
    _apiResponse = ApiResponse.loading('Loading');

    notifyListeners();
    try {
      ItemReviewResponse response =
          await MainRepository()
              .itemReviewRequestApi(value, createOtpChangePassRequest);
      print("Yess" + "${response.data}");

      if (response.status == 200 ||
          response.status == 201) {
        _apiResponse = ApiResponse.completed(response);
      } else {
        _apiResponse = ApiResponse.error(response.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> VerifyOtpChangePass(
      String value, VerifyOtChangePassRequest verifyOtChangePassRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      SignUpInitializeResponse response = await MainRepository()
          .VerifyOtpChangePass(value, verifyOtChangePassRequest);
      if (response.status == 200 || response.status == 201) {
        _apiResponse = ApiResponse.completed(response);
      } else {
        _apiResponse = ApiResponse.error(response.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  Future<void> getHistoryData(
      String value, GetHistoryRequest getHistoryRequest) async {
    _apiResponse = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      GetHistoryResponse getHistoryResponse =
          await MainRepository().getHistoryData(value, getHistoryRequest);
      if (getHistoryResponse.status == 200 ||
          getHistoryResponse.status == 201) {
        _apiResponse = ApiResponse.completed(getHistoryResponse);
      } else {
        _apiResponse = ApiResponse.error(getHistoryResponse.message);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString().contains("<!DOCTYPE html>") ? "Something went wrong!" : e.toString());
      print(e);
    }
    notifyListeners();
  }

  /// Call the media service and gets the data of requested media data of
  /// an artist.
}
