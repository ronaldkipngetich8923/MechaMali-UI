import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/match_model.dart';
import '../../../core/network/api_client.dart';

final watchlistProvider = FutureProvider.autoDispose<List<MatchModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/watchlist');
  final list = res.data as List<dynamic>;
  return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
});

class WatchlistNotifier extends StateNotifier<Set<String>> {
  final dynamic _dio;
  WatchlistNotifier(this._dio) : super({});

  Future<void> toggle(String matchId) async {
    if (state.contains(matchId)) {
      await _dio.delete('/watchlist/$matchId');
      state = {...state}..remove(matchId);
    } else {
      await _dio.post('/watchlist/$matchId');
      state = {...state, matchId};
    }
  }

  bool isWatched(String matchId) => state.contains(matchId);
}

final watchlistNotifierProvider = StateNotifierProvider<WatchlistNotifier, Set<String>>(
  (ref) => WatchlistNotifier(ref.watch(dioProvider)),
);
