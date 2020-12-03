import 'package:dio/dio.dart';

import 'package:flutter_basic/src/models/employee_model.dart';
import 'package:flutter_basic/src/providers/db_provider.dart';

class EmployeeApiProvider {
  Future<List<Employee>> getEmployees(int page, Function logFn) async {
    final url = 'https://randomuser.me/api/?results=20&page=$page';
    logFn('Enviando $url request');
    Response res = await Dio().get(url);
    logFn('resposta da $url request recebida');

    return (res.data['results'] as List).map((user) {
      logFn('Salvando ${user['name']['first']}');

      DBProvider.db.createEmployee(Employee.fromJson({
        'email': user['email'],
        'firstName': user['name']['first'],
        'lastName': user['name']['last'],
        'avatar': user['picture']['medium'],
      }));
    }).toList();
  }
}
