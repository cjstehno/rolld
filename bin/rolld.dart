import 'dart:math';

import 'package:args/args.dart';

const showDetails = 'show-details';
const numRolls = 'num-rolls';
const help = 'help';
const stats = 'stats';

const diceSpecEx = '([0-9]*)d([0-9]*)([+|-]?[0-9]*)';
final rng = Random.secure();

class Dice {
  final int number;
  final int die;
  final int modifier;

  Dice(this.number, this.die, this.modifier);

  int get standard => (number * (die ~/ 2)) + modifier;

  int get low => number + modifier;

  int get high => (number * die) + modifier;

  @override
  String toString() =>
      '${number}d$die${modifier > 0 ? '+' : ''}${modifier != 0 ? modifier : ''}';

  static Dice fromSpec(String spec) {
    final firstMatch = RegExp(diceSpecEx).allMatches(spec).first;
    final n = firstMatch.group(1);
    final d = firstMatch.group(2); // FIXME: error if this is null
    final m = firstMatch.group(3);

    return Dice(
      n!.isNotEmpty ? int.parse(n) : 1,
      int.parse(d!),
      m!.isNotEmpty ? int.parse(m) : 0,
    );
  }
}

class RollResults {
  final List<int> rolls;
  final int modifier;

  RollResults(this.rolls, this.modifier);

  int get value => rolls.reduce((value, element) => value + element) + modifier;

  @override
  String toString() =>
      '$value\t= (${rolls.join(' + ')}) ${modifier >= 0 ? '+' : '-'} $modifier';
}

// FIXME: add more to the usage info

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag(help, negatable: false, abbr: 'h')
    ..addFlag(showDetails, negatable: false, abbr: 'd')
    ..addOption(numRolls, abbr: 'n', valueHelp: 'num_rolls')
    ..addFlag(stats, negatable: false, abbr: 's');

  var args = parser.parse(arguments);

  if (args[help]) {
    print(parser.usage);
  } else {
    final cnt = args[numRolls] != null ? int.parse(args[numRolls]) : 1;
    final dice = Dice.fromSpec(args.rest[0]);

    print('Rolling $dice $cnt time${cnt > 1 ? 's' : ''}...');
    print('-----------------------------------------------');

    final values = <int>[];

    for (var r = 0; r < cnt; r++) {
      var rolled = roll(dice);
      values.add(rolled.value);

      print('[${r + 1}]\t$rolled');
    }

    if (args[stats]) {
      final minVal = values.reduce(min);
      final maxVal = values.reduce(max);
      final avgVal = values.reduce((v, e) => v + e) / values.length;
      print('-----------------------------------------------');
      print('Rolls: $minVal - $maxVal (avg: $avgVal)');
      print('Dice : ${dice.low} - ${dice.high} (avg: ${dice.standard})');
    }
  }
}

RollResults roll(Dice dice) {
  return RollResults(
    Iterable<int>.generate(dice.number)
        .toList()
        .map((e) => rng.nextInt(dice.die) + 1)
        .toList(),
    dice.modifier,
  );
}
