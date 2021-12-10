// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library goap.test;

import 'package:test/test.dart';
//import 'package:goap/goap.dart';

main() {
  group('A group of tests', () {
    bool awesome;

    setUp(() {
      awesome = true;
    });

    test('First Test', () {
      expect(awesome, isTrue);
    });
  });
}
