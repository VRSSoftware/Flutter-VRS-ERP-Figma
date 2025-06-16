import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  int _count = 0;
  Set<String> _addedItems = {};

  int get count => _count;
  Set<String> get addedItems => _addedItems;

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

  void addItem(String styleCode) {
    _addedItems.add(styleCode);
    notifyListeners();
  }

  void updateAddedItems(Set<String> newItems) {
    _addedItems = newItems;
    notifyListeners();
  }

  void clearAddedItems() {
    _addedItems.clear();
    notifyListeners();
  }

  void refreshAddedItems() {
    notifyListeners();
  }
}