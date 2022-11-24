import 'package:dip_project_frontend/main.dart';
import 'package:dip_project_frontend/screens/select_photo_screen.dart';
import 'package:flutter/material.dart';

class ShowPhotoLayout extends StatefulWidget {
  Widget leftChilds, rightChilds;
  String pageTitle;
  ShowPhotoLayout(this.leftChilds, this.rightChilds, this.pageTitle,
      {super.key});

  @override
  State<ShowPhotoLayout> createState() =>
      _ShowPhotoLayoutState(leftChilds, rightChilds, pageTitle);
}

class _ShowPhotoLayoutState extends State<ShowPhotoLayout> {
  late Widget leftChilds, rightChilds;
  late String pageTitle;

  _ShowPhotoLayoutState(this.leftChilds, this.rightChilds, this.pageTitle);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.restart_alt_sharp),
            onPressed: () {
              Navigator.pushReplacementNamed(context, SelectPhotoScreen.route);
            }),
        title: Text(pageTitle),
        centerTitle: true,
      ),
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
