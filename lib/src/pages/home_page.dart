import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_basic/src/models/employee_model.dart';
import 'package:flutter_basic/src/models/item_model.dart';
import 'package:flutter_basic/src/models/payment_model.dart';
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
  var logText = '';

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
            Row(
              children: [
                ElevatedButton(
                  child: Text('Camera'),
                  onPressed: () {
                    _openCamera();
                  },
                ),
                ElevatedButton(
                  child: Text('Pagar'),
                  onPressed: () {
                    _openPayment();
                  },
                ),
              ],
            ),
            Container(
              child: SingleChildScrollView(child: Text(logText)),
              height: 100,
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
      logText += 'Iniciando _loadFromApi\n\n';
    });

    try {
      final apiProvider = EmployeeApiProvider();
      await apiProvider.getEmployees(currentPage, (log) {
        setState(() {
          logText += log + '\n\n';
        });
      });
    } catch (e) {
      setState(() {
        logText += "--> ERROR, exception: $e";
      });
    }

    setState(() {
      isLoading = false;
      logText += 'Finalizado _loadFromApi\n\n';
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

  _openPayment() async {
    try {
      await getInitialLink();
    } catch (e) {
      print("error");
    }

    setState(() {
      logText += 'Criando pagamento\n\n';
    });
    final payment = Payment(
        accessToken: 'JubsJAREppNep0lBKqatM3Sq2STALYOgYs2wNUkUEC0kd8YqgC',
        clientId: 'xhbLVNJN7DFPp95QS4JHqi8atKR9zfyezaavnvITvCU82bGW6E',
        email: 'ygorcruzfelix@gmail.com',
        installments: 0,
        merchantCode: null,
        paymentCode: 'CREDITO_AVISTA',
        items: [
          Item(
              id: '1111',
              name: 'COca cola lata',
              quantity: 1,
              unitOfMeasure: "unidade",
              unitPrice: 1)
        ],
        value: '1');

    final jsonPayment = json.encode(payment.toJson());
    print(jsonPayment);

    final paymentEncoded = base64.encode(utf8.encode(jsonPayment));
    final url =
        'lio://payment?request=$paymentEncoded&urlCallback=order://payment';

    setState(() {
      logText += 'Criado pagamento e verificando se pode abrir pagamento\n\n';
    });
    if (await canLaunch(url)) {
      setState(() {
        logText += 'Abrindo lio de pagamento\n\n';
      });
      await launch(url);
    } else {
      setState(() {
        logText += 'Nao pode abrir a lio de pagamento\n\n';
      });
    }
  }
}
