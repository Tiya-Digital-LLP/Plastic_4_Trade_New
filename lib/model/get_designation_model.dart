class GetDesignationModel {
  final int status;
  final String message;
  final List<Designation> designation;

  GetDesignationModel({
    required this.status,
    required this.message,
    required this.designation,
  });

  factory GetDesignationModel.fromJson(Map<String, dynamic> json) {
    var designationList = json['designation'] as List;
    List<Designation> coreItems =
        designationList.map((i) => Designation.fromJson(i)).toList();

    return GetDesignationModel(
      status: json['status'],
      message: json['message'],
      designation: coreItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'designation': designation.map((core) => core.toJson()).toList(),
    };
  }
}

class Designation {
  final int id;
  final String name;

  Designation({
    required this.id,
    required this.name,
  });

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
