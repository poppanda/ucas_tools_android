import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:ucas_tools/Controllers/TranslatePageController.dart';
import 'package:get/get.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage>
    with AutomaticKeepAliveClientMixin<TranslatePage> {
  final TextEditingController sourceTextController = TextEditingController();
  String sourceLanguage = 'English';
  String targetLanguage = 'Chinese';
  String model = 'gpt-3.5-turbo';
  String translation = TranslatePageController.translationText,
      translationHint = "";
  StreamController outputStreamController = StreamController();
  @override
  bool get wantKeepAlive => true;
  final TextStyle dropdownButtonTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  Widget inputBox() {
    if (TranslatePageController.sourceText != "") {
      sourceTextController.text = TranslatePageController.sourceText;
    }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                blurRadius: 5,
                color: Colors.black38,
                offset: Offset(3, 3),
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: sourceTextController,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: (value) {
              TranslatePageController.sourceText = sourceTextController.text;
            },
          ),
        ),
      ),
    );
  }

  Widget outputBox() {
    return Expanded(
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black38),
          color: Theme.of(context).canvasColor,
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black38,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: StreamBuilder(
              stream: outputStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == "hint") {
                    return Text(
                      translationHint,
                      style: const TextStyle(fontSize: 18),
                    );
                  } else {
                    TranslatePageController.translationText = translation;
                    return SelectableText(
                      translation,
                      style: const TextStyle(fontSize: 18),
                    );
                  }
                } else {
                  return Text(TranslatePageController.translationText);
                }
              }),
        ),
      ),
    );
  }

  Widget languageSelection(
      String previousHint, bool isSource, List<String> languageList) {
    return Row(
      children: [
        Text(
          previousHint,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        DropdownButton<String>(
          style: dropdownButtonTextStyle,
          underline: Container(),
          focusColor: Theme.of(context).canvasColor,
          value: isSource ? sourceLanguage : targetLanguage,
          onChanged: (String? newValue) {
            setState(() {
              if (isSource) {
                sourceLanguage = newValue!;
              } else {
                targetLanguage = newValue!;
              }
            });
          },
          items: languageList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void clearText() {
    TranslatePageController.sourceText = "";
    TranslatePageController.translationText = "";
    sourceTextController.clear();
    translationHint = "";
    translation = "";
    outputStreamController.add("hint");
  }

  void translate() {
    if (sourceTextController.text.isEmpty) {
      return;
    }

    translation = "";

    translationHint = "Translating...";
    outputStreamController.add("hint");

    String translateText =
        "Translate the following text from $sourceLanguage to $targetLanguage: ${sourceTextController.text}";

    var stream = OpenAI.instance.chat.createStream(model: model, messages: [
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: translateText)
    ]);

    stream.listen((event) {
      translation += event.choices.first.delta.content!;
      outputStreamController.add("update");
    });
  }

  @override
  void initState() {
    OpenAI.apiKey = Get.find<SettingController>().openAiKey.value!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Flexible(
                    flex: 15,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            languageSelection(
                                'Source Language: ', true, <String>[
                              'English',
                              'Spanish',
                              'French',
                              'German',
                              'Chinese'
                            ]),
                          ],
                        ),
                        inputBox(),
                      ],
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Flexible(
                    flex: 15,
                    child: Column(
                      children: [
                        languageSelection('Target Language: ', false, <String>[
                          'English',
                          'Spanish',
                          'French',
                          'German',
                          'Chinese'
                        ]),
                        outputBox(),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: clearText,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(133, 50)),
                  maximumSize: MaterialStateProperty.all(const Size(133, 50)),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ElevatedButton(
                onPressed: translate,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(133, 50)),
                  maximumSize: MaterialStateProperty.all(const Size(133, 50)),
                ),
                child: const Text(
                  'Translate',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
