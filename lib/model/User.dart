
class User {
  int attendeeId = 0;
  String name = "";
  String password = "";
  String purpose = "";
  String param = "";
  String contactUs = "";
  // List<Profile> profile_data;

  User();
  User.fromMap(Map<String, dynamic> data) {
    attendeeId = data['attendee_id'];
    name = data['name'];
    password = data['password'];
    purpose = data['purpose'];
    param = data['param'];
    contactUs = data['contact_us'];

    // var profileJson = data['profile_data'] as List;
    // profile_data = profileJson.map((tagJson) => Profile.fromMap(tagJson)).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'attendee_id': attendeeId,
      'name': name,
      'password': password,
      'purpose': purpose,
      'param': param,
      'contact_us': contactUs,
      // 'profile_data': profile_data,
    };
  }
}
