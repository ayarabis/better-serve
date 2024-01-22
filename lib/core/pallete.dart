import 'package:flutter/material.dart';

class Pallete {
  static MaterialColor createSwatch(Color c) {
    return MaterialColor(c.value, {
      50: Color.fromRGBO(c.red, c.green, c.blue, .1),
      100: Color.fromRGBO(c.red, c.green, c.blue, .2),
      200: Color.fromRGBO(c.red, c.green, c.blue, .3),
      300: Color.fromRGBO(c.red, c.green, c.blue, .4),
      400: Color.fromRGBO(c.red, c.green, c.blue, .5),
      500: Color.fromRGBO(c.red, c.green, c.blue, .6),
      600: Color.fromRGBO(c.red, c.green, c.blue, .7),
      700: Color.fromRGBO(c.red, c.green, c.blue, .8),
      800: Color.fromRGBO(c.red, c.green, c.blue, .9),
      900: Color.fromRGBO(c.red, c.green, c.blue, 1),
    });
  }

  static Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
