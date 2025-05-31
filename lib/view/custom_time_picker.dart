import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomTimePicker extends StatefulWidget {
  final TextEditingController controller;

  const CustomTimePicker({Key? key, required this.controller})
      : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = DateTime.now().hour;
    _minute = DateTime.now().minute;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Example height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPickerNumberSelector('Hour', 0, 23, (value) => _hour = value),
          SizedBox(height: 20),
          _buildPickerNumberSelector(
              'Minute', 0, 59, (value) => _minute = value),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.controller.text =
                  '$_hour:${_minute.toString().padLeft(2, '0')}';
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerNumberSelector(
      String label, int min, int max, void Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        CupertinoPicker(
          itemExtent: 32,
          looping: true,
          onSelectedItemChanged: (index) {
            onChanged(index + min);
          },
          children: List.generate(
              max - min + 1, (index) => Text((index + min).toString())),
        ),
      ],
    );
  }
}
