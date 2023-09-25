import 'package:flutter/material.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';

abstract class LLM{
  getResponse(List<Message> messages, ValueChanged<Message> onResponse, ValueChanged<Message> errorCallback, ValueChanged<Message> onSuccess);
}