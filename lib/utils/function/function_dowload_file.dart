import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<void> downloadFile(BuildContext context, String url, String filename) async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isGranted == false) {
      final result = await Permission.manageExternalStorage.request();
      if (!result.isGranted) {
        CustomToast.show(context, 'El usuario no otorgó permisos de almacenamiento', type: 'e');
        return;
      }
    }
  }
  final dir = Directory('/storage/emulated/0/Download');
  final savePath = '${dir.path}/$filename';
  try {
    final dio = Dio();
    await dio.download(url, savePath);
    final file = File(savePath);
    if (await file.exists()) {
      CustomToast.show(context, 'Archivo descargado exitosamente');
    } else {
      CustomToast.show(context, 'El archivo no se guardó', type: 'e');
    }
  } catch (e) {
    CustomToast.show(context, 'Error al descargar archivo', type: 'e');
  }
}
