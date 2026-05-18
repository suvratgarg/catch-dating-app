import 'package:catch_dating_app/core/labelled.dart';

const defaultCountryIsoCode = 'IN';
const defaultCountryDialCode = '+91';
const defaultCurrencyCode = 'INR';
const defaultTimeZone = 'Asia/Kolkata';

const supportedCountryPickerFavorites = ['IN', 'NP', 'AU', 'US'];

class CountryMarket implements Labelled {
  const CountryMarket({
    required this.isoCode,
    required this.label,
    required this.dialCode,
    required this.currencyCode,
    required this.currencySymbol,
    required this.defaultCityName,
    required this.timeZone,
    this.currencyMinorUnitFactor = 100,
  });

  final String isoCode;
  @override
  final String label;
  final String dialCode;
  final String currencyCode;
  final String currencySymbol;
  final String defaultCityName;
  final String timeZone;
  final int currencyMinorUnitFactor;
}

const defaultCountryMarket = CountryMarket(
  isoCode: 'IN',
  label: 'India',
  dialCode: '+91',
  currencyCode: 'INR',
  currencySymbol: '₹',
  defaultCityName: 'mumbai',
  timeZone: 'Asia/Kolkata',
);

const supportedCountryMarkets = [
  defaultCountryMarket,
  CountryMarket(
    isoCode: 'NP',
    label: 'Nepal',
    dialCode: '+977',
    currencyCode: 'NPR',
    currencySymbol: 'Rs ',
    defaultCityName: 'kathmandu',
    timeZone: 'Asia/Kathmandu',
  ),
  CountryMarket(
    isoCode: 'AU',
    label: 'Australia',
    dialCode: '+61',
    currencyCode: 'AUD',
    currencySymbol: 'A\$',
    defaultCityName: 'sydney',
    timeZone: 'Australia/Sydney',
  ),
  CountryMarket(
    isoCode: 'US',
    label: 'United States',
    dialCode: '+1',
    currencyCode: 'USD',
    currencySymbol: '\$',
    defaultCityName: 'new-york',
    timeZone: 'America/New_York',
  ),
];

CountryMarket marketForIsoCode(String? isoCode) {
  final normalized = isoCode?.trim().toUpperCase();
  for (final market in supportedCountryMarkets) {
    if (market.isoCode == normalized) return market;
  }
  return defaultCountryMarket;
}

CountryMarket marketForDialCode(String? dialCode) {
  final normalized = dialCode?.trim();
  for (final market in supportedCountryMarkets) {
    if (market.dialCode == normalized) return market;
  }
  return defaultCountryMarket;
}

CountryMarket marketForCurrencyCode(String? currencyCode) {
  final normalized = currencyCode?.trim().toUpperCase();
  for (final market in supportedCountryMarkets) {
    if (market.currencyCode == normalized) return market;
  }
  return defaultCountryMarket;
}

String countryIsoForDialCode(String? dialCode) =>
    marketForDialCode(dialCode).isoCode;

String formatMinorCurrency(
  int amountMinorUnits, {
  String currencyCode = defaultCurrencyCode,
}) {
  final market = marketForCurrencyCode(currencyCode);
  final factor = market.currencyMinorUnitFactor;
  final sign = amountMinorUnits < 0 ? '-' : '';
  final absolute = amountMinorUnits.abs();
  final whole = absolute ~/ factor;
  final remainder = absolute % factor;
  final groupedWhole = _formatWholeCurrencyUnits(whole);
  final value = remainder == 0
      ? groupedWhole
      : '$groupedWhole.${remainder.toString().padLeft(2, '0')}';
  return '$sign${market.currencySymbol}$value';
}

String _formatWholeCurrencyUnits(int value) {
  final digits = value.toString();
  final firstGroupLength = digits.length % 3;
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 &&
        (index - firstGroupLength) % 3 == 0 &&
        (firstGroupLength != 0 || index != 0)) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }

  return buffer.toString();
}
