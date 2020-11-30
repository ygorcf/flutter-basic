import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImagePage extends StatelessWidget {
  final String imagePath;

  const ImagePage({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Image.file(File(imagePath)));
  }
}
