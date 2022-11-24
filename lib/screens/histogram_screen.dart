import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistogramScreen extends StatelessWidget {
  static String route = "HistogramScreen";
  final ValueNotifier<String> imageNotifier;
  // final ValueNotifier<bool> isLoading;
  // final ValueNotifier<int> operationIndex;
  // ignore: prefer_const_constructors_in_immutables
  HistogramScreen(this.imageNotifier, {super.key});

  List<String> dropdownOperations = [
    'Show Histogram',
    'Histogram Equalization',
    'Histogram Quantization'
  ];

  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<int> operationIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowPhotoLayout(
          leftChilds(), rightChilds(context), 'Histogram Operations'),
    );
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
    // return Column(
    //   children: const [
    //     Expanded(
    //       child: Center(child: Text("Image")),
    //     ),
    //     Expanded(
    //       child: Center(child: Text("Histogram")),
    //     )
    //   ],
    // );
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
        ValueListenableBuilder(
          valueListenable: operationIndex,
          builder: (context, value, child) {
            return Expanded(
              child: operationIndex.value == 2
                  ? SizedBox(
                      width: 200,
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          label: Text("Tone Count"),
                          border: OutlineInputBorder(),
                        ),
                        // keyboardType: TextInputType.number,
                        autocorrect: false,
                        enableSuggestions: false,
                        inputFormatters: [
                          FilteringTextInputFormatter(
                            RegExp(r'[0-9]'),
                            allow: true,
                          ),
                        ],
                      ),
                    )
                  : Container(),
            );
          },
        ),
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
                            'http://localhost:5071/api/image/PreProcessing2',
                            data: {
                              'operationType': operationIndex.value,
                              // ignore: unnecessary_null_comparison
                              'toneCount': textController.text != null
                                  ? int.tryParse(textController.text)
                                  : 0
                            },
                          );
                          isLoading.value = false;
                          imageNotifier.value =
                              response.data["base64ModifiedImageData"];
                          print(response.data["histogram"]);
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text("Apply"),
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
                        //! dont navigate if did not applied any operations
                        await Dio().post(
                            'http://localhost:5071/api/image/NextPage',
                            data: {'base64ImageData': imageNotifier.value});
                        operationIndex.value = 0;
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(
                            context, HistogramScreen.route);
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
          ),
        ),
      ],
    );
  }
}
