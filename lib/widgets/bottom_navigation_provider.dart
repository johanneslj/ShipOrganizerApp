import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationBarIndexProvider = StateNotifierProvider<BottomNavigationBarIndexNotifier, int>((ref) => BottomNavigationBarIndexNotifier());

/// This is the bottom navigation bar index notifier
/// it notifies when the index of the bottom navigation bar changes
class BottomNavigationBarIndexNotifier extends StateNotifier<int> {
  BottomNavigationBarIndexNotifier() : super(0);

  updateIndex(int value) {
    state = value;
  }
}
