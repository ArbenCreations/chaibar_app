
class GetHistoryRequest {
  int? pageNumber;
  int? pageSize;
  int? status;

  GetHistoryRequest(
      {required this.pageNumber,
        required this.pageSize,
        required this.status});

  Map<String, dynamic> toJson() {
    return {
      'page_number': pageNumber,
      'page_size': pageSize,
      'status': status,
    };
  }
}