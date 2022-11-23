import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:dip_project_frontend/screens/color_filter_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class SelectPhotoScreen extends StatelessWidget {
  static String route = "SelectPhotoScreen";
  final ValueNotifier<String> imageNotifier;

  const SelectPhotoScreen(this.imageNotifier, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowPhotoLayout(
          ShowPhoto(imageNotifier), ShowRightPanel(imageNotifier, context)),
    );
  }

  ShowPhoto(imageNotifier) {
    return ValueListenableBuilder(
      valueListenable: imageNotifier,
      builder: ((context, value, child) {
        return Container(
          child: imageNotifier.value == ""
              ? const Text("Select an Image Please...")
              : Image.memory(base64Decode(imageNotifier.value)),
        );
      }),
    );
  }

  ShowRightPanel(imageNotifier, context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  const XTypeGroup typeGroup = XTypeGroup(
                    label: 'images',
                    extensions: <String>['jpg', 'jpeg', 'png'],
                  );
                  try {
                    final XFile? file = await openFile(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup]);

                    Uint8List? bytes = await file?.readAsBytes();

                    imageNotifier.value = base64Encode(bytes!);
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text("Select Image"),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  //! Send base64 string to Backend and store it on original image variable
                  try {
                    var response = await Dio().post(
                      'http://localhost:5071/api/image',
                      data: {'base64ImageData': imageNotifier.value},
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.pushNamed(context, ColorFilterScreen.route);
                  } catch (e) {
                    print(e);
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green)),
                child: const Text("Next"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
