class HijriDateResponse {
  final bool status;
  final HijriRequest request;
  final HijriData data;

  HijriDateResponse({
    required this.status,
    required this.request,
    required this.data,
  });

  factory HijriDateResponse.fromJson(Map<String, dynamic> json) {
    return HijriDateResponse(
      status: json['status'] as bool,
      request: HijriRequest.fromJson(json['request'] as Map<String, dynamic>),
      data: HijriData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class HijriRequest {
  final String path;
  final String date;
  final int adj;

  HijriRequest({
    required this.path,
    required this.date,
    required this.adj,
  });

  factory HijriRequest.fromJson(Map<String, dynamic> json) {
    return HijriRequest(
      path: json['path'] as String,
      date: json['date'] as String,
      adj: json['adj'] as int,
    );
  }
}

class HijriData {
  final List<String> date;
  final List<int> num;

  HijriData({
    required this.date,
    required this.num,
  });

  factory HijriData.fromJson(Map<String, dynamic> json) {
    return HijriData(
      date: List<String>.from(json['date'] as List),
      num: List<int>.from(json['num'] as List),
    );
  }

  String get day => date[0]; // e.g., "Ahad"
  String get hijriDate => date[1]; // e.g., "16 Dzulhijjah 1445 H"
  String get gregorianDate => date[2]; // e.g., "23-06-2024"
}