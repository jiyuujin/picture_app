import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class BlendData {
  BlendData(this.mode, this.color);
  BlendMode? mode;
  Color? color;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Picture'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: strict_raw_type
  final Map blendDataMap = {
    'Strong': BlendData(
      BlendMode.saturation,
      const Color(0xFF00FFFF),
    ),
    'Sepia': BlendData(
      BlendMode.modulate,
      const Color(0xFFffdead),
    ),
    'Sunset': BlendData(
      BlendMode.colorBurn,
      const Color(0xFFf0e68c),
    ),
    'MagicHour': BlendData(
      BlendMode.colorBurn,
      const Color(0xFFba55d3),
    ),
    'Ocean': BlendData(
      BlendMode.colorBurn,
      const Color(0xFF00FFFF),
    ),
  };

  File? _image;
  BlendMode? _mode;
  Color? _color;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widgets = <Widget>[];

    // ignore: cascade_invocations
    widgets.add(
      SizedBox(
        height: size.width,
        width: size.width,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: _image == null
              ? Container()
              : Image.file(
                  _image!,
                  color: _color,
                  colorBlendMode: _mode,
                ),
        ),
      ),
    );

    // ignore: cascade_invocations
    widgets.add(
      _image == null
          ? Container(
              height: 90,
            )
          : SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: createChangeBlendButtons(),
              ),
            ),
    );

    // ignore: cascade_invocations
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              getImage(ImageSource.gallery);
            },
            tooltip: '画像を変更する',
            child: const Icon(Icons.attach_file),
          ),
          FloatingActionButton(
            onPressed: () {
              getImage(ImageSource.camera);
            },
            tooltip: '撮影',
            child: const Icon(Icons.camera),
          ),
          FloatingActionButton(
            onPressed: trimmingImage,
            tooltip: 'トリミング',
            child: const Icon(Icons.picture_in_picture),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: widgets,
      ),
    );
  }

  Future<dynamic> getImage(ImageSource imageSource) async {
    final image = await ImagePicker().pickImage(source: imageSource);

    setState(
      () {
        _image = image! as File;
      },
    );
  }

  Future<dynamic> trimmingImage() async {
    if (_image == null) {
      return;
    }

    final croppedFile = await ImageCropper.cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1,
        ));

    setState(() {
      _image = croppedFile;
    });
  }

  List<Widget> createChangeBlendButtons() {
    final widgets = <Widget>[];

    blendDataMap.forEach(
      (key, value) {
        widgets.add(
          SizedBox(
            height: 50,
            width: 50,
            child: ElevatedButton(
              onPressed: () {
                selectedBlend(key);
              },
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.black,
                  width: 50,
                ),
              ),
              child: const Text(
                '1.Normal Button',
              ),
            ),
          ),
        );
      },
    );
    return widgets;
  }

  void selectedBlend(String value) {
    setState(
      () {
        final BlendData blendData = blendDataMap[value];
        _mode = blendData.mode;
        _color = blendData.color;
      },
    );
  }
}
