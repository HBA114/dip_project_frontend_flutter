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
  const SelectPhotoScreen(this.imageNotifier, this.fileTypeNotifier,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          ShowPhotoLayout(ShowPhoto(), ShowRightPanel(context), 'Select Photo'),
    );
  }

  ShowPhoto() {
    return ValueListenableBuilder(
      valueListenable: imageNotifier,
      builder: ((context, value, child) {
        return Container(
          child: imageNotifier.value == ""
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
                      data: {
                        'base64ImageData': imageNotifier.value,
                        'fileType': fileTypeNotifier.value
                      },
                    );

                    // var response = await Dio().post(
                    //   'http://127.0.0.1:8000/',
                    //   data: {
                    //     'base64Image': imageNotifier.value,
                    //     'base64ModifiedImage': imageNotifier.value
                    //   },
                    // );
                    // print(response);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacementNamed(
                        context, ColorFilterScreen.route);
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
