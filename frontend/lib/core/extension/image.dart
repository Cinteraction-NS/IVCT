import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

extension SVGExtension on SvgPicture {
  SvgPicture copyWith(
      {double? width,
      double? height,
      BoxFit? fit,
      Clip? clipBehavior,
      ColorFilter? colorFilter}) {
    return SvgPicture(
      bytesLoader,
      width: width ?? this.width,
      height: height ?? this.height,
      fit: fit ?? this.fit,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      colorFilter: colorFilter ?? this.colorFilter,
    );
  }
}
