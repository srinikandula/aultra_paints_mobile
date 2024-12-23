class IncidentRequest {
  String email = "";
  String name = "";

  String phoneNumber = "";
  String incidentType = "";
  String natureOfOccurence = "";
  String damageType = "";
  String locationName = "";
  String siteType = "";
  String region = "";
  String service = "";
  late List<String> propertyDamage = [];

  String employerOfInjuredPerson = "";
  String nameOfInjuredPerson = "";
  String gender = "";
  String age = "";
  String injuredBodyPart = "";
  String injuredDetailsDescription = "";
  DateTime dateOfIncident = DateTime.now();
  String timeOfIncident = "";
  String incidentDescription = "";
  String incidentDocs = "";
  String incidentPriority = "";
  int incidentPriorityValue = 0;
  String imagesList = "";
  String incidentDateTime = '';

  int teamId = 0;
  int leadId = 0;
  int deptId = 0;
  String topic_id = '0';

  String incidentFlowCount = "";
  String incidentValue = "";

  String vehicleDamageType = "";
  String fireType = "";

//body parts
//images
  IncidentRequest();
  IncidentRequest.fromMap(Map<String, dynamic> data) {
    print('@@@@@@@@@@@#########====>$data');
    email = data['email'];
    name = data['name'];

    phoneNumber = data['phoneNumber'];
    incidentType = data['incidentType'];
    natureOfOccurence = data['natureOfOccurence'];
    damageType = data['damageType'];
    locationName = data['locationName'];
    siteType = data['siteType'];
    region = data['region'];
    service = data['service'];
    propertyDamage = data['propertyDamage'];

    vehicleDamageType = data['vehicleDamageType'];
    fireType = data['fireType'];

    employerOfInjuredPerson = data['employerOfInjuredPerson'];
    nameOfInjuredPerson = data['nameOfInjuredPerson'];
    gender = data['gender'];
    age = data['age'];
    injuredBodyPart = data['injuredBodyPart'];
    injuredDetailsDescription = data['injuredDetailsDescription'];
    dateOfIncident = data['dateOfIncident'];
    timeOfIncident = data['timeOfIncident'];
    incidentDescription = data['incidentDescription'];
    incidentDocs = data['incidentDocs'];
    incidentPriority = data['incidentPriority'];
    incidentPriority = data['incidentPriorityValue'];
    imagesList = data['imagesList'];
    teamId = data['teamId'];
    leadId = data['leadId'];
    deptId = data['deptId'];
    topic_id = data['topic_id'];
    incidentDateTime = data['incidentDateTime'];
  }

  // get imagesList => null;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phoneNumber,
      'incidentType': incidentType,
      'natureOfOccurence': natureOfOccurence,
      'damageType': damageType,
      'locationName': locationName,
      'siteType': siteType,
      'region': region,
      'service': service,
      'propertyDamage': propertyDamage,
      'employerOfInjuredPerson': employerOfInjuredPerson,
      'nameOfInjuredPerson': nameOfInjuredPerson,
      'gender': gender,
      'age': age,
      'injuredBodyPart': injuredBodyPart,
      'injuredDetailsDescription': injuredDetailsDescription,
      'dateOfIncident': dateOfIncident,
      'timeOfIncident': timeOfIncident,
      'incidentDescription': incidentDescription,
      'incidentDocs': incidentDocs,
      'incidentPriority': incidentPriority, //priority name
      'priorityId': incidentPriorityValue, //priority value
      'imagesList': imagesList,
      'teamId': teamId,
      'leadId': leadId,
      'deptId': deptId,
      'topic_id': topic_id,
      'incidentDateTime': incidentDateTime,
    };
  }
}
