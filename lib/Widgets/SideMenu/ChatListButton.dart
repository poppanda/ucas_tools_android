import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/ConversationController.dart';
import 'package:ucas_tools/Widgets/SideMenu/ChatButton.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:get/get.dart';

class ChatListButton extends StatefulWidget {
  ChatListButton({super.key, required this.title, required this.new_page});

  final String title;
  final Function new_page;
  List<Widget> buttons = [];

  @override
  State<ChatListButton> createState() => _ChatListButtonState();
}

class _ChatListButtonState extends State<ChatListButton> {
  bool shrinked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GetX<ConversationController>(
        builder: (controller) {
          List<Conversation> conversations = controller.conversationList;
          return SizedBox(
            width: 180,
            child: ListView.builder(
              itemBuilder: (context, index) => ChatButton(
                title: conversations[index].name,
                uuid: conversations[index].uuid,
              ),
              itemCount: conversations.length,
            ),
            // child: ExpansionTile(
            //   controller: Global.sideMenuController.expansionTileController,
            //   controlAffinity: ListTileControlAffinity.leading,
            //   title: parentButton,
            //   children: List.generate(
            //     conversations.length,
            //     (index) => ChatButton(
            //       title: conversations[index].name,
            //       uuid: conversations[index].uuid,
            //     ),
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
