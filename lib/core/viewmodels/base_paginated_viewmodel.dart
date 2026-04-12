import 'package:flutter/material.dart';
import '../models/paginated_response.dart';

enum ViewState { idle, loading, loaded, error }

abstract class BasePaginatedViewModel<T> extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _error;
  List<T> _items = [];
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isFetchingMore = false;

  // Getters
  ViewState get state => _state;
  String? get error => _error;
  List<T> get items => _items;
  bool get hasMoreData => _hasMoreData;
  bool get isInitialLoading => _state == ViewState.loading;
  bool get isFetchingMore => _isFetchingMore;

  // The method to be implemented by child classes to perform the actual API call
  Future<PaginatedResponse<T>> fetchFromRepository(int page, int perPage);

  Future<void> loadInitialData() async {
    if (_state == ViewState.loading) return;
    
    _state = ViewState.loading;
    _currentPage = 1;
    _items = [];
    _hasMoreData = true;
    _error = null;
    notifyListeners();

    try {
      final response = await fetchFromRepository(_currentPage, 15);
      _items.addAll(response.data);
      _hasMoreData = response.hasMore;
      if (_hasMoreData) _currentPage++;
      _state = ViewState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreData() async {
    if (_isFetchingMore || !_hasMoreData || _state == ViewState.loading) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final response = await fetchFromRepository(_currentPage, 15);
      _items.addAll(response.data);
      _hasMoreData = response.hasMore;
      if (_hasMoreData) _currentPage++;
    } catch (e) {
      // For pagination loading errors, we might want to just show a snackbar or ignore,
      // but we'll set the error so UI can react.
      _error = e.toString();
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // A helper method if a child class needs to mutate data directly (e.g., Bookings optimistic updates)
  void updateItems(List<T> newItems) {
    _items = newItems;
    notifyListeners();
  }
}
