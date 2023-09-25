import 'dart:math';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Utils/ChatModels/LLM.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:vibration/vibration.dart';

class ChatGPT extends LLM {
  @override
  getResponse(
    List<Message> messages,
    ValueChanged<Message> onResponse,
    ValueChanged<Message> errorCallback,
    ValueChanged<Message> onSuccess,
  ) {
    List<OpenAIChatCompletionChoiceMessageModel> openAIMessages = [];
    messages.forEach((message) {
      openAIMessages.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: message.role.asOpenAIChatMessageRole,
          content: message.text,
        ),
      );
    });
    var stream = OpenAI.instance.chat.createStream(
      messages: openAIMessages,
      model: 'gpt-3.5-turbo',
    );

    Message response = Message(
      conversationId: messages.first.conversationId,
      text: "",
      role: Role.assistant,
    );

    stream.listen(
      (event) async {
        if (event.choices.first.delta.content != null) {
          response.text += event.choices.first.delta.content!;
          var hasVibration = await Vibration.hasVibrator();
          if (hasVibration != null && hasVibration) {
            Vibration.vibrate(duration: 50, amplitude: 50);
          }
          onResponse(response);
        }
      },
      onError: (error) {
        response.text = error.message;
        errorCallback(response);
      },
      onDone: () {
        onSuccess(response);
      },
    );
  }
}
