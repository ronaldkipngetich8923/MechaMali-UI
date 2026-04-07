import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/match_model.dart';
import '../../../core/network/api_client.dart';

// Region filter
enum LeagueRegion { all, kenya, africa, international }

final selectedRegionProvider = StateProvider<LeagueRegion>((ref) => LeagueRegion.all);

// Matches fetcher
final matchesProvider = FutureProvider.autoDispose<List<MatchModel>>((ref) async {
  final dio    = ref.watch(dioProvider);
  final region = ref.watch(selectedRegionProvider);

  final params = <String, String>{};
  if (region != LeagueRegion.all) {
    params['leagueRegion'] = region.name[0].toUpperCase() + region.name.substring(1);
  }

  final res = await dio.get('/matches', queryParameters: params);
  final list = res.data as List<dynamic>;
  return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
});

// Single match
final matchDetailProvider = FutureProvider.autoDispose.family<MatchModel, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/matches/$id');
  return MatchModel.fromJson(res.data as Map<String, dynamic>);
});
