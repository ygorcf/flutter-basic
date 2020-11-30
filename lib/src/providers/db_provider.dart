import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_basic/src/models/employee_model.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDB();
    }

    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'employee_manager.db');

    return await openDatabase(path, version: 2, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Employee('
          'id INTEGER PRIMARY KEY,'
          'email TEXT,'
          'first_name TEXT,'
          'last_name TEXT,'
          'avatar TEXT'
          ')');
    });
  }

  createEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('Employee', {
      'id': employee.id,
      'email': employee.email,
      'first_name': employee.firstName,
      'last_name': employee.lastName,
      'avatar': employee.avatar,
    });
  }

  Future<int> deleteAllEmployees() async {
    final db = await database;
    return await db.rawDelete('DELETE FROM Employee');
  }

  Future<List<Employee>> listEmployees() async {
    final db = await database;
    final res = await db.rawQuery('SELECT * FROM Employee');

    return res.isNotEmpty
        ? res
            .map((employee) => Employee(
                  id: employee['id'],
                  email: employee['email'],
                  firstName: employee['first_name'],
                  lastName: employee['last_name'],
                  avatar: employee['avatar'],
                ))
            .toList()
        : [];
  }
}
