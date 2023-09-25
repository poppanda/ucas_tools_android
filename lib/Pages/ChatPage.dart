import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/ChatStateController.dart';
import 'package:ucas_tools/Controllers/ConversationController.dart';
import 'package:ucas_tools/Controllers/MessageController.dart';
import 'package:ucas_tools/Utils/conversation_db.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  final ChatStateController chatStateController = ChatStateController();

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  // final List<Widget> _messages = [];
  final List<OpenAIChatCompletionChoiceMessageModel> chatMessages = [];
  bool enterByEnter = true, showOptions = false;
  String model = 'gpt-3.5-turbo';
  final _scrollController = ScrollController();

  void _sendMessage(String text) async {
    if (widget.chatStateController.chatTitleConcluded == false) {
      widget.chatStateController.chatTitleConcluded = true;
      List<OpenAIChatCompletionChoiceMessageModel> tempMessages =
          List.from(chatMessages);
      tempMessages.add(
        const OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: "Conclude a title in five words for this chat"),
      );
      var stream2 = OpenAI.instance.chat
          .createStream(messages: tempMessages, model: model);
      stream2.listen(
        (event) {
          widget.chatStateController.chatTitle +=
              event.choices.first.delta.content!;
          widget.chatStateController.chatTitleConcluded = true;
          widget.chatStateController.notifyListeners();
        },
      );
    }
  }

  void _sendMessageFromText() async {
    if (_textController.text.isEmpty) {
      return;
    }

    Message newMessage = Message(
        text: _textController.text,
        role: Role.user,
        conversationId:
            Get.find<ConversationController>().currentConversationUUid.value);

    _textController.clear();

    MessageController controller = Get.find();
    controller.postMessage(newMessage);
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            maxLines: null,
            controller: _textController,
            onSubmitted: (value) => _sendMessageFromText(),
            onChanged: (value) {
              if (enterByEnter && value.endsWith('\n')) {
                _textController.text = _textController.text
                    .substring(0, _textController.text.length - 1);
                _sendMessageFromText();
              }
            },
            decoration: const InputDecoration(
              hintText: "Input a message",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => _sendMessageFromText(),
        )
      ],
    );
  }

  Widget modelSelector() {
    return ListTile(
      title: const Text("Model"),
      trailing: DropdownButton<String>(
        value: model,
        underline: Container(),
        focusColor: Theme.of(context).canvasColor,
        onChanged: (String? newValue) {
          setState(() {
            model = newValue!;
          });
        },
        items: <String>[
          'gpt-3.5-turbo',
          'text-davinci-003',
          'davinci',
        ].map(
          (e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          },
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ConversationController conversationController = Get.find();
    // String currentUuid = Get<ConversationController>.find().currentConversationUUid.value;
    String currentUuid =
        Get.find<ConversationController>().currentConversationUUid.value;
    Get.find<MessageController>().loadAllMessages(currentUuid);
    // controller.loadAllMessages(currentUuid);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Get.find<ConversationController>()
              .conversationList
              .firstWhere((element) => element.uuid == currentUuid)
              .name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.find<ConversationController>()
                  .deleteConversation(currentUuid);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(child: GetX<MessageController>(
            builder: (controller) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                _scrollToNewMessage();
              });

              List<Message> messages = controller.messageList;
              return ListView.builder(
                controller: _scrollController,
                // padding: Vx.m8,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return messages[index].toChatMessage();
                },
              );
            },
          )),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  offset: const Offset(0, 0),
                  color: Theme.of(context).shadowColor,
                ),
              ],
              color: Theme.of(context).canvasColor,
            ),
            padding: const EdgeInsets.only(top: 8.0, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      showOptions = !showOptions;
                    });
                  },
                  icon: showOptions
                      ? const Icon(Icons.arrow_downward)
                      : const Icon(Icons.arrow_forward),
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.zero),
                  ),
                ),
                SizedBox(
                  width: 0.8 * MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                          color: Theme.of(context).shadowColor,
                        ),
                      ],
                    ),
                    child: _buildTextComposer(),
                  ),
                ),
              ],
            ),
          ),
          if (showOptions)
            SizedBox(
              height: 0.3 * MediaQuery.of(context).size.height,
              width: 0.8 * MediaQuery.of(context).size.width,
              child: ListView(
                children: [
                  ListTile(
                    title: const Text("Enter by enter"),
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        // splashRadius: 2,
                        value: enterByEnter,
                        onChanged: (value) {
                          setState(() {
                            enterByEnter = value;
                          });
                        },
                      ),
                    ),
                  ),
                  modelSelector(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _scrollToNewMessage() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
