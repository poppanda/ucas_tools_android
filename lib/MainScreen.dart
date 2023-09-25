import 'package:flutter/material.dart';
import 'package:ucas_tools/Global.dart';
import 'package:ucas_tools/Pages/CalendarPage.dart';
import 'package:ucas_tools/Pages/ChatListPage.dart';
import 'package:ucas_tools/Pages/HomePage.dart';
import 'package:ucas_tools/Pages/SettingPage.dart';
import 'package:ucas_tools/Pages/TranslatePage.dart';
import 'package:ucas_tools/Widgets/SideMenu/SideMenu.dart';
import 'package:ucas_tools/Widgets/SideMenu/SideMenuButton.dart';
import 'package:ucas_tools/Controllers/SideMenuController.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  SideMenuController sideMenuController = SideMenuController();
  Widget currentPage = const Placeholder();
  double bottom_padding = 200;

  @override
  void initState() {
    Global.sideMenuController = sideMenuController;
    super.initState();
    Global.sideMenuController.addListener(() {
      if (sideMenuController.Page != currentPage) {
        setState(() {
          currentPage = sideMenuController.Page;
        });
      }
      setState(() {
        bottom_padding = sideMenuController.height;
      });
    });

    sideMenuController.chatListButton = SideMenuButton(
      icon: const Icon(Icons.chat),
      title: "Chat",
      page: ChatListPage(),
    );
    sideMenuController.translateButton = SideMenuButton(
        icon: const Icon(Icons.translate),
        title: "Translate",
        page: const TranslatePage());
    sideMenuController.homeButton = SideMenuButton(
        icon: const Icon(Icons.home), title: "Home", page: const HomePage());
    sideMenuController.settingButton = SideMenuButton(
      icon: const Icon(Icons.settings),
      title: "Settings",
      page: const SettingPage(),
    );
    sideMenuController.calendarButton = SideMenuButton(
      icon: const Icon(Icons.calendar_month_outlined),
      title: "Calendar",
      page: const CalendarPage(),
      // page: Placeholder(),
    );
    Global.sideMenuController.pressedMenuButton = sideMenuController.homeButton;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if(Platform.)
    return Scaffold(
      // appBar: AppBar(title: const Text("ChatGPT demo")),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottom_padding, top: MediaQuery.of(context).viewPadding.top),
            child: currentPage,
          ),
          SideMenu(
            controller: sideMenuController,
            children: [
              Global.sideMenuController.homeButton,
              Global.sideMenuController.chatListButton,
              Global.sideMenuController.translateButton,
              Global.sideMenuController.calendarButton,
              Global.sideMenuController.settingButton,
              // SideMenuButton(title: "Logout"),
            ],
          ),
        ],
      ),
    );
  }
}
