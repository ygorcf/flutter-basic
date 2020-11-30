import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_basic/src/models/employee_model.dart';
import 'package:flutter_basic/src/pages/camera_page.dart';
import 'package:flutter_basic/src/providers/db_provider.dart';
import 'package:flutter_basic/src/providers/employee_api_provider.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  var isLoading = false;
  var currentPage = 1;
  ScrollController controller;
  CameraController cameraController;
  Future<void> cameraFuture;

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()
      ..addListener(() {
        if (controller.position.extentAfter < 20 && !isLoading) {
          _loadFromApi();
        }
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      cameraFuture = cameraController?.initialize() ?? null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
          actions: [
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.settings_input_antenna),
                onPressed: () {
                  _loadFromApi();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _deleteData();
                },
              ),
            )
          ],
        ),
        body: Column(
          children: [
            ElevatedButton(
              child: Text('Camera'),
              onPressed: () {
                _openCamera();
              },
            ),
            Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _buildEmployeeListView()),
          ],
        ));
  }

  _loadFromApi() async {
    setState(() {
      isLoading = true;
    });

    final apiProvider = EmployeeApiProvider();
    await apiProvider.getEmployees(currentPage);

    setState(() {
      isLoading = false;
      currentPage++;
    });
  }

  _deleteData() async {
    setState(() {
      isLoading = true;
    });

    await DBProvider.db.deleteAllEmployees();

    setState(() {
      isLoading = false;
      currentPage = 1;
    });
  }

  _buildEmployeeListView() {
    return FutureBuilder(
        future: DBProvider.db.listEmployees(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Não há dados.'));
          } else {
            return ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Colors.black12,
                    ),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final employee = snapshot.data[index] as Employee;

                  return ListTile(
                    leading: Image.network(employee.avatar),
                    title: Text(
                        "Name: ${employee.firstName} ${employee.lastName}"),
                    subtitle: Text(employee.email),
                  );
                },
                controller: controller);
          }
        });
  }

  _openCamera() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CameraPage()));
  }
}
