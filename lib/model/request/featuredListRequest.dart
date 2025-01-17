class FeaturedListRequest {
  bool? featured;

  FeaturedListRequest({
    required this.featured,});

  Map<String, dynamic> toJson() {
    return {
      'featured': featured,
    };
  }
}
