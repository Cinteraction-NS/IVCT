import 'dart:io' show File;
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;

Future<void> downloadPdfFile(BuildContext context, String fileUrl) async {
  final fileName = fileUrl.split('/').last;
  try {
    if (kIsWeb) {
      Response response = await Dio().get(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final blob = html.Blob([response.data], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        throw Exception("Error while downloading PDF: ${response.statusCode}");
      }
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      Response response = await Dio().get(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.data);
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          context.showSnackBarMessage('There is error while opening file');
        }
      } else {
        throw Exception("Error while downloading PDF: ${response.statusCode}");
      }
    }
  } catch (e) {
    context.showSnackBarMessage('There is error: $e');
  }
}

void showPdfDialog(BuildContext context, String pdfUrl) async {
  try {
    if (kIsWeb) {
      Response response = await Dio().get(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final blob = html.Blob([response.data], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      }
    } else {
      await downloadPdfFile(context, pdfUrl);
    }
  } catch (e) {
    print("Error downloading PDF: $e");
  }
}
