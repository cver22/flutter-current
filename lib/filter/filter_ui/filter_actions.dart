import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<Widget> filterActions({required Function() onPressedClear}) {
  return [
    TextButton(
      child: Text('Clear'),
      onPressed: onPressedClear,
    ),
    TextButton(
        child: Text('Done'),
        onPressed: () {
          Get.back();
        }),
  ];
}