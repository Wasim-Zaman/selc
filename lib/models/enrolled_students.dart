class EnrolledStudent {
  final String id;
  final String name;
  final String email;
  final String fatherName;
  final String level;
  final String contactNumber;
  final String fatherContactNumber;
  final String address;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime enrollmentDate;

  EnrolledStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.fatherName,
    required this.level,
    required this.contactNumber,
    required this.fatherContactNumber,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.enrollmentDate,
  });

  factory EnrolledStudent.fromMap(Map<String, dynamic> data, String id) {
    return EnrolledStudent(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      fatherName: data['father_name'] ?? '',
      level: data['level'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      fatherContactNumber: data['father_contact_number'] ?? '',
      address: data['address'] ?? '',
      dateOfBirth: _parseDate(data['date_of_birth']),
      gender: data['gender'] ?? '',
      enrollmentDate: data['enrollmentDate'] is DateTime
          ? data['enrollmentDate'] as DateTime
          : DateTime.parse(data['enrollmentDate'] as String),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'father_name': fatherName,
      'level': level,
      'contact_number': contactNumber,
      'father_contact_number': fatherContactNumber,
      'address': address,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'enrollmentDate': enrollmentDate.toIso8601String(),
    };
  }
}
