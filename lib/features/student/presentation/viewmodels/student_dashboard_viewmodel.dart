import 'package:flutter/material.dart';
import '../../data/models/student_models.dart';
import '../../domain/repositories/student_repository.dart';

enum ViewState { idle, loading, loaded, error }

class StudentDashboardViewModel extends ChangeNotifier {
  final StudentRepository _repository;

  StudentDashboardViewModel(this._repository);

  ViewState _state = ViewState.idle;
  String? _error;
  StudentDashboardModel? _dashboard;

  ViewState get state => _state;
  String? get error => _error;
  StudentDashboardModel? get dashboard => _dashboard;
  bool get isLoading => _state == ViewState.loading;

  Future<void> fetchDashboard() async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      _dashboard = await _repository.getDashboard();
      _state = ViewState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
