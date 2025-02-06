import 'package:flutter/material.dart';


final Color DEFAULT_BLACK = Color.fromRGBO(19, 19, 19, 1);
final Color DEFAULT_WHITE = Color.fromRGBO(220, 220, 220, 1);
final Color DEFAULT_ORANGE = Color.fromRGBO(255,153,0, 1);
final Color DEFAULT_GREY = Color.fromRGBO(100, 100, 100, 1);
final Color DEFAULT_RED = Colors.red;


AppBar getDefaultAppBar(context) {
  return AppBar(
    toolbarHeight: 55,
    foregroundColor: DEFAULT_WHITE,
    backgroundColor: DEFAULT_BLACK,
    leading: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },

      icon: Icon(Icons.arrow_back_ios),
    ),

  );
}

