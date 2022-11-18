import 'package:dip_project_frontend/screens/color_filter_screen.dart';
import 'package:dip_project_frontend/screens/select_photo_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<String> notifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: notifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Digital Image Processing',
          theme: ThemeData.dark(),
          routes: {
            SelectPhotoScreen.route: (context) => SelectPhotoScreen(notifier),
            ColorFilterScreen.route: (context) => ColorFilterScreen(notifier),
          },
          initialRoute: SelectPhotoScreen.route,
        );
      },
    );
  }
}
