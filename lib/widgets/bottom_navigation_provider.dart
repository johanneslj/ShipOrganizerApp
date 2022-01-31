import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationBarIndexProvider = StateNotifierProvider<BottomNavigationBarIndexNotifier, int>((ref) => BottomNavigationBarIndexNotifier());

class BottomNavigationBarIndexNotifier extends StateNotifier<int> {
  BottomNavigationBarIndexNotifier() : super(0);

  updateIndex(int value) {
    state = value;
  }
}
