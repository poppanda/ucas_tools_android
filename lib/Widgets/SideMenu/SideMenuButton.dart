import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ucas_tools/Global.dart';

class SideMenuButtonInterface {
  Widget? page;
  int? buttonLevel;
  late String title;
}

class SideMenuButton extends StatefulWidget implements SideMenuButtonInterface {
  SideMenuButton(
      {super.key, required this.icon, required this.title, this.page, this.buttonLevel, this.isOn});
  late Icon icon;
  late String title;
  late Widget? page;
  late int? buttonLevel;
  bool? isOn;
  

  @override
  State<SideMenuButton> createState() => _SideMenuButtonState();
}

class _SideMenuButtonState extends State<SideMenuButton> {
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    if (widget.isOn != null) {
      isOn = widget.isOn!;
    }
    if (widget == Global.sideMenuController.pressedMenuButton) {
      isOn = true;
    }
    Global.sideMenuController.addListener(() {
      if (!mounted) return; 
      setState(() {
        isOn = Global.sideMenuController.pressedMenuButton == widget;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.buttonLevel ??= 0;
    if (widget.buttonLevel! > 0) {
    } else {
    }
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: isOn
              ? MaterialStateProperty.all<Color>(Theme.of(context).hoverColor)
              : MaterialStateProperty.all<Color>(Colors.transparent),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          // overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          surfaceTintColor:
              MaterialStateProperty.all<Color>(Colors.transparent),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: () {
          Global.sideMenuController.pressedMenuButton = widget;
        },
        child: widget.icon
      ),
    );
  }
}
