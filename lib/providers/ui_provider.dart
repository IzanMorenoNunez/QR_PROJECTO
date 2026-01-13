import 'package:flutter/material.dart';

class UIProvider extends ChangeNotifier {
  int _slectedMenuOpt = 1;

  int get selectedMenuOpt {
    return this._slectedMenuOpt;
  }

  set selectedMenuOpt(int index) {
    this._slectedMenuOpt = index;
    notifyListeners();
  }
}
