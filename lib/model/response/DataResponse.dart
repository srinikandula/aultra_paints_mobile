import '/model/User.dart';

class DataResponse {
  User user_info = User();


  DataResponse();
  DataResponse.fromMap(Map<String, dynamic> map) {
    if(map['user_info'] != null) {
      user_info = User.fromMap(map['user_info']);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'user_info': user_info
    };
  }
}
