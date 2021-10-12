import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

void main() => runApp(MyApp());

class BlendData {
  BlendMode? mode;
  Color? color;
  BlendData(BlendMode mode, Color color) {
    this.mode = mode;
    this.color = color;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Picture'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // BlendDataの作成
  final Map blendDataMap = {
    "Strong": BlendData(
      BlendMode.saturation,
      Color(0xFF00FFFF),
    ),
    "Sepia": BlendData(
      BlendMode.modulate,
      Color(0xFFffdead),
    ),
    "Sunset": BlendData(
      BlendMode.colorBurn,
      Color(0xFFf0e68c),
    ),
    "MagicHour": BlendData(
      BlendMode.colorBurn,
      Color(0xFFba55d3),
    ),
    "Ocean": BlendData(
      BlendMode.colorBurn,
      Color(0xFF00FFFF),
    ),
  };

  File? _image;
  BlendMode? _mode;
  Color? _color;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    List<Widget> widgets = [];

    // メインの画像
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

    // 色調変更ボタン
    widgets.add(
      _image == null
          ? Container(
        height: 90,
      )
          : Container(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: createChangeBlendButtons(),
        ),
      ),
    );


    // Utilityボタン
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            onPressed: (){getImage(ImageSource.gallery);},
            tooltip: "画像を変更する",
            child: Icon(Icons.attach_file),
          ),
          FloatingActionButton(
            onPressed: (){getImage(ImageSource.camera);},
            tooltip: "撮影",
            child: Icon(Icons.camera),
          ),
          FloatingActionButton(
            onPressed: trimmingImage,
            tooltip: "トリミング",
            child: Icon(Icons.picture_in_picture),
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

  Future getImage(ImageSource imageSource) async {
    var image = await ImagePicker().pickImage(source: imageSource);

    setState(
          () {
        _image = image! as File;
      },
    );
  }

  Future trimmingImage() async {
    if (_image == null) {
      return;
    }

    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    setState(() {
      _image=croppedFile;
    });
  }

  List<Widget> createChangeBlendButtons() {
    List<Widget> widgets = [];

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
                child: Text(
                  "1.Normal Button",
                ),
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.black,
                    width: 50,
                  ),
                ),
              ),
          ),        );
      },
    );
    return widgets;
  }

  void selectedBlend(String value) {
    setState(
          () {
        BlendData blendData = blendDataMap[value];
        _mode = blendData.mode;
        _color = blendData.color;
      },
    );
  }
}