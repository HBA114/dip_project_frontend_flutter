import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class SelectPhotoScreen extends StatefulWidget {
  static String route = "SelectPhotoScreen";
  const SelectPhotoScreen({super.key});

  @override
  State<SelectPhotoScreen> createState() => _SelectPhotoScreenState();
}

class _SelectPhotoScreenState extends State<SelectPhotoScreen> {
  String _base64Image = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: _base64Image == ""
                  ? const Text("Select an Image Please...")
                  : Image.memory(base64Decode(_base64Image)),
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
                        onPressed: () {
                          //! Send base64 string to Backend and store it on original image variable
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
