import 'dart:math';

import 'package:args/args.dart';

const showDetails = 'show-details';
const numRolls = 'num-rolls';
const help = 'help';

const diceSpecEx = '([0-9]*)d([0-9]*)([+|-]?[0-9]*)';

class Dice {
  final int number;
  final int die;
  final int modifier;

  Dice(this.number, this.die, this.modifier);

  @override
  String toString() {
    return '${number}d$die${modifier > 0 ? '+' : ''}${modifier != 0 ? modifier : ''}';
  }

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

  int get value {
    return rolls.reduce((value, element) => value + element) + modifier;
  }

  @override
  String toString() {
    final mod = '${modifier >= 0 ? '+' : '-'} $modifier';
    return '$value\t= (${rolls.join(' + ')}) $mod';
  }
}

// FIXME: add more to the usage info

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag(help, negatable: false, abbr: 'h')
    ..addFlag(showDetails, negatable: false, abbr: 'd')
    ..addOption(numRolls, abbr: 'n', valueHelp: 'num_rolls');

  var args = parser.parse(arguments);

  if (args[help]) {
    print(parser.usage);
  } else {
    final cnt = args[numRolls] != null ? int.parse(args[numRolls]) : 1;
    final dice = Dice.fromSpec(args.rest[0]);

    print('Rolling $dice $cnt time${cnt > 1 ? 's' : ''}...');

    for (var r = 0; r < cnt; r++) {
      print('[${r + 1}]\t${roll(dice)}');
    }
  }
}

RollResults roll(Dice dice) {
  var rng = Random.secure();

  final rolls = <int>[];

  for (var r = 0; r < dice.number; r++) {
    rolls.add(rng.nextInt(dice.die) + 1);
  }

  return RollResults(rolls, dice.modifier);
}
