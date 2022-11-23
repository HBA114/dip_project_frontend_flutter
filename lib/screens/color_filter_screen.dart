import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:dip_project_frontend/screens/histogram_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorFilterScreen extends StatelessWidget {
  static String route = "ColorFilterScreen";
  final ValueNotifier<String> imageNotifier;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<int> operationIndex;
  ColorFilterScreen(this.imageNotifier, this.isLoading, this.operationIndex,
      {super.key});

  List<String> dropdownOperations = [
    'Select An Option',
    'Gray Scale',
    'Black&White With Treshold'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowPhotoLayout(
          LeftChilds(imageNotifier, isLoading),
          RightChilds(
              imageNotifier, operationIndex, dropdownOperations, context)),
    );
  }

  LeftChilds(imageNotifier, isLoading) {
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

  RightChilds(
      ValueNotifier<String> imageNotifier,
      ValueNotifier<int> operationIndex,
      List<String> dropdownOperations,
      BuildContext context) {
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
                    int index = dropdownOperations.indexOf(item) - 1;
                    if (index > 0) operationIndex.value = index;
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
              child: operationIndex.value == 1
                  ? SizedBox(
                      width: 200,
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          label: Text("Treshold Value"),
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
                            'http://localhost:5071/api/image/PreProcessing1',
                            data: {
                              'operationType': operationIndex.value,
                              // ignore: unnecessary_null_comparison
                              'tresholdValue': textController.text != null
                                  ? int.tryParse(textController.text)
                                  : 0
                            },
                          );
                          isLoading.value = false;
                          imageNotifier.value =
                              response.data["base64ModifiedImageData"];
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
                      onPressed: () {
                        //! dont navigate if did not applied any operations
                        Navigator.pushNamed(context, HistogramScreen.route);
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
