import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Utils/ChatModels/ChatGPT.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:get/get.dart';

class MessageRepository {
  static final MessageRepository _instance = MessageRepository._internal();

  factory MessageRepository() => _instance;

  MessageRepository._internal() {
    init();
  }

  void init() {
    OpenAI.apiKey = Get.find<SettingController>().openAiKey.value!;
    OpenAI.baseUrl = Get.find<SettingController>().openAiBaseUrl.value!;
  }

  void postMessage(
    String conversation_id,
    ValueChanged<Message> onResponse,
    ValueChanged<Message> errorCallback,
    ValueChanged<Message> onSuccess,
  ) async {
    final conversationDB = ConversationDB();
    final messages = await conversationDB.getMessagesByConversationUUid(
      conversation_id,
    );
    _getResponseFromLLM(messages, onResponse, errorCallback, onSuccess);
  }

  void _getResponseFromLLM(
    List<Message> messages,
    ValueChanged<Message> onResponse,
    ValueChanged<Message> errorCallback,
    ValueChanged<Message> onSuccess,
  ) async {
    ChatGPT().getResponse(
      messages,
      onResponse,
      errorCallback,
      onSuccess,
    );
  }
}
