import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/mock_data_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider() {
    _items = MockDataService.instance.notifications;
  }

  late List<AppNotification> _items;
  NotificationCategory? _filter;

  List<AppNotification> get items =>
      _filter == null ? _items : _items.where((n) => n.category == _filter).toList();

  NotificationCategory? get filter => _filter;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  void setFilter(NotificationCategory? category) {
    _filter = category;
    notifyListeners();
  }

  void markAsRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _items[i] = _items[i].markRead();
    notifyListeners();
  }

  void markAllRead() {
    _items = _items.map((n) => n.markRead()).toList();
    notifyListeners();
  }
}
