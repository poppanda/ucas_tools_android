import 'package:flutter/material.dart';
import 'package:ucas_tools/Controllers/ConversationController.dart';
import 'package:ucas_tools/Controllers/MessageController.dart';
import 'package:ucas_tools/Controllers/SettingController.dart';
import 'package:ucas_tools/MainScreen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:window_manager/window_manager.dart';

void main() async{
  // await windowManager.ensureInitialized();
  // if(Platform.isLinux || Platform.isWindows || Platform.isMacOS){
  //   WindowOptions windowOptions = WindowOptions(
  //     size: Size(1200, 800),
  //     minimumSize: Size(820, 600),
  //   );
  //   windowManager.waitUntilReadyToShow(windowOptions, ()async{
  //     await windowManager.show();
  //     await windowManager.focus();
  //   });
  // }
  
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    Get.put(ConversationController());
    Get.put(MessageController());
    Get.put(SettingController());
    return MaterialApp(
      title: "ChatGPt demo",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        cardColor: Colors.indigo.shade100,
        shadowColor: Colors.grey.withOpacity(0.5), 
        focusColor: const Color.fromARGB(215, 74, 122, 255),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
          backgroundColor: Colors.white,
          cardColor: Colors.indigo.shade50,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade500,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(215, 74, 122, 255),
              width: 1,
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
