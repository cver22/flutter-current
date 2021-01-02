import 'package:expenses/env.dart';
import 'package:expenses/qr_reader/qr_model/qr_model.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QRReader extends StatefulWidget {
  final List<CameraDescription> cameras;

  const QRReader({Key key, @required this.cameras}) : super(key: key);

  @override
  _QRReaderState createState() => _QRReaderState();
}

class _QRReaderState extends State<QRReader> {
  QRReaderController controller;

  void initState() {
    super.initState();
    controller = QRReaderController(widget.cameras[0], ResolutionPreset.medium, [CodeFormat.qr], (dynamic value) {
      print(value); // the result!
      if (value != null && !value.isBlank && value.toString().contains(APP) && value.toString().contains(EXPENSE_APP)) {
        QRModel newLogMember = QRModel.fromJson(value);
        Env.store.dispatch(AddMemberToSelectedLog(uid: newLogMember.uid, name: newLogMember.uid));
        Get.back();
      }
      Future.delayed(const Duration(seconds: 3), controller.startScanning);
    });
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startScanning();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(aspectRatio: controller.value.aspectRatio, child: QRReaderPreview(controller));
  }
}
