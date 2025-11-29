import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  int _currentModule = 0;
  Map<String, dynamic> _selectedData = {};

  int get currentModule => _currentModule;
  Map<String, dynamic> get selectedData => _selectedData;

  void setCurrentModule(int module) {
    _currentModule = module;
    notifyListeners();
  }

  void setSelectedData(Map<String, dynamic> data) {
    _selectedData = data;
    notifyListeners();
  }

  void clearSelectedData() {
    _selectedData = {};
    notifyListeners();
  }
}






