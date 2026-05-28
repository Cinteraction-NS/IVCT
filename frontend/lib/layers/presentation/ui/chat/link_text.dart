import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';

class LinkText extends StatelessWidget {
  final String text;

  LinkText(this.text);

  Iterable<RegExpMatch> getLinkMatches() {
    final RegExp linkRegExp = RegExp(
      r'((https?:\/\/)?((www\.)?[\w\-]+(\.[\w\-]+)+\.?(:\d+)?(\/\S*)?))',
      caseSensitive: false,
    );

    return linkRegExp.allMatches(text);
  }

  Map<String, String> getFileNameAndExtension(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    String fileNameWithExtension = path.split('/').last;
    String fileName = fileNameWithExtension
        .split('%2F')
        .last
        .replaceAll('%20', ' '); // Decode URL-encoded space

    int lastDotIndex = fileName.lastIndexOf('.');
    String fileExtension =
        lastDotIndex != -1 ? fileName.substring(lastDotIndex + 1) : '';

    return {
      'fileName': fileName,
      'extension': fileExtension,
    };
  }

  @override
  Widget build(BuildContext context) {
    final matches = getLinkMatches();
    if (matches.isNotEmpty) {
      final List<Widget> spans = [];
      final match = matches.first;

      final url = text.substring(match.start, match.end);
      final fullUrl = url.startsWith('http') ? url : 'https://$url';
      final fileData = getFileNameAndExtension(fullUrl);
      print(fileData);

      return GestureDetector(
        onTap: () async {
          print("Container clicked");
          if (await canLaunchUrl(Uri.parse(fullUrl))) {
            await launchUrl(Uri.parse(fullUrl));
          } else {
            throw 'Could not launch $fullUrl';
          }
          // Add your code here
        },
        child: ["png", "jpg", "jpeg"].contains(fileData['extension'])
            ? SizedBox(
                width: 300, // Set your desired width
                height: 200, // Set your desired height
                child: Image.network(
                  fullUrl, // Replace with your image URL
                  fit: BoxFit.cover,
                  // Options: BoxFit.cover, BoxFit.contain, BoxFit.fill, etc.
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Image is loaded
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Container(
                      width: 150,
                      height: 100,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Image(
                            image: ImageAsset('pdf_file.png'),
                          ),
                          Text(
                            "${fileData['fileName']}",
                            style: context.primaryTextTheme.bodySmall
                                ?.copyWith(color: ColorConstants.kGray600),
                            softWrap: true,
                          )
                        ],
                      ),
                    ); // Handle error loading image
                  },
                ),
              )
            : Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // const Image(
                    //   image: ImageAsset('pdf_file.png'),
                    // ),
                    Text(
                      fullUrl,
                      style: context.primaryTextTheme.bodySmall
                          ?.copyWith(color: ColorConstants.kGray600),
                      softWrap: true,
                    )
                  ],
                ),
              ),
      );
    } else {
      return Text(
        text,
        style: context.primaryTextTheme.bodySmall
            ?.copyWith(color: ColorConstants.kGray600),
        softWrap: true,
      );
    }
  }

  TextSpan _buildTextSpan(BuildContext context, String text) {
    print("_buildTextSpan");
    final RegExp linkRegExp = RegExp(
      r'((https?:\/\/)?((www\.)?[\w\-]+(\.[\w\-]+)+\.?(:\d+)?(\/\S*)?))',
      caseSensitive: false,
    );

    final matches = linkRegExp.allMatches(text);
    final List<TextSpan> spans = [];
    int start = 0;

    for (var match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final url = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              print("on tap url");
              final fullUrl = url.startsWith('http') ? url : 'https://$url';

              print("on tap url $fullUrl");
              if (await canLaunchUrl(Uri.parse(fullUrl))) {
                await launchUrl(Uri.parse(fullUrl));
              } else {
                throw 'Could not launch $fullUrl';
              }
            },
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return TextSpan(
      style: context.primaryTextTheme.bodySmall
          ?.copyWith(color: ColorConstants.kGray600),
      children: spans,
    );
  }
}
