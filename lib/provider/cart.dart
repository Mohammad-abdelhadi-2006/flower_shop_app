import 'package:flower_shop_app/model/item.dart';
import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  List<Item> selectedProducts = [];
  int price = 0;

  void add(Item product) {
    selectedProducts.add(product);
    price += product.price.round();
    notifyListeners();
  }

  void delete(Item product) {
    selectedProducts.remove(product);
    price -= product.price.round();

    notifyListeners();
  }

  int get itemCount {
    return selectedProducts.length;
  }
}
