import 'package:flutter/material.dart';

abstract class PageUtils {
  static Widget buildRow(Widget page, String title) {
    return Builder(
      builder: (context) => ListTile(
        title: Text(title),
        onTap: () => Navigator.push<dynamic>(
            context, MaterialPageRoute<dynamic>(builder: (_) => page)),
      ),
    );
  }
}
