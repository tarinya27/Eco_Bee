// This class is used to localize the app
class Localization {
  static const String errorLoadingData =
      'Error loading data. Please try again.';
  static const String noUserDataAvailable = 'No user data available.';
  final String dashboard;
  final String welcome;
  final String selectYourLanguage;
  final String pleaseAddUnits;
  final String automation;
  final String feedingHistory;
  final String units;
  final String insights;
  final String sinhala;
  final String english;
  final String species;
  final String frames;
  final String hiveSize;
  final String location;
  final String fillInTheFields;
  final String addUnit;
  final String save;
  final String unitId;
  final String nickname;
  final String selectApiaryProvince;
  final String selectApiaryDistrict;
  final String noUnitsFound;
  final String selectTheUnit;
  final String noUnitSelected;
  final String startAutomation;
  final String noDataAvailable;
  final String production;
  final String addProduction;
  final String quantity;
  final String feedToProdRatio;

  Localization({
    required this.dashboard,
    required this.welcome,
    required this.selectYourLanguage,
    required this.pleaseAddUnits,
    required this.automation,
    required this.feedingHistory,
    required this.units,
    required this.insights,
    required this.sinhala,
    required this.english,
    required this.species,
    required this.frames,
    required this.hiveSize,
    required this.location,
    required this.fillInTheFields,
    required this.addUnit,
    required this.save,
    required this.unitId,
    required this.nickname,
    required this.selectApiaryProvince,
    required this.selectApiaryDistrict,
    required this.noUnitsFound,
    required this.selectTheUnit,
    required this.noUnitSelected,
    required this.startAutomation,
    required this.noDataAvailable,
    required this.production,
    required this.addProduction,
    required this.quantity,
    required this.feedToProdRatio,
  });
}

Localization sinhalaLocalization = Localization(
  dashboard: 'Dashboard',
  welcome: 'ආයුබෝවන්',
  selectYourLanguage: 'ඔබේ භාෂාව තෝරන්න',
  pleaseAddUnits: '"මී මැසි ඒකක" ටයිල් එක ඔබා ඒකක එකතු කරන්න',
  automation: 'ස්වයංක්‍රීයකරණය',
  feedingHistory: 'පෝෂණය කිරීමේ ඉතිහාසය',
  units: 'මී මැසි ඒකක',
  insights: 'දත්ත විශ්ලේෂණය',
  sinhala: 'සිංහල',
  english: 'English',
  species: 'මී මැසි විශේෂය',
  frames: 'රාමු ගණන',
  hiveSize: 'මී වදයේ ප්‍රමාණය',
  location: 'ස්ථානය',
  fillInTheFields: 'කරුණාකර සියල්ල නිවැරදිව පුරවන්න',
  addUnit: 'ඒකක එකතු කරන්න',
  save: 'සුරකින්න',
  unitId: 'ඒකක හැඳුනුම් අංකය',
  nickname: 'ඒකක නාමය',
  selectApiaryProvince: 'මී මැසි පෙට්ටිය තිබෙන පළාත',
  selectApiaryDistrict: 'මී මැසි පෙට්ටිය තිබෙන දිස්ත්‍රික්කය',
  noUnitsFound: 'ඒකක නැත',
  selectTheUnit: 'ඒකකය තෝරන්න',
  noUnitSelected: 'ඒකකයක් තෝරා නැත',
  startAutomation: 'ස්වයංක්‍රීයකරණය ආරම්භ කරන්න',
  noDataAvailable: 'දත්ත නොමැත',
  production: 'පැණි නිෂ්පාදන',
  addProduction: 'පැණි නිෂ්පාදන ප්‍රමාණය සටහන් කරන්න',
  quantity: 'ප්‍රමාණය (kg)',
  feedToProdRatio: 'නිෂ්පාදන-පෝෂණ අනුපාතය',
);

Localization englishLocalization = Localization(
  dashboard: 'Dashboard',
  welcome: 'Welcome',
  selectYourLanguage: 'Select your language',
  pleaseAddUnits: 'Please add units by tapping the "Units" tile.',
  automation: 'Automation',
  feedingHistory: 'Feeding History',
  units: 'Hive Units',
  insights: 'Data-Driven Insights',
  sinhala: 'සිංහල',
  english: 'English',
  species: 'Bee Species',
  frames: 'Frames',
  hiveSize: 'Hive Size',
  location: 'Location',
  fillInTheFields: 'Please fill all fields correctly',
  addUnit: 'Add Unit',
  save: 'Save',
  unitId: 'Unit ID',
  nickname: 'Nickname',
  selectApiaryProvince: 'Select Apiary Province',
  selectApiaryDistrict: 'Select Apiary District',
  noUnitsFound: 'No units found',
  selectTheUnit: 'Select the Unit',
  noUnitSelected: 'No unit selected',
  startAutomation: 'Start Automation',
  noDataAvailable: 'No data available',
  production: 'Honey Production',
  addProduction: 'Add Production',
  quantity: 'Quantity (kg)',
  feedToProdRatio: 'Feed to Production Ratio',
);
