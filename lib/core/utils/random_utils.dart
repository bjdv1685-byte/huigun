import 'dart:math';

class RandomUtils {
  RandomUtils._();

  static final Random _random = Random();

  /// 从列表中随机选取一个元素
  static T? pickRandom<T>(List<T> list) {
    if (list.isEmpty) return null;
    return list[_random.nextInt(list.length)];
  }

  /// 洗牌
  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle(_random);
    return shuffled;
  }
}
