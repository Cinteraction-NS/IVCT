enum FileType {
  pdf,
  text,
  image,
  word,
  excel,
  powerpoint,
  archive,
  video,
  audio,
  unknown,
}

FileType getFileType(String path) {
  final ext = path.toLowerCase().split('.').last;

  switch (ext) {
    case 'pdf':
      return FileType.pdf;
    case 'txt':
    case 'csv':
    case 'json':
      return FileType.text;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return FileType.image;
    case 'doc':
    case 'docx':
      return FileType.word;
    case 'xls':
    case 'xlsx':
      return FileType.excel;
    case 'ppt':
    case 'pptx':
      return FileType.powerpoint;
    case 'zip':
    case 'rar':
    case '7z':
      return FileType.archive;
    case 'mp4':
    case 'avi':
    case 'mov':
      return FileType.video;
    case 'mp3':
    case 'wav':
      return FileType.audio;
    default:
      return FileType.unknown;
  }
}
