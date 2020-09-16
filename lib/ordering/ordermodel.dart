import 'package:scoped_model/scoped_model.dart';
import 'dart:math';

class OrderModel extends Model {
  double _totalCost = 9.90;

  double get totalCost => _totalCost;


  void calculateOrderCost(
    double subjectCost,
    double documentCost,
    double urgencyCost,
    double academicCost,
    int spacing,
    int pages,
  ) {
    _totalCost =
        (8.61 * documentCost * subjectCost * urgencyCost * academicCost) *
            pages;
    if (spacing == 2) {
      _totalCost = _totalCost * 2;
    }

    _totalCost = roundDouble(_totalCost, 2);

    notifyListeners();
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void setTotalCost(double total) {
    _totalCost = total;

    notifyListeners();
  }
}
