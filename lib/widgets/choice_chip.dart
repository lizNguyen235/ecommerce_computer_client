import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/helper_function.dart';
import 'package:flutter/material.dart';

class TChoiceChip extends StatelessWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label:
          HelperFunction.getColor(text) != null ? const SizedBox() : Text(''),
      selected: selected,
      onSelected: onSelected,
      labelStyle: TextStyle(color: selected ? whiteColor : null),
      avatar:
          HelperFunction.getColor(text) != null
              ? CircleAvatar(
                backgroundColor: HelperFunction.getColor(text),
                child: Text(text, style: const TextStyle(color: whiteColor)),
              )
              : null,
      shape: CircleBorder(),
      labelPadding: EdgeInsets.all(0),
      selectedColor: Colors.green,
      backgroundColor: Colors.green,
    );
  }
}
