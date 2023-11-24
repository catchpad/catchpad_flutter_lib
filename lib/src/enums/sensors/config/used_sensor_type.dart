/// well we have `SensorType` but, that does not include
/// sub categories like tap and motion.
enum UsedSensorsType {
  tap,
  motion,
  distance,
  force,
  none;

  static UsedSensorsType getSensorTypeByIndex(int val) {
    switch(val) {
      case 0:
        return UsedSensorsType.tap;
      case 1:
        return UsedSensorsType.motion;
      case 2:
        return UsedSensorsType.distance;
      case 3:
        return UsedSensorsType.force;
      default:
        return UsedSensorsType.none;
    }
  }

}
