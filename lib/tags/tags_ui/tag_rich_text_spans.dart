import 'package:expenses/tags/tag_model/tag.dart';
import 'package:flutter/material.dart';

RichText tagRichTextSpans({@required Tag tag, @required String search}) {
  String name = tag.name;
  if (search != null && search.length > 0 && name.toLowerCase().contains(search.toLowerCase())) {
    List<TextSpan> textSpans =[];
    while (name.length > 0) {
      int index = name.toLowerCase().indexOf(search.toLowerCase());
      if (index == 0) {
        String substring = name.substring(0, search.length).trim();
        textSpans.add(TextSpan(text: substring, style: TextStyle(color: Colors.blueAccent)));
        name = name.substring(search.length);
      } else if (index > 0) {
        String substring = name.substring(0, index).trim();
        textSpans.add(TextSpan(text: substring, style: TextStyle(color: Colors.black)));
        name = name.substring(index);
      } else {
        textSpans.add(TextSpan(text: name, style: TextStyle(color: Colors.black)));
        name = '';
      }
    }
    return RichText(text: TextSpan(children: textSpans));
  } else {
    return null;
  }
}
