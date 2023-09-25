import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ucas_tools/Widgets/SideMenu/SideMenuButton.dart';


class SideMenuController extends ChangeNotifier{
  late Widget _page;
  late List<Widget> _sideMenuButtons;
  SideMenuButtonInterface _pressedMenuButton = SideMenuButtonInterface();
  late SideMenuButton chatListButton, translateButton, homeButton, settingButton, calendarButton;
  ExpansionTileController expansionTileController = ExpansionTileController();
  bool shrinked = false;
  double height = 70;
  // ExpansionController expansionController;

  SideMenuController(){
    _sideMenuButtons = [];
    _page = Container();
    
    // ChatListButton chatListButton = ChatListButton();
  }

  Widget get Page => _page;
  set Page(Widget page){
    _page = page;
    notifyListeners();
  }

  List<Widget> get sideMenuButtons => _sideMenuButtons;
  set sideMenuButtons(List<Widget> sideMenuButtons){
    _sideMenuButtons = sideMenuButtons;
    notifyListeners();
  }

  SideMenuButtonInterface get pressedMenuButton => _pressedMenuButton;
  set pressedMenuButton(SideMenuButtonInterface pressedMenuButton){
    _pressedMenuButton = pressedMenuButton;
    if (_pressedMenuButton.page != null) {
      Page = _pressedMenuButton.page!;
    }
    notifyListeners();
  }

  void pressShrink(){
    log("SideMenuController: pressShrink");
    shrinked = !shrinked;
    height = 70;
    notifyListeners();
  }
}