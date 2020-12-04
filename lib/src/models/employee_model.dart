import 'dart:convert';

List<Employee> employeesFromJson(String str) => List<Employee>.from(
    json.decode(str).map((employee) => Employee.fromJson(employee)));

String employeesToJson(List<Employee> data) =>
    json.encode(List<dynamic>.from(data.map((employee) => employee.toJson())));

class Employee {
  int id;
  String email;
  String firstName;
  String lastName;
  String avatar;

  Employee({this.id, this.email, this.firstName, this.lastName, this.avatar});

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        avatar: json['avatar'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'avatar': avatar,
      };
}
