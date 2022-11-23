import 'package:dip_project_frontend/screens/color_filter_screen.dart';
import 'package:dip_project_frontend/screens/histograms_screen.dart';
import 'package:dip_project_frontend/screens/select_photo_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<String> imageNotifier = ValueNotifier("");
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> operationIndex = ValueNotifier(0);

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
                SelectPhotoScreen(imageNotifier),
            ColorFilterScreen.route: (context) =>
                ColorFilterScreen(imageNotifier, isLoading, operationIndex),
            HistogramsScreen.route: (context) => HistogramsScreen(),
          },
          initialRoute: SelectPhotoScreen.route,
        );
      },
    );
  }
}
