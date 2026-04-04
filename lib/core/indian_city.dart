import 'package:catch_dating_app/core/labelled.dart';

enum IndianCity implements Labelled {
  mumbai('Mumbai'),
  delhi('Delhi'),
  bangalore('Bangalore'),
  hyderabad('Hyderabad'),
  chennai('Chennai'),
  kolkata('Kolkata'),
  pune('Pune'),
  ahmedabad('Ahmedabad'),
  indore('Indore');

  const IndianCity(this.label);
  @override
  final String label;
}
