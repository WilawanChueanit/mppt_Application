import 'dart:async';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mppt_esp32/widgets/mptt_data_card_widget.dart';
import 'package:mppt_esp32/widgets/mptt_data_overview_widget.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Double> wattList = List<Double>();
  List<Double> voltageList = List<Double>();
  List<Double> ampList = List<Double>();
  List<Double> degreeList = List<Double>();
  List<Double> batvoltageList = List<Double>();
  List<String> chargeType = List<String>();
  List<Double> percentage = List<Double>();
  Double volt, amp, watt, degree, batvolt, percen;
  String cahrgeType;

  Timer timer;
  FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  fetchSolarCellData() async {
    DatabaseReference databaseReference = _firebaseDatabase.reference();

    var query = databaseReference
        .child('SolarCell')
        .orderByChild('Created_Time')
        .limitToLast(1);
    await query.onChildAdded.forEach(
      (element) {
        Map<dynamic, dynamic> solarValue = element.snapshot.value;
        setState(() {
          volt = solarValue["Voltage"];
          amp = solarValue["Current"];
          watt = solarValue["Power"];
          degree = solarValue["Degree"];
        });
      },
    );
  }

  fetchBatteryData() async {
    DatabaseReference databaseReference = _firebaseDatabase.reference();

    var query = databaseReference
        .child('Battery')
        .orderByChild('Created_Time')
        .limitToLast(1);
    await query.onChildAdded.forEach(
      (element) {
        Map<dynamic, dynamic> batValue = element.snapshot.value;
        setState(() {
          batvolt = batValue["Voltage"];
          cahrgeType = batValue["Charge_Type"];
          percen = batValue["Percentage"];
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    /* Call for first time */
    fetchSolarCellData();
    /* Call timer to iterable function */
    timer =
        Timer.periodic(Duration(seconds: 1), (timer) => fetchSolarCellData());

    fetchBatteryData();
    timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => fetchBatteryData(),
    );
  }

  Future refreshQuery() async {
    await Future.delayed(Duration(seconds: 2), () {
      fetchSolarCellData();
    });

    await Future.delayed(Duration(seconds: 2), () {
      fetchBatteryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: __dashboardAppbar(),
      drawer: Container(
        width: 250,
        color: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: RefreshIndicator(
            onRefresh: refreshQuery,
            child: ListView(
              children: <Widget>[
                MPTTDataOverviewCardWidget(
                  icon: Image.asset("images/solacell.png"),
                  dataTitle: "SOLAR CELL",
                  children: Column(
                    children: [
                      SizedBox(height: 5),
                      MPTTDataCardWidget(dataValue: "VOLTAGE : $volt V"),
                      SizedBox(height: 5),
                      MPTTDataCardWidget(dataValue: "CURRENT : $amp A"),
                      SizedBox(height: 5),
                      MPTTDataCardWidget(dataValue: "POWER : $watt W"),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
                MPTTDataOverviewCardWidget(
                  icon: Image.asset("images/battery.png"),
                  dataTitle: "BATTERY",
                  children: Column(
                    children: [
                      SizedBox(height: 5),
                      MPTTDataCardWidget(dataValue: "VOLTAGE : $batvolt  V"),
                      SizedBox(height: 5),
                      MPTTDataCardWidget(
                          dataValue: "CHARGE TYPE : $cahrgeType "),
                      SizedBox(height: 5),
                      MPTTDataCardWidget(dataValue: "PERCENTAGE : $percen  %"),
                    ],
                  ),
                ),
                MPTTDataOverviewCardWidget(
                  icon: Image.asset("images/solacell.png"),
                  dataTitle: "SOLAR DEGREES",
                  children: Column(
                    children: [
                      SizedBox(height: 5),
                      MPTTDataCardWidget(dataValue: "DEGREES : $degree "),
                    ],
                  ),
                ),
                // __solarCellWidget(name: "SOLAR CELL", image: "solacell.png"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget __dashboardAppbar() => AppBar(
        centerTitle: true,
        title: Text('MPTT ESP32'),
      );
}
