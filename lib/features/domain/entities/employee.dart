class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String employeeCode;
  final double netPay;
  final String profileImage;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.employeeCode,
    required this.netPay,
    this.profileImage = '',
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      department: json['department'] as String? ?? '',
      employeeCode: json['employee_code'] as String? ?? '',
      netPay: json['net_pay'] is int
          ? (json['net_pay'] as int).toDouble()
          : (json['net_pay'] as double? ?? 0.0),
      profileImage: json['profile_image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'employee_code': employeeCode,
      'net_pay': netPay,
      'profile_image': profileImage,
    };
  }
}
