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
  final ValueNotifier<String> fileTypeNotifier;
  SelectPhotoScreen(this.imageNotifier, this.fileTypeNotifier, {super.key});

  ValueNotifier<bool> canContinue = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          ShowPhotoLayout(ShowPhoto(), ShowRightPanel(context), 'Select Photo'),
    );
  }

  ShowPhoto() {
    return ValueListenableBuilder(
      valueListenable: canContinue,
      builder: ((context, value, child) {
        return Container(
          child: !canContinue.value
              ? const Center(
                  child: Text(
                    "Select an Image Please...",
                  ),
                )
              : Image.memory(base64Decode(imageNotifier.value)),
        );
      }),
    );
  }

  ShowRightPanel(context) {
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
                    extensions: <String>['jpg', 'jpeg', 'png', 'bmp'],
                  );
                  try {
                    final XFile? file = await openFile(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup]);

                    Uint8List? bytes = await file?.readAsBytes();
                    if (file != null) {
                      fileTypeNotifier.value = file.name.split(".").last;
                      print(fileTypeNotifier.value);
                    }
                    imageNotifier.value = base64Encode(bytes!);
                    canContinue.value = true;
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
              child: ValueListenableBuilder(
                valueListenable: canContinue,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      //! Send base64 string to Backend and store it on original image variable
                      if (canContinue.value) {
                        try {
                          var response = await Dio().post(
                            'http://localhost:5071/api/image',
                            data: {
                              'base64ImageData': imageNotifier.value,
                              'fileType': fileTypeNotifier.value
                            },
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacementNamed(
                              context, ColorFilterScreen.route);
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            canContinue.value ? Colors.green : Colors.red)),
                    child: const Text("Next"),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
