import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/data/repositories/quote_repository.dart';
import 'package:pomodoro_app/core/constants/app_durations.dart';

/// Provider for QuoteRepository so it can be injected via ref.read.
final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository();
});

class SplashState {
  final String? quote;
  final bool ready;

  const SplashState({this.quote, this.ready = false});
}

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    _init();
    return const SplashState();
  }

  Future<void> _init() async {
    final repo = ref.read(quoteRepositoryProvider);
    final quote = await repo.getRandomUnshownQuote();
    await Future.delayed(
      const Duration(seconds: AppDurations.splashDelaySeconds),
    );
    state = SplashState(quote: quote?.text, ready: true);
  }
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
