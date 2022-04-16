import 'package:catchpad_flutter_lib/src/models/battery_model.dart';
import 'package:test/test.dart';

void main() {
  test(
    'from bytes',
    () {
      const st = '1/1/4200';

      final bytes = st.codeUnits;

      final model = BatteryModel.fromBytes(bytes);

      expect(model?.voltage, 4200);
      expect(model?.isCharging, true);
      expect(model?.isCompleted, true);
    },
  );
  test(
    'closest bytes',
    () {
      const st = '1/1/4200';
      final bytes = st.codeUnits;
      final model = BatteryModel.fromBytes(bytes);

      expect(model?.closestNums(4100), [4100, 4100]);
      expect(model?.closestNums(4110), [4100, 4200]);
      expect(model?.closestNums(4210), [4200, 4200]);
      expect(model?.closestNums(3190), [3200, 3200]);
      expect(model?.closestNums(3210), [3200, 3300]);
      expect(model?.closestNums(3450), [3400, 3500]);
    },
  );
  test(
    'voltage to percentage',
    () {
      final keys = BatteryModel.voltagePercentageMap.keys;
      for (var i = 0; i < keys.length; i++) {
        final key = keys.elementAt(i);

        final st = '1/1/$key';
        final bytes = st.codeUnits;
        final model = BatteryModel.fromBytes(bytes);

        expect(
          model?.percentage,
          BatteryModel.voltagePercentageMap[key],
        );
      }

      const st1 = '1/1/4130';
      final bytes1 = st1.codeUnits;
      final model1 = BatteryModel.fromBytes(bytes1);

      // actually 94.4, but we're flooring
      expect(model1?.percentage, 94);

      const st2 = '1/1/3835';
      final bytes2 = st2.codeUnits;
      final model2 = BatteryModel.fromBytes(bytes2);

      // actually 6.3, but we're flooring
      expect(model2?.percentage, 49);
    },
  );
}
