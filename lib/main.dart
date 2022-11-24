import 'package:dip_project_frontend/screens/color_filter_screen.dart';
import 'package:dip_project_frontend/screens/filters_screen.dart';
import 'package:dip_project_frontend/screens/histogram_screen.dart';
import 'package:dip_project_frontend/screens/select_photo_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<String> imageNotifier = ValueNotifier("");
  final ValueNotifier<String> fileTypeNotifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: imageNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Digital Image Processing',
          theme: ThemeData.dark(),
          routes: {
            SelectPhotoScreen.route: (context) =>
                SelectPhotoScreen(imageNotifier, fileTypeNotifier),
            ColorFilterScreen.route: (context) =>
                ColorFilterScreen(imageNotifier),
            HistogramScreen.route: (context) => HistogramScreen(imageNotifier),
            FiltersScreen.route: (context) => FiltersScreen(imageNotifier),
          },
          initialRoute: SelectPhotoScreen.route,
        );
      },
    );
  }
}
