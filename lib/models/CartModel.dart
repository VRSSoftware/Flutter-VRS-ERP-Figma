import 'package:flutter/cupertino.dart';

class CartModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

   Set<String> _addedItems = {};

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

    void refreshAddedItems() {
    notifyListeners();
  }

    void addItems(Set<String> newItems) {
    _addedItems = _addedItems.union(newItems);
    notifyListeners();
  }
}