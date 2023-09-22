import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:dip_project_frontend/screens/morphologicals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FiltersScreen extends StatelessWidget {
  static String route = "FiltersScreen";
  final ValueNotifier<String> imageNotifier;
  FiltersScreen(this.imageNotifier, {super.key});

  final List<String> dropdownOperations = [
    'Gaussian Blur Filter',
    'Sharpening Filter',
    'Edge Detect Filter',
    'Mean Filter',
    'Median Filter',
    'Contra Harmonical Filter'
  ];

  final List<String> filterSizes = ['3x3', '5x5', '9x9'];
  final List<int> filterSizeValues = [3, 5, 9];

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> operationIndex = ValueNotifier(0);
  final ValueNotifier<int> filterIndex = ValueNotifier(0);
  final ValueNotifier<bool> canContinue = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ShowPhotoLayout(leftChildren(), rightChildren(context), 'Filters');
  }

  leftChildren() {
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

  rightChildren(BuildContext context) {
    ValueNotifier<String> selectedItem = ValueNotifier(dropdownOperations[0]);
    ValueNotifier<String> selectedFilterSize = ValueNotifier(filterSizes[0]);
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
              child: operationIndex.value == 0
                  ? SizedBox(
                      width: 200,
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          label: Text("Standard Deviation"),
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
                  : operationIndex.value == 3 ||
                          operationIndex.value == 4 ||
                          operationIndex.value == 1
                      ? ValueListenableBuilder(
                          valueListenable: selectedFilterSize,
                          builder: ((context, value, child) {
                            return DropdownButton<String>(
                              value: selectedFilterSize.value,
                              items: filterSizes
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                              onChanged: ((item) {
                                selectedFilterSize.value = item!;
                                int index = filterSizes.indexOf(item);
                                if (index >= 0) filterIndex.value = index;
                              }),
                            );
                          }),
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
                            'http://localhost:5071/api/image/Filters',
                            data: {
                              'filterType': operationIndex.value,
                              // ignore: unnecessary_null_comparison
                              'filterSize': filterSizeValues[filterIndex.value],
                              'standardDeviation': textController.text != null
                                  ? int.tryParse(textController.text)
                                  : 0
                            },
                          );
                          isLoading.value = false;
                          canContinue.value = true;
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
                    child: ValueListenableBuilder(
                      valueListenable: canContinue,
                      builder: (context, value, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            //! Send base64 string to Backend and store it on original image variable
                            if (canContinue.value) {
                              try {
                                await Dio().post(
                                  'http://localhost:5071/api/image/NextPage',
                                  data: {
                                    'base64ImageData': imageNotifier.value
                                  },
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacementNamed(
                                    context, MorphologicalsScreen.route);
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  canContinue.value
                                      ? Colors.green
                                      : Colors.red)),
                          child: const Text("Next"),
                        );
                      },
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
