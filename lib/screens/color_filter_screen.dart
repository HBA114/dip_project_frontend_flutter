import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dip_project_frontend/widgets/dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class ColorFilterScreen extends StatelessWidget {
//   static String route = "ColorFilterScreen";
//   final ValueNotifier<String> imageNotifier;
//   final ValueNotifier<bool> isLoading;
//   final ValueNotifier<int> operationIndex;
//   ColorFilterScreen(this.imageNotifier, this.isLoading, this.operationIndex,
//       {super.key});

//   List<String> dropdownOperations = ['Gray Scale', 'Black&White With Treshold'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: <Widget>[
//           Expanded(
//             child: Center(
//               child: isLoading.value //! not works for now, state not changes
//                   ? const CircularProgressIndicator()
//                   : Image.memory(base64Decode(imageNotifier.value)),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: <Widget>[
//                 Expanded(
//                   child: Center(
//                     child: CustomDropDown(dropdownOperations, operationIndex),
//                   ),
//                 ),
//                 operationIndex.value == 1 ? const Text("data") : Container(),
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Center(
//                           child: SizedBox(
//                             height: 50,
//                             width: 200,
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 //! Send base64 string to Backend and store it on original image variable
//                                 try {
//                                   isLoading.value = true;
//                                   var response = await Dio().post(
//                                     'http://localhost:5071/api/image/PreProcessing1',
//                                     data: {
//                                       'operationType': operationIndex.value
//                                     },
//                                   );
//                                   isLoading.value = false;
//                                   imageNotifier.value =
//                                       response.data["base64ModifiedImageData"];
//                                 } catch (e) {
//                                   print(e);
//                                 }
//                               },
//                               child: const Text("Apply"),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: SizedBox(
//                             height: 50,
//                             width: 200,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 // Navigator.pushNamed(context, routeName);
//                               },
//                               style: ButtonStyle(
//                                   backgroundColor:
//                                       MaterialStateProperty.all<Color>(
//                                           Colors.green)),
//                               child: const Text("Next"),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ColorFilterScreen extends StatefulWidget {
  static String route = "ColorFilterScreen";
  final ValueNotifier<String> imageNotifier;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<int> operationIndex;
  ColorFilterScreen(this.imageNotifier, this.isLoading, this.operationIndex,
      {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<ColorFilterScreen> createState() =>
      _ColorFilterScreenState(imageNotifier, isLoading, operationIndex);
}

class _ColorFilterScreenState extends State<ColorFilterScreen> {
  final ValueNotifier<String> imageNotifier;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<int> operationIndex;
  _ColorFilterScreenState(
      this.imageNotifier, this.isLoading, this.operationIndex);

  List<String> dropdownOperations = ['Gray Scale', 'Black&White With Treshold'];
  String? selectedItem = '';
  int tresholdValue = 0;
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedItem == '') {
      selectedItem = dropdownOperations[0];
    }
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: isLoading.value //! not works for now
                  ? const CircularProgressIndicator()
                  : Image.memory(base64Decode(imageNotifier.value)),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
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
                      onChanged: (item) => setState(() {
                        selectedItem = item!;
                        operationIndex.value =
                            dropdownOperations.indexOf(selectedItem!);
                      }),
                    ),
                  ),
                ),
                Expanded(
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
                                  setState(() {
                                    isLoading.value = true;
                                  });
                                  var operationType =
                                      dropdownOperations.firstWhere(
                                          (element) => element == selectedItem);
                                  print("Operation Type");
                                  print(operationType);
                                  print(selectedItem);
                                  var response = await Dio().post(
                                    'http://localhost:5071/api/image/PreProcessing1',
                                    data: {
                                      'operationType': operationIndex.value,
                                      'tresholdValue':
                                          int.parse(textController.text)
                                    },
                                  );
                                  setState(() {
                                    isLoading.value = false;
                                  });
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
                                // Navigator.pushNamed(context, routeName);
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green)),
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
          ),
        ],
      ),
    );
  }
}
