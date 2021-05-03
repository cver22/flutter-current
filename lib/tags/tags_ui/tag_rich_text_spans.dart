import 'package:flutter/material.dart';

import '../../utils/maybe.dart';
import '../tag_model/tag.dart';

RichText? tagRichTextSpans({required Tag tag, required Maybe<String> search}) {
  String? name = tag.name;
  if (search.isSome &&
      search.value.length > 0 &&
      name!.toLowerCase().contains(search.value.toLowerCase())) {
    List<TextSpan> textSpans = [];
    textSpans.add(TextSpan(text: '#', style: TextStyle(color: Colors.black)));
    while (name!.length > 0) {
      int index = name.toLowerCase().indexOf(search.value.toLowerCase());
      if (index == 0) {
        String substring = name.substring(0, search.value.length).trim();
        textSpans.add(TextSpan(
            text: substring, style: TextStyle(color: Colors.blueAccent)));
        name = name.substring(search.value.length);
      } else if (index > 0) {
        String substring = name.substring(0, index).trim();
        textSpans.add(
            TextSpan(text: substring, style: TextStyle(color: Colors.black)));
        name = name.substring(index);
      } else {
        textSpans
            .add(TextSpan(text: name, style: TextStyle(color: Colors.black)));
        name = '';
      }
    }
    return RichText(text: TextSpan(children: textSpans));
  } else {
    return null;
  }
}
