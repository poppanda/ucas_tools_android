import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/ConversationController.dart';
import 'package:ucas_tools/Controllers/MessageController.dart';
import 'package:ucas_tools/Global.dart';
import 'package:ucas_tools/Pages/ChatPage.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:ucas_tools/Widgets/SideMenu/ChatButtonIcon.dart';
import 'package:ucas_tools/Widgets/SideMenu/SideMenuButton.dart';
import 'package:get/get.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

class ChatButton extends StatefulWidget implements SideMenuButtonInterface {
  ChatButton({
    super.key,
    required this.title,
    required this.uuid,
  });

  late String title;
  late String uuid;

  @override
  var buttonLevel = 0;

  @override
  State<ChatButton> createState() => _ChatButtonState();

  @override
  late Widget? page = Global.chatPage;
}

class _ChatButtonState extends State<ChatButton> {
  late SideMenuButton button;
  late final TextEditingController _titleController =
      TextEditingController(text: widget.title);
  late FocusNode _titleEditFocusNode;
  bool _titleChangeEnabled = false, _deleteActivated = false, _focused = false;

  @override
  void initState() {
    super.initState();
    _titleEditFocusNode = FocusNode();
    widget.page = Global.chatPage;
    var chatStateController = (widget.page as ChatPage).chatStateController;
    chatStateController.addListener(
      () {
        if (chatStateController.chatTitleConcluded) {
          setState(() {
            widget.title = chatStateController.chatTitle;
          });
        }
      },
    );
  }

  void setTitle() {
    String newTitle = _titleController.text;
    Get.find<ConversationController>()
        .updateConversation(Conversation(name: newTitle, uuid: widget.uuid));
  }

  @override
  void dispose() {
    _titleEditFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FontWeight textWeight = FontWeight.w400;
    _titleEditFocusNode.addListener(() {
      // log("ChatButton.dart: Focus changed to ${_titleEditFocusNode.hasFocus} at time ${DateTime.now()}");
      if (!_titleEditFocusNode.hasFocus) {
        if (_focused) {
          _focused = false;
          setState(() {
            _titleChangeEnabled = false;
          });
          setTitle();
        }
      } else {
        if (!_focused) {
          _focused = true;
        }
      }
    });
    Widget baseOptions = Stack(
      children: [
        if (!_deleteActivated)
          Row(
            children: [
              ChatIcon(
                icon: Icons.edit,
                iconSize: 25,
                onPressed: () {
                  setState(() {
                    log("Edit button pressed");
                    _titleChangeEnabled = true;
                    if (_titleChangeEnabled) {
                      Future.delayed(const Duration(milliseconds: 10), () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context)
                            .requestFocus(_titleEditFocusNode);
                      });
                      _titleController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _titleController.text.length,
                      );
                    }
                  });
                },
              ),
              ChatIcon(
                icon: Icons.delete,
                iconSize: 25,
                onPressed: () {
                  setState(() {
                    _deleteActivated = true;
                  });
                },
              ),
            ],
          ),
        if (_deleteActivated)
          TapRegion(
            onTapOutside: (event) {
              setState(() {
                _deleteActivated = false;
              });
            },
            child: Row(
              children: [
                ChatIcon(
                  icon: Icons.check,
                  iconSize: 25,
                  onPressed: () {
                    setState(() {
                      log("Delete button pressed");
                      Get.find<ConversationController>()
                          .deleteConversation(widget.uuid);
                      _deleteActivated = false;
                    });
                  },
                ),
                ChatIcon(
                  icon: Icons.close,
                  iconSize: 25,
                  onPressed: () {
                    setState(() {
                      _deleteActivated = false;
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );

    return Container(
      width: 180,
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: ElevatedButton(
        style: ButtonStyle(
          padding:
              MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: () {
          ConversationController controller = Get.find();
          controller.setCurrentConversationUUid(widget.uuid);
          Get.find<MessageController>().loadAllMessages(widget.uuid);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage()),
          );
          log("ChatButton.dart: Pressed ${widget.title} with uuid ${widget.uuid}");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100,
              child: Theme(
                data: ThemeData(disabledColor: Colors.black54),
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: textWeight,
                  ),
                  enabled: _titleChangeEnabled,
                  focusNode: _titleEditFocusNode,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.all(5),
                  ),
                ),
              ),
            ),
            baseOptions,
          ],
        ),
      ),
    );
  }
}
