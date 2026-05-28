import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class ImageAsset extends AssetImage {
  static const String base = 'lib/assets/images/';
  final String assetImageName;
  const ImageAsset(this.assetImageName) : super(base + assetImageName);
}

SvgPicture? imageSVGAsset(String assetImageName) {
  const String base = 'lib/assets/images/svg/';

  return SvgPicture.asset(
    '$base$assetImageName.svg'
  );
}

