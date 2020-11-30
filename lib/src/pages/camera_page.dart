import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_basic/src/pages/Image_page.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  CameraDescription _currentCamera;
  Future<CameraDescription> get currentCamera async {
    if (_currentCamera == null) {
      WidgetsFlutterBinding.ensureInitialized();

      final cameras = await availableCameras();

      _currentCamera = cameras.first;
    }

    return _currentCamera;
  }

  @override
  State<StatefulWidget> createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {
  CameraController cameraController;
  Future<void> cameraFuture;

  @override
  void initState() {
    super.initState();

    cameraFuture = _initCamera();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: cameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(cameraController);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await cameraFuture;
            final path = join((await getTemporaryDirectory()).path,
                'img-${DateTime.now()}.png');
            await cameraController?.takePicture(path);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ImagePage(
                          imagePath: path,
                        )));
          } catch (e) {
            print(e);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _initCamera() async {
    cameraController =
        CameraController(await widget.currentCamera, ResolutionPreset.high);

    await cameraController.initialize();
  }
}
