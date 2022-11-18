import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/screens/color_filter_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class SelectPhotoScreen extends StatefulWidget {
  static String route = "SelectPhotoScreen";
  final ValueNotifier<String> notifier;

  const SelectPhotoScreen(this.notifier, {super.key});

  @override
  State<SelectPhotoScreen> createState() => _SelectPhotoScreenState(notifier);
}

class _SelectPhotoScreenState extends State<SelectPhotoScreen> {
  String _base64Image = "";
  final ValueNotifier<String> notifier;

  _SelectPhotoScreenState(this.notifier);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: notifier.value == ""
                  ? const Text("Select an Image Please...")
                  : Image.memory(base64Decode(notifier.value)),
            ),
          ),
          Expanded(
            child: Column(
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

                          final XFile? file = await openFile(
                              acceptedTypeGroups: <XTypeGroup>[typeGroup]);

                          Uint8List? bytes = await file?.readAsBytes();

                          setState(() {
                            _base64Image = base64Encode(bytes!);
                            notifier.value = base64Encode(bytes);
                          });
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
                              data: {'base64ImageData': notifier.value},
                            );

                            // ignore: use_build_context_synchronously
                            Navigator.pushNamed(
                                context, ColorFilterScreen.route);
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text("Next"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
