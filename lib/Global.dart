import 'package:flutter/material.dart';
import 'package:ucas_tools/Pages/ChatPage.dart';
import 'package:ucas_tools/Controllers/SideMenuController.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class Global{
  static late SideMenuController sideMenuController;
  static ConversationDB conversationDB = ConversationDB();
  static Uuid uuid = const Uuid();
  static ChatPage chatPage = ChatPage();
}

TextStyle get subHeadingStyle{
  return GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black45,
  );
}

TextStyle get headingStyle{
  return GoogleFonts.lato(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}