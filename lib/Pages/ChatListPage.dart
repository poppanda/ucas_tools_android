import 'package:flutter/material.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:ucas_tools/Controllers/ConversationController.dart';
import 'package:ucas_tools/Widgets/SideMenu/ChatButton.dart';
import 'package:get/get.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({super.key});
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GetX<ConversationController>(
            builder: (controller){
              List<Conversation> conversations = controller.conversationList;
              return ListView.builder(
              itemBuilder: (context, index) {
                return ChatButton(
                  title: conversations[index].name,
                  uuid: conversations[index].uuid,
                );
              },
              itemCount: conversations.length,
            );
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ConversationController().createConversation();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
