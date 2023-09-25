import 'dart:async';
import 'dart:developer';

import 'package:ucas_tools/Global.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:ucas_tools/Utils/message_repository.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final messageList = <Message>[].obs;

  void loadAllMessages(String conversationId) async {
    log('loadAllMessages: conversationId=$conversationId');
    messageList.value = await Global.conversationDB
        .getMessagesByConversationUUid(conversationId);
  }

  void postMessage(Message message) async {
    await Global.conversationDB.addMessage(message);
    final messages = await Global.conversationDB
        .getMessagesByConversationUUid(message.conversationId);
    messageList.value = [...messages, Message(conversationId: message.conversationId, role: Role.assistant, text: "Loading...")];
    final completer = Completer();
    try {
      MessageRepository().postMessage(
        message.conversationId,
        (Message response) {
          messageList.value = [...messages, response];
        },
        (Message response) {
          messageList.value = [...messages, response];
        },
        (Message response) async {
          Global.conversationDB.addMessage(response);
          messageList.value = await Global.conversationDB
              .getMessagesByConversationUUid(message.conversationId);
          completer.complete();
        },
      );
    } catch (e) {
      messageList.value = [
        ...messages,
        Message(conversationId: message.conversationId, role: Role.system, text: e.toString())
      ];
      completer.complete();
    }
  }
}
