class GlobalSearchRequest {
  String query;

  GlobalSearchRequest({
    required this.query,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query, // Convert the customer object to JSON
    };
  }
}

