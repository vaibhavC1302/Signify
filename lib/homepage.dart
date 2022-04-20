import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> status =
        await [Permission.storage].request();
    final info = status[Permission.storage].toString();
    print(info);
    _toastInfo(info);
  }

  _toastInfo(String info) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
  }

  void _handleClearButton() {
    signatureGlobalKey.currentState?.clear();
  }

  void _handleSaveButtonPressed() async {
    RenderSignaturePad boundary = signatureGlobalKey.currentContext!
        .findRenderObject() as RenderSignaturePad;
    ui.Image image = await boundary.toImage();
    final byteData = await (image.toByteData(format: ui.ImageByteFormat.png)
        as FutureOr<ByteData?>);
    if (byteData != null) {
      final time = DateTime.now().millisecond;
      final name = "signature_$time.png";
      final result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100,
          name: name);
      print(result);
      _toastInfo(result.toString());

      final isSuccess = result["isSuccess"];
      signatureGlobalKey.currentState?.clear();
      if (isSuccess) {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: Container(
              child: Image.memory(byteData.buffer.asUint8List()),
            )),
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.88,
            margin:
                const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 20),
            decoration: const BoxDecoration(
                boxShadow: [BoxShadow(offset: Offset(5, 5), blurRadius: 17)]),
            child: SfSignaturePad(
              key: signatureGlobalKey,
              backgroundColor: Colors.white,
              maximumStrokeWidth: 6,
              minimumStrokeWidth: 3,
              strokeColor: Colors.black,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.grey[800]),
                  onPressed: _handleSaveButtonPressed,
                  child: const Text("Save as Image"),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.grey[800]),
                    onPressed: _handleClearButton,
                    child: const Text("Clear"))
              ],
            ),
          )
        ],
      ),
    );
  }
}
