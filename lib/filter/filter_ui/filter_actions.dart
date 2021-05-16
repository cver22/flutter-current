import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<Widget> filterActions({required dynamic Function(void) onPressedClear}) {
  return [
    TextButton(
      child: Text('Clear'),
      onPressed: () => onPressedClear,
    ),
    TextButton(
        child: Text('Done'),
        onPressed: () {
          Get.back();
        }),
  ];
}