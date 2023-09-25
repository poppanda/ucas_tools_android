import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController{
  late GetStorage storage;
  final Rxn<String> username = Rxn("User");

  final Rxn<String> openAiKey = Rxn();
  final Rxn<String> openAiBaseUrl = Rxn();

  final Rxn<bool> calendarShowNotes = Rxn();
  final Rxn<String> calendarView = Rxn();

  final GetStorage openaiStorage = GetStorage("openAI");
  final GetStorage calendarStorage = GetStorage("calendar");

  @override
  void onInit()async{
    storage = GetStorage();
    openAiKey.value = readFromStorage("openAIKey");
    log(openAiKey.value??"null");
    openAiBaseUrl.value = readFromStorage("openAIBaseUrl");
    calendarShowNotes.value = readFromStorage("showNotes");
    calendarView.value = readFromStorage("calendarView");

    if(openAiKey.value == null) setOpenaiKey("sk-xx");
    if(openAiBaseUrl.value == null) setOpenAiBaseUrl("https://api.openai.com");
    if(calendarShowNotes.value == null) setCalendarShowNotes(true);
    if(calendarView.value == null) setCalendarView("week");
    super.onInit();
  }
  
  dynamic readFromStorage(String key, ){
    return storage.read(key);
  }

  void writeToStorage(String key, dynamic value){
    storage.write(key, value);
    log("writeToStorage: $key, $value, and read it back: ${readFromStorage(key)}");
  }

  void setOpenaiKey(String apiKey){
    openAiKey.value = apiKey;
    writeToStorage("openAIKey", apiKey);
    // storage.write("apiKey", apiKey);
    update();
  }

  void setOpenAiBaseUrl(String baseUrl){
    log("setOpenAiBaseUrl: $baseUrl");
    openAiBaseUrl.value = baseUrl;
    writeToStorage("openAIBaseUrl", baseUrl);
    update();
  }

  void setCalendarShowNotes(bool showNotes){
    log("setCalendarShowNotes: $showNotes");
    calendarShowNotes.value = showNotes;
    writeToStorage("showNotes", showNotes);
    update();
  }

  void setCalendarView(String view){
    log("setCalendarView: $view");
    calendarView.value = view;
    writeToStorage("calendarView", view);
    update();
  }
}