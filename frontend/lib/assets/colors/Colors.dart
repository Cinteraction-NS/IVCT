import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorConstants {
  static const kPrimaryColor = Color(0xFFF1471C);
  static const kSecondaryColor = Color(0xFF403736);

  static const kStateColors = [ kEngProgress30];

  // static const kStateInfo = Color(0xFF56A0D6);
  static const kStateInfo = Color(0xFF24408B);
  static const kStateSuccess = Color(0xFF1CBC96);
  static const kStateWarning = Color(0xFFEFBA32);
  static const kStateError = Color(0xFFDA2E2E);

  static const kBlack1 = Color(0xFF000000);
  static const kBlack2 = Color(0xFF1D1D1D);
  static const kBlack3 = Color(0xFF222222);

  static const kWhite = Color(0xFFFFFFFF);
  static const kWhite30 = Color(0x4DFFFFFF);

  static const kGray1 = Color(0xFF333333);
  static const kGray2 = Color(0xFF4F4F4F);
  static const kGray3 = Color(0xFF828282);
  static const kGray4 = Color(0xFFBDBDBD);
  static const kGray5 = Color(0xFFE0E0E0);
  static const kGray600 = Color(0xFF475466);



  static const kGrey100 = Color(0xFFF6F6F8);

  static const kEngProgress65 = Color(0xFFA9A31A);
  static const kEngProgress30 = Color(0xFFF1691C);
  static const kWhite40 = Color(0xFFF8F8F8);

  static const kWhite50 = Color(0xFFF1F1F1);



  static final List<MaterialColor> _filteredColors = Colors.primaries.where((color) {
    // Exclude pinks and light colors
    return color != Colors.pink &&
        color != Colors.pinkAccent &&
        color != Colors.redAccent &&
        color != Colors.deepOrangeAccent &&
        color != Colors.purpleAccent &&
        color != Colors.purple &&
        color != Colors.yellowAccent &&
        color != Colors.yellow &&
        color != Colors.black &&
        color != Colors.black54 &&
        color != Colors.black87 &&
        color != Colors.black38 &&
        color != Colors.black45 &&
        color != Colors.black26 &&
        color != Colors.brown &&
        color != Colors.cyanAccent &&
        color != Colors.white &&
        color != Colors.greenAccent &&
        color != Colors.orange &&
        color != Colors.orangeAccent &&
        color != Colors.limeAccent

    ;
  }).toList();

  static Color getRandomColor(int id, {int shade = 200}) {
    // final hash = "${id * 256}".codeUnits.fold(0, (prev, elem) => prev * 31 + elem);
    // final r = 127 + (hash >> 16) % 120;
    // final g = 127 + (hash >> 8) % 120;
    // final b = 127 + hash % 120;
    // return Color.fromARGB(255, r, g, b);

    final index = id % _filteredColors.length;
    final color = _filteredColors[index];



    // Choose a darker shade (like 700) to avoid light colors
    return color[shade] ?? color;


  }


  static Color getShadedColor(int id,
      {double amount = 0.2, bool lighten = true}) {
    Color color = getRandomColor(id);

    assert(amount >= 0 && amount <= 1);

    int adjust(int channel) {
      return lighten
          ? (channel + ((255 - channel) * amount)).round()
          : (channel * (1 - amount)).round();
    }

    return Color.fromARGB(
      (color.a * 255).toInt(),
      adjust((color.r * 255).toInt()),
      adjust((color.g * 255).toInt()),
      adjust((color.b * 255).toInt()),
    );
  }





  static Color graphColorFor(int key) {
    const palette = [
      Color(0xFF1e88e5), // blue
      Color(0xFFe53935), // red
      Color(0xFF43a047), // green
      Color(0xFF8e24aa), // purple
      Color(0xFFfb8c00), // orange
      Color(0xFF00acc1), // cyan
      Color(0xFF6d4c41), // brown
      Color(0xFF7cb342), // light green
      Color(0xFF3949ab), // indigo
      Color(0xFFf4511e), // deep orange
    ];
    return palette[key.hashCode.abs() % palette.length];
  }
}
