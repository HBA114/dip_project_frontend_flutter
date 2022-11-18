import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ColorFilterScreen extends StatefulWidget {
  static String route = "ColorFilterScreen";
  final ValueNotifier<String> notifier;
  const ColorFilterScreen(this.notifier, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<ColorFilterScreen> createState() => _ColorFilterScreenState(notifier);
}

class _ColorFilterScreenState extends State<ColorFilterScreen> {
  final ValueNotifier<String> notifier;
  _ColorFilterScreenState(this.notifier);

  List<String> dropdownOperations = ['Gray Scale', 'Black&White With Treshold'];
  String? selectedItem = 'Gray Scale';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Image.memory(base64Decode(notifier.value)),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: DropdownButton<String>(
                      value: selectedItem,
                      items: dropdownOperations
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (item) => setState(() => selectedItem = item),
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
                              'http://localhost:5071/api/image/PreProcessing1',
                              data: {'operationType': 0},
                            );

                            setState(() => notifier.value =
                                response.data["base64ModifiedImageData"]);
                            // ignore: use_build_context_synchronously
                            // Navigator.pushNamed(
                            //     context, ColorFilterScreen.route);
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
