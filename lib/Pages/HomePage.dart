import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/ConversationController.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:ucas_tools/Global.dart';
import 'package:get/get.dart';
import 'package:ucas_tools/Pages/ChatPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 1,
      childAspectRatio: 2.5,
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red.shade400),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onPressed: () {
              Global.sideMenuController.pressedMenuButton =
                  Global.sideMenuController.translateButton;
            },
            child: const Text(
              "Translate text with GPT-3.5",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(15),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue.shade400),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onPressed: () {
              setState(() {
                ConversationController().createConversation().then(
                  (uuid) {
                    Get.find<ConversationController>()
                        .setCurrentConversationUUid(uuid);
                    Global.sideMenuController.pressedMenuButton =
                        Global.sideMenuController.chatListButton;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ChatPage()));
                  },
                );
              });
            },
            child: const Text(
              "Start a new chat with GPT-3.5",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
            ),
          ),
          // color: Colors.red,
        ),
        Container(
          margin: const EdgeInsets.all(15),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Colors.purpleAccent.shade400),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onPressed: () {
              setState(() {
                Get.find<SettingController>().setCalendarView("day");
                Global.sideMenuController.pressedMenuButton =
                    Global.sideMenuController.calendarButton;
              });
            },
            child: const Text(
              "Watch todays' courses",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
            ),
          ),
          // color: Colors.red,
        ),
        Container(
          color: Colors.yellow,
        ),
        Container(
          color: Colors.orange,
        ),
        Container(
          color: Colors.purple,
        ),
      ],
    );
  }
}
