// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  List<String> itemList;
  final ValueNotifier<int> operationIndex;
  CustomDropDown(this.itemList, this.operationIndex, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<CustomDropDown> createState() =>
      _CustomDropDownState(itemList, operationIndex);
}

class _CustomDropDownState extends State<CustomDropDown> {
  List<String> itemList;
  final ValueNotifier<int> operationIndex;
  _CustomDropDownState(this.itemList, this.operationIndex);

  String selectedItem = "";
  @override
  Widget build(BuildContext context) {
    if (selectedItem == "") {
      selectedItem = itemList[0];
      operationIndex.value = 0;
    }
    return DropdownButton<String>(
      value: selectedItem,
      items: itemList
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (item) => setState(() {
        selectedItem = item!;
        operationIndex.value = itemList.indexOf(selectedItem);
      }),
    );
  }
}
