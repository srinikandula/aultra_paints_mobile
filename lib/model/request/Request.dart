class Request {
  String param = "";

  Request();
  Request.fromMap(Map<String, dynamic> data) {
    param = data['param'];
  }

  Map<String, dynamic> toMap() {
    return {
      'param': param,
    };
  }
}
