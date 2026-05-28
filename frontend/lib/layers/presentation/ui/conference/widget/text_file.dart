import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';

void openLocalFile(BuildContext context, PlatformFile file) async {
  try {
    Uint8List? fileBytes = file.bytes;
    if (fileBytes == null) {
      return;
    }

    if (_isPdfFile(file)) {
      _openPdfInNewTab(fileBytes);
    } else {
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      if (_isImageFile(file)) {
        _showFileDialog(context, file.name, url, isImage: true);
      } else if (_isTextFile(file)) {
        final reader = html.FileReader();
        reader.readAsText(blob);
        reader.onLoadEnd.listen((_) {
          final fileContent = reader.result as String;
          _showFileDialog(context, file.name, fileContent, isImage: false);
        });
      } else {
        _showFileDialog(context, file.name, "File opened: ${file.name}",
            isImage: false);
      }
    }
  } catch (e) {
    print("Error opening local file: $e");
  }
}

void _openPdfInNewTab(Uint8List fileBytes) {
  final blob = html.Blob([fileBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.window.open(url, '_blank');
  html.Url.revokeObjectUrl(url);
}

bool _isImageFile(PlatformFile file) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  return imageExtensions.any((ext) => file.name.toLowerCase().endsWith(ext));
}

bool _isTextFile(PlatformFile file) {
  final textExtensions = ['txt', 'json', 'xml', 'csv'];
  return textExtensions.any((ext) => file.name.toLowerCase().endsWith(ext));
}

bool _isPdfFile(PlatformFile file) {
  return file.name.toLowerCase().endsWith('.pdf');
}

void _showFileDialog(BuildContext context, String fileName, String content,
    {required bool isImage}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow
                  .ellipsis, // Prevents long names from breaking layout
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(Icons.download, color: Colors.blue),
            onPressed: () {
              _downloadFile(fileName, content, isImage);
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: isImage ? Image.network(content) : Text(content),
      ),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

void _downloadFile(String fileName, String content, bool isImage) {
  final blob = html.Blob([content], isImage ? 'image/*' : 'text/plain');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();

  html.Url.revokeObjectUrl(url);
}
