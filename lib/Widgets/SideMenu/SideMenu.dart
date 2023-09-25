import 'package:flutter/material.dart';
import 'package:ucas_tools/Global.dart';
import 'package:ucas_tools/Controllers/SideMenuController.dart';

class SideMenu extends StatefulWidget {
  SideMenu({super.key, required this.children, required this.controller});
  late List<Widget> children;
  late SideMenuController controller;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Global.sideMenuController = widget.controller;
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: Global.sideMenuController.height,
        // color: Colors.amber,
        // decoration: BoxDecoration(
        //   color: theme.cardColor,
        //   boxShadow: [BoxShadow(blurRadius: 5, color: theme.shadowColor)],
        // ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.children),
      ),
    );
  }
}
