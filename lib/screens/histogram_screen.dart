import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:dip_project_frontend/screens/filters_screen.dart';
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
  Map<int, int> histogramRed = {
    0: 0,
  };
  Map<int, int> histogramGreen = {
    0: 0,
  };
  Map<int, int> histogramBlue = {
    0: 0,
  };
  // final Map<String, int> someMap = {
  //   "a": 1,
  //   "b": 2,
  // };

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
                builder: (context, value, child) => Column(children: [
                  Expanded(
                    child: Image.memory(
                      base64Decode(imageNotifier.value),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 256,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(index.toString()),
                          trailing: Row(
                            children: [
                              Column(
                                children: [
                                  const Text("Red"),
                                  Text(histogramRed[index] == null
                                      ? "0"
                                      : histogramRed[index].toString()),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Green"),
                                  Text(histogramGreen[index] == null
                                      ? "0"
                                      : histogramGreen[index].toString()),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Blue"),
                                  Text(histogramBlue[index] == null
                                      ? "0"
                                      : histogramBlue[index].toString()),
                                ],
                              ),
                            ],
                          ),
                          // trailing: Text(histogram[index] == null
                          //     ? "0"
                          //     : histogram[index].toString()), //!!
                        );
                      },
                    ),
                  ),
                ]),
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
                          // print(response.data["histogram"]);
                          // print(response.data["histogram"]["0"]);
                          // print(response.data["histogram"].length);
                          for (int i = 0; i < 256; i++) {
                            if (response.data["histogramRed"][i.toString()] !=
                                null) {
                              histogramRed[i] =
                                  response.data["histogramRed"][i.toString()];
                            } else {
                              histogramRed[i] = 0;
                            }

                            if (response.data["histogramGreen"][i.toString()] !=
                                null) {
                              histogramGreen[i] =
                                  response.data["histogramGreen"][i.toString()];
                            } else {
                              histogramGreen[i] = 0;
                            }

                            if (response.data["histogramBlue"][i.toString()] !=
                                null) {
                              histogramBlue[i] =
                                  response.data["histogramBlue"][i.toString()];
                            } else {
                              histogramBlue[i] = 0;
                            }
                          }

                          // print(histogram);
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
                            context, FiltersScreen.route);
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
