import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/mock_data_service.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider() {
    _all = MockDataService.instance.transactions
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  late List<TransactionModel> _all;
  TransactionType? _filter;

  List<TransactionModel> get all => _all;
  TransactionType? get filter => _filter;

  List<TransactionModel> get filtered =>
      _filter == null ? _all : _all.where((t) => t.type == _filter).toList();

  void setFilter(TransactionType? type) {
    _filter = type;
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _all = [transaction, ..._all];
    notifyListeners();
  }
}
