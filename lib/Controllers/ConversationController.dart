import 'dart:developer';

import 'package:ucas_tools/Global.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:get/get.dart';

class ConversationController extends GetxController {
  final conversationList = <Conversation>[].obs;
  final currentConversationUUid = "".obs;
  static ConversationController get to => Get.find();
  @override
  void onInit() async {
    conversationList.value = await Global.conversationDB.getConversations();
    print("Conversations get");
    super.onInit();
  }

  void setCurrentConversationUUid(String uuid) async {
    currentConversationUUid.value = uuid;
    // update();
  }

  void deleteConversation(String uuid) async {
    await Global.conversationDB.deleteConversation(uuid);
    conversationList.value = await Global.conversationDB.getConversations();
    // update();
  }

  Future<String> createConversation()async{
    Conversation newConversation =
        Conversation(name: "New Chat", uuid: Global.uuid.v4());
    ConversationController controller = Get.find();
    controller.addConversation(newConversation);
    conversationList.value = await Global.conversationDB.getConversations();
    log("ConversationController: created a conver");
    return newConversation.uuid;
  }

  void addConversation(Conversation conversation) async {
    await Global.conversationDB.addConversation(conversation);
    conversationList.value = await Global.conversationDB.getConversations();
    update();
  }

  void updateConversation(Conversation conversation) async {
    await Global.conversationDB.updateConversation(conversation);
    conversationList.value = await Global.conversationDB.getConversations();
    update();
  }
}
