// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library goap.test;

import 'package:test/test.dart';
import 'package:goap_bh/goap_bh.dart';

class LumberjackAction extends Action<SimpleState> {
  final String name;
  LumberjackAction(this.name, ApplyAction<SimpleState> applyFunction,
      {num cost: 1, ApplicabilityFunction<SimpleState>? prerequisite})
      : super(applyFunction, cost: cost, prerequisite: prerequisite);

  toString() => name;
}

class LumberjackDream extends DesiredState<SimpleState> {
  @override
  num getHeuristicDistanceFrom(SimpleState? node, {Object? params}) {
    return 100 - node!.facts!["gold"];
  }

  @override
  bool? match(SimpleState? node) => node!.facts!["gold"] >= 100;
}

main() async {
  group('A group of tests', () {
    late LumberjackAction buyAxe;
    late LumberjackAction improveAxe;
    late LumberjackAction chopWood;
    late LumberjackAction chopWoodBetter;
    late LumberjackAction sellWood;
    late LumberjackAction stealGold;
    late LumberjackDream goal;
    late Planner<LumberjackAction> planner;

    setUp(() {
      goal = LumberjackDream();
      planner = Planner<LumberjackAction>();
      buyAxe = LumberjackAction("BuyAxe", (SimpleState? state) {
        state!.facts!["gold"] -= 10;
        state.facts!["axe"] = true;
      }, prerequisite: (SimpleState? state) => state!.facts!["gold"] >= 10);

      improveAxe = new LumberjackAction("ImproveAxe", (SimpleState? state) {
        state!.facts!["gold"] -= 1;
        state.facts!["improvedAxe"] = true;
      },
          prerequisite: (SimpleState? state) =>
              state!.facts!["axe"] == true && state.facts!["gold"] > 1);

      chopWood = LumberjackAction("ChopWood", (SimpleState? state) {
        state!.facts!["lumber"] += 10;
      },
          prerequisite: (SimpleState? state) => state!.facts!["axe"] == true,
          cost: 5);

      chopWoodBetter = LumberjackAction("ChopWoodBetter", (SimpleState? state) {
        state!.facts!["lumber"] += 10;
      },
          prerequisite: (SimpleState? state) =>
              state!.facts!["axe"] == true && state.facts!["improvedAxe"]);

      sellWood = LumberjackAction("SellWood", (SimpleState? state) {
        state!.facts!["lumber"] -= 7;
        state.facts!["gold"] += 10;
      }, prerequisite: (SimpleState? state) => state!.facts!["lumber"] >= 7);

      stealGold = LumberjackAction("StealGold", (SimpleState? s) {
        s!.facts!["gold"] += 50;
      });
    });
    group('Goap tests:', () {
      test('No plan needed Test', () async {
        SimpleState state = SimpleState()
          ..facts = {
            "gold": 101,
            "lumber": 0,
            "axe": false,
            "improvedAxe": false
          };
        var solution = await planner.plan(state, goal,
            [buyAxe, improveAxe, chopWood, chopWoodBetter, sellWood, stealGold],
            previouslyFailedAction: stealGold,
            countdownFailedActionAvoidance: -1);
        expect(solution!.length == 0, isTrue,
            reason:
                'No actions should have been planned, goal was reached in original state.');
      });
      test('Only sell lumber.', () async {
        SimpleState state = SimpleState()
          ..facts = {
            "gold": 0,
            "lumber": 77,
            "axe": false,
            "improvedAxe": false
          };
        var solution = await planner.plan(state, goal,
            [buyAxe, improveAxe, chopWood, chopWoodBetter, sellWood, stealGold],
            previouslyFailedAction: stealGold,
            countdownFailedActionAvoidance: -1);
        expect(solution!.every((action) => action.name == 'SellWood'), isTrue,
            reason:
                'Starting state should have resulted in a plan to only sell wood.');
      });
      test('Has nothing test.', () async {
        SimpleState state = SimpleState()
          ..facts = {
            "gold": 0,
            "lumber": 0,
            "axe": false,
            "improvedAxe": false
          };
        var solution = await planner.plan(state, goal,
            [buyAxe, improveAxe, chopWood, chopWoodBetter, sellWood, stealGold],
            previouslyFailedAction: stealGold,
            countdownFailedActionAvoidance: -1);
        expect(solution == null, isTrue,
            reason: 'There should not have been a valid path to goal.');
      });
      test('Starting with 10 gold.', () async {
        SimpleState state = SimpleState()
          ..facts = {
            "gold": 10,
            "lumber": 0,
            "axe": false,
            "improvedAxe": false
          };
        var solution = await planner.plan(state, goal,
            [buyAxe, improveAxe, chopWood, chopWoodBetter, sellWood, stealGold],
            previouslyFailedAction: stealGold,
            countdownFailedActionAvoidance: -1);
        expect((solution?.length ?? 0) > 0, isTrue,
            reason: 'There should have been a valid path to goal.');
      });
    });
  });
}
