import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_color/main_color.dart';

class ImagesAssets {
  static const List<String> Paths = [
    "images/1.jpg",
    "images/2.jpg",
    "images/3.jpg",
    "images/4.jpg",
    "images/5.jpg",
    "images/6.jpg",
  ];
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(child: ImagesLoader()),
    );
  }
}

class ImagesLoader extends StatefulWidget {
  @override
  _ImagesLoaderState createState() => _ImagesLoaderState();
}

class _ImagesLoaderState extends State<ImagesLoader> {
  Future<List<List<int>>> _imagesBytesFuture;

  @override
  void initState() {
    super.initState();
    _imagesBytesFuture = _loadAssetsBytes();
  }

  Future<List<List<int>>> _loadAssetsBytes() async {
    var bytesList = List<List<int>>();
    for (int i = 0; i < ImagesAssets.Paths.length; i++) {
      bytesList.add(await _loadAssetBytes(ImagesAssets.Paths[i]));
    }
    return bytesList;
  }

  Future<List<int>> _loadAssetBytes(String path) async {
    ByteData data = await rootBundle.load(path);
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _imagesBytesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Example(imagesBytes: snapshot.data);
        }
      },
    );
  }
}

class Example extends StatefulWidget {
  final List<List<int>> imagesBytes;

  const Example({Key key, this.imagesBytes}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  List<Color> _mainColors;
  double _saturationCoef = 1;
  double _valueCoef = 1;

  @override
  void initState() {
    super.initState();
    _mainColors = _getMainColors();
  }

  List<Color> _getMainColors() {
    var colors = List<Color>();
    for (int i = 0; i < widget.imagesBytes.length; i++) {
      colors.add(MainColor.fromImageBytes(
        widget.imagesBytes[i],
        staturationCoef: _saturationCoef,
        valueCoef: _valueCoef,
      ));
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: <Widget>[
          Slider(
            value: _saturationCoef,
            max: 2,
            min: 0,
            onChangeEnd: (double value) {
              setState(() {
                _saturationCoef = value;
                _mainColors = _getMainColors();
                print("new value = $_saturationCoef");
              });
            },
            onChanged: (double value) {},
          ),
          Slider(
            value: _valueCoef,
            max: 2,
            min: 0,
            onChangeEnd: (double value) {
              setState(() {
                _valueCoef = value;
                _mainColors = _getMainColors();
                print("new value = $_valueCoef");
              });
            },
            onChanged: (double value) {},
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: ImagesAssets.Paths.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(index, _mainColors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int index, List<Color> colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(child: Image.asset(ImagesAssets.Paths[index])),
          ),
          Expanded(
            child: Container(
              height: 200,
              color: colors[index],
            ),
          )
        ],
      ),
    );
  }
}
