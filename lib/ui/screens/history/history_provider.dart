import 'package:flutter/material.dart';
import '../../../data/models/history_model.dart';
import '../../../data/repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository = HistoryRepository();

  bool _isLoading = false;
  String? _error;
  List<History> _historyItems = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMoreData = true;
  String _selectedFilter = 'Semua';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<History> get historyItems => _historyItems;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMoreData => _hasMoreData;
  String get selectedFilter => _selectedFilter;

  List<History> get filteredHistory {
    if (_selectedFilter == 'Semua') {
      return _historyItems;
    } else {
      return _historyItems
          .where(
            (item) =>
                item.status.toLowerCase() == _selectedFilter.toLowerCase(),
          )
          .toList();
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void _resetPagination() {
    _currentPage = 1;
    _lastPage = 1;
    _hasMoreData = true;
    _historyItems = [];
  }

  Future<void> getHistory({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _resetPagination();
    }

    if (!_hasMoreData && !refresh) return;

    try {
      _setLoading(true);
      _clearError();

      final response = await _repository.getHistory(page: _currentPage);

      if (response.success && response.data != null) {
        final historyData = response.data!;

        if (refresh) {
          _historyItems = historyData.data;
        } else {
          _historyItems.addAll(historyData.data);
        }

        _currentPage = historyData.currentPage;
        _lastPage = historyData.lastPage;
        _hasMoreData = _currentPage < _lastPage;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _setError('Gagal mendapatkan data riwayat: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMoreData || _isLoading) return;
    _currentPage++;
    await getHistory();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}
