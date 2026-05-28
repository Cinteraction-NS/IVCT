import 'dart:typed_data';
import 'dart:io' as io;

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:cinteraction_vc/core/extension/context.dart';

void openTextFile(BuildContext context, String fileUrl) async {
  try {
    final dio = Dio();
    final response = await dio.get(fileUrl);
    final uri = Uri.parse(fileUrl);
    final fileName = uri.pathSegments.last;

    if (response.statusCode == 200) {
      final fileContent = response.data.toString();

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: ColorConstants.kPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        color: ColorConstants.kPrimaryColor,
                        onPressed: () async {
                          Navigator.pop(context);
                          await downloadTextFile(context, fileUrl);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          fileContent,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      print("Error while opening file: ${response.statusCode}");
    }
  } catch (e) {
    print("Error opening file: $e");
  }
}

Future<void> downloadTextFile(BuildContext context, String fileUrl) async {
  try {
    Dio dio = Dio();
    Uri uri = Uri.parse(fileUrl);
    String fileName = uri.pathSegments.last;

    final response = await dio.get(
      fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      final Uint8List bytes = Uint8List.fromList(response.data);

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = fileName
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);

        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          context.showSnackBarMessage('Error while opening file');
        }
      }
    } else {
      throw Exception("Error while download: ${response.statusCode}");
    }
  } catch (e) {
    context.showSnackBarMessage("Error: $e", isError: true);
  }
}
