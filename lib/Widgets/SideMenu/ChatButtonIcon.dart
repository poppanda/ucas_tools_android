import 'dart:ffi';

import 'package:flutter/material.dart';

class ChatIcon extends StatefulWidget {
  final IconData icon;
  final IconData? hoverIcon;
  final double? iconSize;
  final VoidCallback? onPressed;
  final Color? color, hoverColor;
  const ChatIcon({
    super.key,
    required this.icon,
    this.hoverIcon,
    this.onPressed,
    this.iconSize,
    this.color,
    this.hoverColor,
  });

  @override
  State<ChatIcon> createState() => _ChatIconState();
}

class _ChatIconState extends State<ChatIcon> {
  bool _isHover = false;

  Icon selectIcon(BuildContext context) {
    if (_isHover) {
      return Icon(
        widget.hoverIcon ?? widget.icon,
        color: widget.hoverColor ?? Theme.of(context).focusColor,
        size: widget.iconSize,
      );
    } else {
      return Icon(
        widget.icon,
        color: widget.color ?? Theme.of(context).primaryColor,
        size: widget.iconSize,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEvent event) {
        setState(() {
          _isHover = true;
        });
      },
      onExit: (PointerEvent event) {
        setState(() {
          _isHover = false;
        });
      },
      child: InkWell(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: widget.onPressed,
        child: selectIcon(context),
      ),
    );
  }
}
