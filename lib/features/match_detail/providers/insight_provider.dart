import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/insight_model.dart';
import '../../../core/network/api_client.dart';

final insightProvider = FutureProvider.autoDispose.family<InsightModel, String>((ref, matchId) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/matches/$matchId/insights');
  return InsightModel.fromJson(res.data as Map<String, dynamic>);
});
