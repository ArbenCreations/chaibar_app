import 'package:ChaatBar/model/request/CardDetailRequest.dart';
import 'package:ChaatBar/model/request/CreateOrderRequest.dart';
import 'package:ChaatBar/model/request/TransactionRequest.dart';
import 'package:ChaatBar/model/request/createOtpChangePass.dart';
import 'package:ChaatBar/model/request/editProfileRequest.dart';
import 'package:ChaatBar/model/request/featuredListRequest.dart';
import 'package:ChaatBar/model/request/getCategoryRequest.dart';
import 'package:ChaatBar/model/request/getCouponDetailsRequest.dart';
import 'package:ChaatBar/model/request/getCouponListRequest.dart';
import 'package:ChaatBar/model/request/getHistoryRequest.dart';
import 'package:ChaatBar/model/request/getProductsRequest.dart';
import 'package:ChaatBar/model/request/globalSearchRequest.dart';
import 'package:ChaatBar/model/request/markFavoriteRequest.dart';
import 'package:ChaatBar/model/request/otpVerifyRequest.dart';
import 'package:ChaatBar/model/request/signInRequest.dart';
import 'package:ChaatBar/model/request/signUpRequest.dart';
import 'package:ChaatBar/model/request/signUpWithGoogleRequest.dart';
import 'package:ChaatBar/model/request/successCallbackRequest.dart';
import 'package:ChaatBar/model/request/vendorSearchRequest.dart';
import 'package:ChaatBar/model/request/verifyOtpChangePass.dart';
import 'package:ChaatBar/model/response/couponListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/PaymentDetailsResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/bannerListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/categoryListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/createOrderResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/createOtpChangePassResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/dashboardDataResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/favoriteListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/featuredListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/getApiAccessKeyResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/getCouponDetailsResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/getHistoryResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/globalSearchResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/locationListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/markFavoriteResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/productListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/profileResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/signInResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/signUpInitializeResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/signUpVerifyResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/storeStatusResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/successCallbackResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/tokenDetailsResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/vendorListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/vendorSearchResponse.dart';
import 'package:ChaatBar/model/services/base_service.dart';
import 'package:ChaatBar/model/services/chat_bar_customer_service.dart';

class MainRepository {
  BaseService _ChaatBarCustomerService = ChaatBarCustomerService();

  Future<SignInResponse> signInWithPass(
      String value, SignInRequest signInRequest) async {
    print(signInRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, signInRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SignInResponse mediaList = SignInResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<SignInResponse> signInWithGoogle(
      String value, SignUpWithGoogleRequest signUpWithGoogleRequest) async {
    print(signUpWithGoogleRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, signUpWithGoogleRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SignInResponse mediaList = SignInResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GetApiAccessKeyResponse> getApiAccessKey(
      String value, String auth) async {
    dynamic response =
        await _ChaatBarCustomerService.getCloverResponse(value, auth);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    GetApiAccessKeyResponse mediaList =
        GetApiAccessKeyResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<TokenDetailsResponse> getApiToken(
      String value, String apiKey, CardRequest cardRequest) async {
    dynamic response = await _ChaatBarCustomerService.postCloverResponse(
        value, apiKey, cardRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    TokenDetailsResponse mediaList = TokenDetailsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<PaymentDetails> getFinalPaymentApi(
      String value, String auth, TransactionRequest transactionRequest) async {
    dynamic response = await _ChaatBarCustomerService.postCloverFinalPaymentResponse(
        value, auth, transactionRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    PaymentDetails mediaList = PaymentDetails.fromJson(jsonData);
    return mediaList;
  }

  Future<SuccessCallbackResponse> successCallback(
      String value, SuccessCallbackRequest successCallbackRequest) async {
    print(successCallbackRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, successCallbackRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SuccessCallbackResponse mediaList =
    SuccessCallbackResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<SignUpInitializeResponse> signUpData(
      String value, SignUpRequest signUpRequest) async {
    print(signUpRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, signUpRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SignUpInitializeResponse mediaList =
        SignUpInitializeResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<SignUpVerifyResponse> signUpOtpVerifyData(
      String value, OtpVerifyRequest otpVerifyRequest) async {
    print(otpVerifyRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, otpVerifyRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SignUpVerifyResponse mediaList = SignUpVerifyResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<LocationListResponse> fetchLocationList(String value) async {
    dynamic response = await _ChaatBarCustomerService.getResponse(value);
    print(value);
    final jsonData = response;
    print(jsonData);
    LocationListResponse mediaList = LocationListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<VendorListResponse> fetchVendors(String value) async {
    dynamic response = await _ChaatBarCustomerService.getResponse(value);
    print(value);
    final jsonData = response;
    print(jsonData);
    VendorListResponse mediaList = VendorListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<BannerListResponse> fetchBanners(String value) async {
    dynamic response = await _ChaatBarCustomerService.getResponse(value);
    print(value);
    final jsonData = response;
    print(jsonData);
    BannerListResponse mediaList = BannerListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<DashboardDataResponse> fetchDashBoardData(
      String value, int? vendorId) async {
    GetCategoryRequest getCategoryRequest =
        GetCategoryRequest(vendorId: vendorId);

    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, getCategoryRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    DashboardDataResponse mediaList = DashboardDataResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CategoryListResponse> fetchProductCategoriesList(
      String value, int? vendorId) async {
    GetCategoryRequest getCategoryRequest =
        GetCategoryRequest(vendorId: vendorId);

    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, getCategoryRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    CategoryListResponse mediaList = CategoryListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<FeaturedListResponse> fetchFeaturedProductList(
      String value, FeaturedListRequest featuredListRequest) async {
    print(featuredListRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, featuredListRequest);
    final jsonData = response;
    print(jsonData);
    FeaturedListResponse mediaList = FeaturedListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<FavoriteListResponse> fetchFavoritesProductList(
      String value, MarkFavoriteRequest markFavRequest) async {
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, markFavRequest);
    final jsonData = response;
    print(jsonData);
    FavoriteListResponse mediaList = FavoriteListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<MarkFavoriteResponse> markFavoriteData(
      String value, MarkFavoriteRequest markFavoriteRequest) async {
    print(markFavoriteRequest);
    dynamic response =
        await _ChaatBarCustomerService.putResponse(value, markFavoriteRequest);
    final jsonData = response;
    print(jsonData);
    MarkFavoriteResponse mediaList = MarkFavoriteResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<MarkFavoriteResponse> removeFavoriteData(
      String value, MarkFavoriteRequest request) async {
    dynamic response =
        await _ChaatBarCustomerService.deleteResponse(value, request);
    final jsonData = response;
    print(jsonData);
    MarkFavoriteResponse mediaList = MarkFavoriteResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<StoreStatusResponse> fetchStoreStatus(String value) async {
    dynamic response = await _ChaatBarCustomerService.getResponse(value);
    final jsonData = response;
    print(jsonData);
    StoreStatusResponse mediaList = StoreStatusResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProfileResponse> fetchProfile(String value) async {
    dynamic response = await _ChaatBarCustomerService.getResponse(value);
    final jsonData = response;
    print(jsonData);
    ProfileResponse mediaList = ProfileResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProfileResponse> editProfile(
      String value, EditProfileRequest editProfileRequest) async {
    dynamic response =
        await _ChaatBarCustomerService.putResponse(value, editProfileRequest);
    final jsonData = response;
    print(jsonData);
    ProfileResponse mediaList = ProfileResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CouponListResponse> fetchCouponList(
      String value, GetCouponListRequest getCouponListRequest) async {
    print(getCouponListRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, getCouponListRequest);
    final jsonData = response;
    print(jsonData);
    CouponListResponse mediaList = CouponListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProductListResponse> fetchProductList(
      String value, GetProductsRequest getProductRequest) async {
    print(getProductRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, getProductRequest);
    final jsonData = response;
    print(jsonData);
    ProductListResponse mediaList = ProductListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GlobalSearchResponse> fetchGlobalSearchResults(
      String value, GlobalSearchRequest globalSearchRequest) async {
    print(globalSearchRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, globalSearchRequest);
    final jsonData = response;
    print(jsonData);

    GlobalSearchResponse mediaList = GlobalSearchResponse.fromJson(jsonData);

    return mediaList;
  }

  Future<VendorSearchResponse> fetchVendorSearchResults(
      String value, VendorSearchRequest searchRequest) async {
    print(searchRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, searchRequest);
    final jsonData = response;
    print(jsonData);

    VendorSearchResponse mediaList = VendorSearchResponse.fromJson(jsonData);

    return mediaList;
  }

  Future<CouponDetailsResponse> fetchCouponDetails(
      String value, GetCouponDetailsRequest getCouponDetailsRequest) async {
    print(getCouponDetailsRequest);
    dynamic response = await _ChaatBarCustomerService.postResponse(
        value, getCouponDetailsRequest);
    final jsonData = response;
    print(jsonData);
    CouponDetailsResponse mediaList = CouponDetailsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CreateOrderResponse> placeOrder(
      String value, CreateOrderRequest createOrderRequest) async {
    print(createOrderRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, createOrderRequest);
    final jsonData = response;
    print(jsonData);
    CreateOrderResponse mediaList = CreateOrderResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CreateOtpChangePassResponse> CreateOtpChangePass(String value,
      CreateOtpChangePassRequest createOtpChangePassRequest) async {
    print(createOtpChangePassRequest);
    dynamic response = await _ChaatBarCustomerService.postResponse(
        value, createOtpChangePassRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    CreateOtpChangePassResponse mediaList =
        CreateOtpChangePassResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<SignUpInitializeResponse> VerifyOtpChangePass(
      String value, VerifyOtChangePassRequest verifyOtChangePassRequest) async {
    print(verifyOtChangePassRequest);
    dynamic response = await _ChaatBarCustomerService.postResponse(
        value, verifyOtChangePassRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    SignUpInitializeResponse mediaList =
        SignUpInitializeResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GetHistoryResponse> getHistoryData(
      String value, GetHistoryRequest getHistoryRequest) async {
    print(getHistoryRequest);
    dynamic response =
        await _ChaatBarCustomerService.postResponse(value, getHistoryRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    GetHistoryResponse mediaList = GetHistoryResponse.fromJson(jsonData);
    return mediaList;
  }
}
