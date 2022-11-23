import 'package:flutter/material.dart';

class ShowPhotoLayout extends StatefulWidget {
  Widget leftChilds, rightChilds;
  ShowPhotoLayout(this.leftChilds, this.rightChilds, {super.key});

  @override
  State<ShowPhotoLayout> createState() =>
      _ShowPhotoLayoutState(leftChilds, rightChilds);
}

class _ShowPhotoLayoutState extends State<ShowPhotoLayout> {
  late Widget leftChilds, rightChilds;

  _ShowPhotoLayoutState(this.leftChilds, this.rightChilds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: leftChilds,
          ),
          Expanded(
            child: rightChilds,
          ),
        ],
      ),
    );
  }
}
