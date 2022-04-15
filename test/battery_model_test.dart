import 'package:catchpad_flutter_lib/src/models/battery_model.dart';
import 'package:test/test.dart';

void main() {
  test(
    'from bytes',
    () {
      const st = '1/1/4.2';

      final bytes = st.codeUnits;

      final model = BatteryModel.fromBytes(bytes);

      expect(model.voltage, 4.2);
      expect(model.isCharging, true);
      expect(model.isCompleted, true);
    },
  );
  test(
    'closest bytes',
    () {
      const st = '1/1/4.2';
      final bytes = st.codeUnits;
      final model = BatteryModel.fromBytes(bytes);

      expect(model.closestNums(4.1), [4.1, 4.1]);
      expect(model.closestNums(4.11), [4.1, 4.2]);
      expect(model.closestNums(4.21), [4.2, 4.2]);
      expect(model.closestNums(3.19), [3.2, 3.2]);
      expect(model.closestNums(3.21), [3.2, 3.3]);
      expect(model.closestNums(3.45), [3.4, 3.5]);
    },
  );
  test(
    'voltage to percentage',
    () {
      const _st = '1/1/4.2';
      final _bytes = _st.codeUnits;
      final _model = BatteryModel.fromBytes(_bytes);

      final keys = _model.voltagePercentageMap.keys;
      for (var i = 0; i < keys.length; i++) {
        final key = keys.elementAt(i);

        final st = '1/1/$key';
        final bytes = st.codeUnits;
        final model = BatteryModel.fromBytes(bytes);

        expect(
          model.percentage,
          _model.voltagePercentageMap[key],
        );
      }
    },
  );
}
