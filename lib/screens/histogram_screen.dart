import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:flutter/material.dart';

class HistogramScreen extends StatelessWidget {
  static String route = "HistogramScreen";
  final ValueNotifier<String> imageNotifier;
  // ignore: prefer_const_constructors_in_immutables
  HistogramScreen(this.imageNotifier, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowPhotoLayout(leftChilds(), rightChilds()),
    );
  }

  leftChilds() {
    return Column(
      children: const [
        Expanded(
          child: Center(child: Text("Image")),
        ),
        Expanded(
          child: Center(child: Text("Histogram")),
        )
      ],
    );
  }

  rightChilds() {
    return Container();
  }
}
