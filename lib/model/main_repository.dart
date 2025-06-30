import 'package:ChaiBar/model/request/EncryptedWalletRequest.dart';
import 'package:ChaiBar/model/request/addRewardPointsRequest.dart';
import 'package:ChaiBar/model/request/deleteProfileRequest.dart';
import 'package:ChaiBar/model/request/getOrderDetailRequest.dart';
import 'package:ChaiBar/model/request/getRewardPointsRequest.dart';
import 'package:ChaiBar/model/request/itemReviewRequest.dart';
import 'package:ChaiBar/model/response/StoreSettingResponse.dart';
import 'package:ChaiBar/model/response/addRewardPointsResponse.dart';
import 'package:ChaiBar/model/response/appleTokenDetailsResponse.dart';
import 'package:ChaiBar/model/response/getRewardPointsResponse.dart';
import 'package:ChaiBar/model/response/getViewRewardPointsResponse.dart';
import 'package:ChaiBar/model/response/itemReviewResponse.dart';
import 'package:ChaiBar/model/response/orderDetailResponse.dart';

import '/model/request/CardDetailRequest.dart';
import '/model/request/CreateOrderRequest.dart';
import '/model/request/TransactionRequest.dart';
import '/model/request/createOtpChangePass.dart';
import '/model/request/editProfileRequest.dart';
import '/model/request/featuredListRequest.dart';
import '/model/request/getCategoryRequest.dart';
import '/model/request/getCouponDetailsRequest.dart';
import '/model/request/getCouponListRequest.dart';
import '/model/request/getHistoryRequest.dart';
import '/model/request/getProductsRequest.dart';
import '/model/request/globalSearchRequest.dart';
import '/model/request/markFavoriteRequest.dart';
import '/model/request/otpVerifyRequest.dart';
import '/model/request/signInRequest.dart';
import '/model/request/signUpRequest.dart';
import '/model/request/signUpWithGoogleRequest.dart';
import '/model/request/successCallbackRequest.dart';
import '/model/request/vendorSearchRequest.dart';
import '/model/request/verifyOtpChangePass.dart';
import '/model/response/couponListResponse.dart';
import '/model/response/PaymentDetailsResponse.dart';
import '/model/response/bannerListResponse.dart';
import '/model/response/categoryListResponse.dart';
import '/model/response/createOrderResponse.dart';
import '/model/response/createOtpChangePassResponse.dart';
import '/model/response/dashboardDataResponse.dart';
import '/model/response/favoriteListResponse.dart';
import '/model/response/featuredListResponse.dart';
import '/model/response/getApiAccessKeyResponse.dart';
import '/model/response/getCouponDetailsResponse.dart';
import '/model/response/getHistoryResponse.dart';
import '/model/response/globalSearchResponse.dart';
import '/model/response/locationListResponse.dart';
import '/model/response/markFavoriteResponse.dart';
import '/model/response/productListResponse.dart';
import '/model/response/profileResponse.dart';
import '/model/response/signInResponse.dart';
import '/model/response/signUpInitializeResponse.dart';
import '/model/response/signUpVerifyResponse.dart';
import '/model/response/storeStatusResponse.dart';
import '/model/response/successCallbackResponse.dart';
import '/model/response/tokenDetailsResponse.dart';
import '/model/response/vendorListResponse.dart';
import '/model/response/vendorSearchResponse.dart';
import '/model/services/baseService.dart';
import '/model/services/chaiBarCustomerService.dart';

class MainRepository {
  BaseService _baseService = ChaiBarCustomerService();

  Future<SignInResponse> signInWithPass(
      String value, SignInRequest signInRequest) async {
    print(signInRequest);
    dynamic response =
        await _baseService.postResponse(value, signInRequest);
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
        await _baseService.postResponse(value, signUpWithGoogleRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SignInResponse mediaList = SignInResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GetApiAccessKeyResponse> getApiAccessKey(
      String value, String auth) async {
    dynamic response =
        await _baseService.getCloverResponse(value, auth);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    GetApiAccessKeyResponse mediaList =
        GetApiAccessKeyResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<TokenDetailsResponse> getApiToken(
      String value, String apiKey, CardRequest cardRequest) async {
    dynamic response = await _baseService.postCloverResponse(
        value, apiKey, cardRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    TokenDetailsResponse mediaList = TokenDetailsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<AppleTokenDetailsResponse> getApiTokenForApplePay(
      String value, String apiKey, EncryptedWallet applePayTokenRequest) async {
    dynamic response = await _baseService.postCloverResponse(
        value, apiKey, applePayTokenRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    AppleTokenDetailsResponse mediaList = AppleTokenDetailsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<PaymentDetails> getFinalPaymentApi(
      String value, String auth, TransactionRequest transactionRequest) async {
    dynamic response = await _baseService.postCloverFinalPaymentResponse(
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
        await _baseService.postResponse(value, successCallbackRequest);
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
        await _baseService.postResponse(value, signUpRequest);
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
        await _baseService.postResponse(value, otpVerifyRequest);
    print(value);
    final jsonData = response;
    print(" ${jsonData}");
    SignUpVerifyResponse mediaList = SignUpVerifyResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<LocationListResponse> fetchLocationList(String value) async {
    dynamic response = await _baseService.getResponse(value);
    print(value);
    final jsonData = response;
    print(jsonData);
    LocationListResponse mediaList = LocationListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<VendorListResponse> fetchVendors(String value) async {
    dynamic response = await _baseService.getResponse(value);
    print(value);
    final jsonData = response;
    print(jsonData);
    VendorListResponse mediaList = VendorListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<StoreSettingResponse> fetchStoreSettingData(String value) async {
    dynamic response = await _baseService.getResponse(value);
    print(value);
    final jsonData = response;
    print(jsonData);
    StoreSettingResponse mediaList = StoreSettingResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<BannerListResponse> fetchBanners(String value) async {
    dynamic response = await _baseService.getResponse(value);
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
        await _baseService.postResponse(value, getCategoryRequest);
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
        await _baseService.postResponse(value, getCategoryRequest);
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
        await _baseService.postResponse(value, featuredListRequest);
    final jsonData = response;
    print(jsonData);
    FeaturedListResponse mediaList = FeaturedListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<FavoriteListResponse> fetchFavoritesProductList(
      String value, MarkFavoriteRequest markFavRequest) async {
    dynamic response =
        await _baseService.postResponse(value, markFavRequest);
    final jsonData = response;
    print(jsonData);
    FavoriteListResponse mediaList = FavoriteListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<MarkFavoriteResponse> markFavoriteData(
      String value, MarkFavoriteRequest markFavoriteRequest) async {
    print(markFavoriteRequest);
    dynamic response =
        await _baseService.putResponse(value, markFavoriteRequest);
    final jsonData = response;
    print(jsonData);
    MarkFavoriteResponse mediaList = MarkFavoriteResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<MarkFavoriteResponse> removeFavoriteData(
      String value, MarkFavoriteRequest request) async {
    dynamic response =
        await _baseService.deleteResponse(value, request);
    final jsonData = response;
    print(jsonData);
    MarkFavoriteResponse mediaList = MarkFavoriteResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<StoreStatusResponse> fetchStoreStatus(String value) async {
    dynamic response = await _baseService.getResponse(value);
    final jsonData = response;
    print(jsonData);
    StoreStatusResponse mediaList = StoreStatusResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<OrderDetailResponse> fetchOrderStatus(String value, GetOrderDetailRequest request) async {
    dynamic response = await _baseService.postResponse(value,request);
    final jsonData = response;
    print(jsonData);
    OrderDetailResponse mediaList = OrderDetailResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProfileResponse> fetchProfile(String value) async {
    dynamic response = await _baseService.getResponse(value);
    final jsonData = response;
    print(jsonData);
    ProfileResponse mediaList = ProfileResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GetViewRewardPointsResponse> fetchRedeemPointsApi(String value) async {
    dynamic response = await _baseService.getResponse(value);
    final jsonData = response;
    print(jsonData);
    GetViewRewardPointsResponse mediaList = GetViewRewardPointsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProfileResponse> editProfile(
      String value, EditProfileRequest editProfileRequest) async {
    dynamic response =
        await _baseService.putResponse(value, editProfileRequest);
    final jsonData = response;
    print(jsonData);
    ProfileResponse mediaList = ProfileResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProfileResponse> deleteProfile(
      String value, DeleteProfileRequest deleteProfileRequest) async {
    dynamic response =
        await _baseService.deleteResponse(value, deleteProfileRequest);
    final jsonData = response;
    print(jsonData);
    ProfileResponse mediaList = ProfileResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CouponListResponse> fetchCouponList(
      String value, GetCouponListRequest getCouponListRequest) async {
    print(getCouponListRequest);
    dynamic response =
        await _baseService.postResponse(value, getCouponListRequest);
    final jsonData = response;
    print(jsonData);
    CouponListResponse mediaList = CouponListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<ProductListResponse> fetchProductList(
      String value, GetProductsRequest getProductRequest) async {
    print(getProductRequest);
    dynamic response =
        await _baseService.postResponse(value, getProductRequest);
    final jsonData = response;
    print(jsonData);
    ProductListResponse mediaList = ProductListResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GlobalSearchResponse> fetchGlobalSearchResults(
      String value, GlobalSearchRequest globalSearchRequest) async {
    print(globalSearchRequest);
    dynamic response =
        await _baseService.postResponse(value, globalSearchRequest);
    final jsonData = response;
    print(jsonData);

    GlobalSearchResponse mediaList = GlobalSearchResponse.fromJson(jsonData);

    return mediaList;
  }

  Future<VendorSearchResponse> fetchVendorSearchResults(
      String value, VendorSearchRequest searchRequest) async {
    print(searchRequest);
    dynamic response =
        await _baseService.postResponse(value, searchRequest);
    final jsonData = response;
    print(jsonData);

    VendorSearchResponse mediaList = VendorSearchResponse.fromJson(jsonData);

    return mediaList;
  }

  Future<CouponDetailsResponse> fetchCouponDetails(
      String value, GetCouponDetailsRequest getCouponDetailsRequest) async {
    print(getCouponDetailsRequest);
    dynamic response = await _baseService.postResponse(
        value, getCouponDetailsRequest);
    final jsonData = response;
    print(jsonData);
    CouponDetailsResponse mediaList = CouponDetailsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<GetRewardPointsResponse> fetchRewardPointsDetails(
      String value, GetRewardPointsRequest getRewardPointsRequest) async {
    print("${getRewardPointsRequest}");
    dynamic response = await _baseService.postResponse(
        value, getRewardPointsRequest);
    final jsonData = response;
    print(jsonData);
    GetRewardPointsResponse mediaList = GetRewardPointsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<AddRewardPointsResponse?> addRewardPointsDetails(
      String value, AddRewardPointsRequest request) async {
    print("${request}");
    dynamic response = await _baseService.postResponse(
        value, request);
    final jsonData = response;
    print(jsonData);
    AddRewardPointsResponse mediaList = AddRewardPointsResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CreateOrderResponse> placeOrder(
      String value, CreateOrderRequest createOrderRequest) async {
    print(createOrderRequest);
    dynamic response =
        await _baseService.postResponse(value, createOrderRequest);
    final jsonData = response;
    print(jsonData);
    CreateOrderResponse mediaList = CreateOrderResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<CreateOtpChangePassResponse> CreateOtpChangePass(String value,
      CreateOtpChangePassRequest createOtpChangePassRequest) async {
    print(createOtpChangePassRequest);
    dynamic response = await _baseService.postResponse(
        value, createOtpChangePassRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    CreateOtpChangePassResponse mediaList =
        CreateOtpChangePassResponse.fromJson(jsonData);
    return mediaList;
  }


  Future<ItemReviewResponse> itemReviewRequestApi(String value,
      ItemReviewRequest request) async {
    print(request);
    dynamic response = await _baseService.postResponse(
        value, request);
    print(value);
    final jsonData = response;
    print(jsonData);
    ItemReviewResponse mediaList =
    ItemReviewResponse.fromJson(jsonData);
    return mediaList;
  }

  Future<SignUpInitializeResponse> VerifyOtpChangePass(
      String value, VerifyOtChangePassRequest verifyOtChangePassRequest) async {
    print(verifyOtChangePassRequest);
    dynamic response = await _baseService.postResponse(
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
        await _baseService.postResponse(value, getHistoryRequest);
    print(value);
    final jsonData = response;
    print(jsonData);
    GetHistoryResponse mediaList = GetHistoryResponse.fromJson(jsonData);
    return mediaList;
  }
}
