(String, double) assessFeeding({
  required double hiveTemp,
  required double hiveHumidity,
  required double externalTemp,
  required bool raining,
  required DateTime currentTime,
  required int numFrames,
  required String beeSpecies,
  required String hiveSize,
  (DateTime, double)? lastFeeding,
}) {
  const double optimalHiveTempMin = 32.0;
  const double optimalHiveTempMax = 35.0;
  const double optimalHiveHumidityMin = 50.0;
  const double optimalHiveHumidityMax = 60.0;
  const double minForagingTemp = 10.0;
  const int feedingIntervalHours = 4;

  // Assess foraging conditions
  bool poorForagingConditions = raining || externalTemp < minForagingTemp;

  // Evaluate hive conditions
  bool suboptimalHiveConditions = hiveTemp < optimalHiveTempMin ||
      hiveTemp > optimalHiveTempMax ||
      hiveHumidity < optimalHiveHumidityMin ||
      hiveHumidity > optimalHiveHumidityMax;

  // Determine season
  int month = currentTime.month;
  bool isSpring = (month >= 3 && month <= 5);
  bool isAutumn = (month >= 9 && month <= 11);
  bool isNectarScarceSeason = isSpring || isAutumn;

  // Determine hive size factor
  double hiveSizeFactor;
  switch (hiveSize.toLowerCase()) {
    case 'small':
      hiveSizeFactor = 1.0;
    case 'medium':
      hiveSizeFactor = 1.5;
    case 'large':
      hiveSizeFactor = 2.0;
    default:
      throw ArgumentError('Invalid hive size');
  }

  // Determine species factor
  double speciesFactor;
  switch (beeSpecies.toLowerCase()) {
    case 'apis mellifera':
      speciesFactor = 1.2; // Higher feeding needs
    case 'apis cerana':
      speciesFactor = 0.8; // Lower feeding needs
    default:
      speciesFactor = 1.0; // Default factor for other species
  }

  // Check last feeding time
  if (lastFeeding != null) {
    var (lastFeedingTime, _) = lastFeeding;
    Duration timeSinceLastFeeding = currentTime.difference(lastFeedingTime);
    if (timeSinceLastFeeding.inHours < feedingIntervalHours) {
      return ('No feeding necessary at this time; previous feeding was recent.', 0.0);
    }
  }

  // Calculate feeding necessity and quantity
  if (poorForagingConditions || suboptimalHiveConditions ||
      isNectarScarceSeason) {
    double baseFeedAmount = 1000.0; // in milliliters
    double feedQuantity = baseFeedAmount * hiveSizeFactor * speciesFactor *
        (numFrames / 10.0);

    return ('Feed the bees with $feedQuantity liters of sugar syrup.', feedQuantity);
  } else {
    return ('No feeding necessary at this time.', 0.0);
  }
}
