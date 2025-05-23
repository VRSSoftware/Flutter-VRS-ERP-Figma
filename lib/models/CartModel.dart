import 'package:flutter/cupertino.dart';

class CartModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void updateCount(int newCount) {
    _count = newCount;
    notifyListeners();
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}