import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/layouts/show_photo_layout.dart';
import 'package:dip_project_frontend/screens/save_image_screen.dart';
import 'package:flutter/material.dart';

class MorphologicalsScreen extends StatelessWidget {
  static String route = "MorphologicalsScreen";
  final ValueNotifier<String> imageNotifier;

  MorphologicalsScreen(this.imageNotifier, {super.key});

  final List<String> dropdownOperations = [
    'Erosion',
    'Dilation',
    'Skeletonization'
  ];

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> operationIndex = ValueNotifier(0);
  final ValueNotifier<bool> canContinue = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ShowPhotoLayout(
        leftChildren(), rightChildren(context), 'Morphologicals');
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
                            'http://localhost:5071/api/image/Morphological',
                            data: {
                              'operationType': operationIndex.value,
                            },
                          );
                          isLoading.value = false;
                          canContinue.value = true;
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
                                    context, SaveImageScreen.route);
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
