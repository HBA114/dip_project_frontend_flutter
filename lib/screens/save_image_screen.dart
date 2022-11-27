import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SaveImageScreen extends StatelessWidget {
  static String route = "SaveImageScreen";
  final ValueNotifier<String> imageNotifier;
  SaveImageScreen(this.imageNotifier, {super.key});

  List<String> dropdownOperations = ['jpeg', 'jpg', 'png'];

  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<int> operationIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return ShowPhotoLayout(leftChilds(), rightChilds(context), 'Save Image');
  }

  leftChilds() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: ((context, value, child) {
        return isLoading.value //! not works for now
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: imageNotifier,
                builder: (context, value, child) =>
                    Image.memory(base64Decode(imageNotifier.value)),
              );
      }),
    );
  }

  rightChilds(BuildContext context) {
    ValueNotifier<String> selectedItem = ValueNotifier(dropdownOperations[0]);
    TextEditingController textController = TextEditingController();
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: selectedItem,
              builder: ((context, value, child) {
                return DropdownButton<String>(
                  value: selectedItem.value,
                  items: dropdownOperations
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: ((item) {
                    selectedItem.value = item!;
                    int index = dropdownOperations.indexOf(item);
                    if (index >= 0) operationIndex.value = index;
                  }),
                );
              }),
            ),
          ),
        ),
        // ValueListenableBuilder(
        //   valueListenable: operationIndex,
        //   builder: (context, value, child) {
        //     return Expanded(
        //       child: operationIndex.value == -1
        //           ? SizedBox(
        //               width: 200,
        //               child: TextField(
        //                 controller: textController,
        //                 decoration: const InputDecoration(
        //                   label: Text("Tone Count"),
        //                   border: OutlineInputBorder(),
        //                 ),
        //                 // keyboardType: TextInputType.number,
        //                 autocorrect: false,
        //                 enableSuggestions: false,
        //                 inputFormatters: [
        //                   FilteringTextInputFormatter(
        //                     RegExp(r'[0-9]'),
        //                     allow: true,
        //                   ),
        //                 ],
        //               ),
        //             )
        //           : Container(),
        //     );
        //   },
        // ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        //! Send base64 string to Backend and store it on original image variable
                        try {
                          isLoading.value = true;
                          var response = await Dio().post(
                            'http://localhost:5071/api/image/SaveFile',
                            data: {
                              'base64ImageData': imageNotifier.value,
                              'fileType':
                                  dropdownOperations[operationIndex.value]
                            },
                          );
                          isLoading.value = false;
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text("Save Image"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
