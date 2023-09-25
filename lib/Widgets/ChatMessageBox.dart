import 'dart:developer';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:ucas_tools/Global.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:ucas_tools/Utils/markdown.dart';
import 'package:get/get.dart';

class ChatMessageBox extends StatefulWidget {
  ChatMessageBox({super.key, this.text, required this.sender});

  late String? text;
  final Role sender;

  @override
  State<ChatMessageBox> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessageBox> {
  MaterialColor secondColor = Colors.teal;
  late ThemeData secondTheme;
  String getSender(Role role) {
    switch (role) {
      case Role.user:
        return Get.find<SettingController>().username.value!;
      case Role.assistant:
        return "Assistant";
      case Role.system:
        return "System";
    }
  }

  @override
  void initState() {
    secondTheme = ThemeData(
      primarySwatch: secondColor,
      cardColor: secondColor.shade50,
      shadowColor: Colors.grey.withOpacity(0.5),
      // focusColor: const Color.fromARGB(215, 74, 122, 255),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: secondColor,
        backgroundColor: Colors.white,
        cardColor: secondColor.shade50,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 1,
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
    super.initState();
  }

  Icon getAvatar(Role role) {
    switch (role) {
      case Role.user:
        return const Icon(Icons.person);
      case Role.assistant:
        return const Icon(Icons.adb_outlined);
      case Role.system:
        return const Icon(Icons.computer_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.text ??= "";
    String sender = getSender(widget.sender);
    Icon avatar = getAvatar(widget.sender);
    ThemeData theme =
        widget.sender == Role.user ? Theme.of(context) : secondTheme;
    // log("$sender ${theme.primaryColor} ${Theme.of(context)} $secondTheme $theme");
    final Widget avatarContainer = Theme(
      data: theme,
      child: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 14.0),
        child: CircleAvatar(
          child: avatar,
        ),
      ),
    );
    final Expanded messageContainer = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sender, style: theme.textTheme.titleMedium),
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            width: MediaQuery.of(context).size.width - 72 - 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      spreadRadius: 0.5,
                      blurRadius: 3,
                      offset: const Offset(3, 3), // changes position of shadow
                    ),
                  ]),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: Markdown(text: widget.text!)),
            ),
          )
        ],
      ),
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatarContainer,
          messageContainer,
        ],
      ),
    );
  }
}
