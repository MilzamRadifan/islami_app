class CitySearchResponse {
  final bool status;
  final CitySearchRequest request;
  final List<CityData> data;

  CitySearchResponse({
    required this.status,
    required this.request,
    required this.data,
  });

  factory CitySearchResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List<dynamic>;
    return CitySearchResponse(
      status: json['status'] as bool,
      request: CitySearchRequest.fromJson(json['request'] as Map<String, dynamic>),
      data: dataList
          .map((item) => CityData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CitySearchRequest {
  final String path;
  final String keyword;

  CitySearchRequest({
    required this.path,
    required this.keyword,
  });

  factory CitySearchRequest.fromJson(Map<String, dynamic> json) {
    return CitySearchRequest(
      path: json['path'] as String,
      keyword: json['keyword'] as String,
    );
  }
}

class CityData {
  final String id;
  final String lokasi;

  CityData({
    required this.id,
    required this.lokasi,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      id: json['id'] as String,
      lokasi: json['lokasi'] as String,
    );
  }
}