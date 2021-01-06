import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  //TODO have chips change colour when selected?

  const TagChip({Key key, this.name, this.onPressed, this.onEdit, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    GlobalKey key = GlobalKey(debugLabel: name);
    return InputChip(
      label: Text('#$name'),
      key: key,
      onPressed: onPressed,
      onDeleted: () {
        RenderBox box = key.currentContext.findRenderObject();
        Offset position = box.localToGlobal(Offset.zero);

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),

          items: <PopupMenuEntry<String>>[EditDeleteTag()],
        ).then<void>((String command) {
          if (command == 'edit') {
            onEdit();
          } else if (command == 'delete') {
            onDelete();
          }
          return;
        });
      },
      deleteIcon: Icon(Icons.more_vert_outlined),
    );
  }
}


class EditDeleteTag extends PopupMenuEntry<String> {
  @override
  double height = 10;
  // height doesn't matter, as long as we are not giving
  // initialValue to showMenu().

  @override
  EditDeleteTagState createState() => EditDeleteTagState();

  @override
  bool represents(String command) {
    return command == 'edit' || command == 'delete';
  }
}

class EditDeleteTagState extends State<EditDeleteTag> {
  void _edit() {
    // This is how you close the popup menu and return user selection.
    Navigator.pop<String>(context, 'edit');
  }

  void _delete() {
    Navigator.pop<String>(context, 'delete');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: _edit, child: Text('Edit')),
        FlatButton(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, onPressed: _delete, child: Text('Delete')),
      ],
    );
  }
}
