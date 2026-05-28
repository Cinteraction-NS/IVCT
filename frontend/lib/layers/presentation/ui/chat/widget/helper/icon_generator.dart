import 'package:flutter/material.dart';

IconData getFileIcon(String filePath) {
  final ext = filePath.toLowerCase().split('.').last;

  switch (ext) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'txt':
    case 'csv':
    case 'json':
      return Icons.description;
    case 'doc':
    case 'docx':
      return Icons.article;
    case 'xls':
    case 'xlsx':
      return Icons.grid_on;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'zip':
    case 'rar':
    case '7z':
      return Icons.archive;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
    case 'tiff':
    case 'tif':
    case 'svg':
    case 'ico':
    case 'heic':
    case 'avif':
      return Icons.image;
    case 'mp4':
    case 'avi':
    case 'mov':
      return Icons.movie;
    case 'mp3':
    case 'wav':
      return Icons.music_note;
    default:
      return Icons.insert_drive_file;
  }
}
