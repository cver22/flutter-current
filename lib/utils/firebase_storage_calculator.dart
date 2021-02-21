import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStorageCalculator {
  final List<DocumentSnapshot> documents;

  FirebaseStorageCalculator({this.documents});

  getDocumentSize() {
    documents.forEach((element) {
      int docSize = calcFirestoreDocSize(element.documentID, element.data);

      print('document: ${element.documentID} is $docSize bytes of data');
    });
  }

  calcFirestoreDocSize(docId, docObject) {
    int docNameSize = 1 + 16;
    if (docId is String) {
      docNameSize += encodedLength(docId) + 1;
    } else {
      docNameSize += 8;
    }
    int docSize = docNameSize + calcObjSize(docObject);

    return docSize;
  }

  encodedLength(String str) {
    var len = str.length;
    for (int i = str.length - 1; i >= 0; i--) {
      var code = str.codeUnitAt(i);
      if (code > 0x7f && code <= 0x7ff) {
        len++;
      } else if (code > 0x7ff && code <= 0xffff) {
        len += 2;
      }
      if (code >= 0xDC00 && code <= 0xDFFF) {
        i--;
      }
    }
    return len;
  }

  calcObjSize(obj) {
    int size = 0;

    if (obj == null) {
      return 1;
    } else if (obj is double) {
      return 8;
    } else if (obj is String) {
      return encodedLength(obj) + 1;
    } else if (obj is bool) {
      return 1;
    } else if (obj is List) {
      for (int i = 0; i < obj.length; i++) {
        size += calcObjSize(obj[i]);
      }
      return size;
    } else if (obj is Map) {
      obj.forEach((key, value) {
        size += encodedLength(key) + 1;
        size += calcObjSize(obj[key]);
      });
    }
    return size += 32;
  }
}
