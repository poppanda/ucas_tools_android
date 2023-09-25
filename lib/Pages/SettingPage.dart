import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:get/get.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController apiKeyController = TextEditingController(),
      baseUrlController = TextEditingController();

  late Widget openAISettings, calendarSettings;
  late SettingController settingController;

  @override
  void initState() {
    super.initState();
    settingController = Get.find<SettingController>();
    apiKeyController.text = settingController.openAiKey.value!;
    baseUrlController.text = settingController.openAiBaseUrl.value!;
  }

  @override
  Widget build(BuildContext context) {
    openAISettings = Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Api Key",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Focus(
              child: TextFormField(
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.grey.shade800),
                  controller: apiKeyController),
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  settingController.setOpenaiKey(apiKeyController.text);
                  log("set openai key to ${apiKeyController.text}");
                } else {
                  log("Entering Api Key Setting");
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Base Url",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Focus(
              child: TextFormField(
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.grey.shade800),
                  controller: baseUrlController),
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  settingController.setOpenAiBaseUrl(baseUrlController.text);
                  log("SettingPage: set openai key to ${baseUrlController.text}");
                } else {
                  log("SettingPage: Entering Api Key Setting");
                }
              },
            ),
          ],
        ),
      ),
    );

    calendarSettings = Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Show Notes",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Obx(
              () => Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: settingController.calendarShowNotes.value!,
                  onChanged: (value) {
                    settingController.setCalendarShowNotes(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            "Setting Page",
            style: TextStyle(fontSize: 30),
          ),
          openAISettings,
          calendarSettings,
        ],
      ),
    );
  }
}
