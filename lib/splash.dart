import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'bluetooth_off.dart';
import 'controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return DeviceAutoSelectScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class DeviceAutoSelectScreen extends StatefulWidget {
  @override
  _DeviceAutoSelectScreenState createState() => _DeviceAutoSelectScreenState();
}

class _DeviceAutoSelectScreenState extends State<DeviceAutoSelectScreen> {
  Stream<List<ScanResult>> scanResults;

  @override
  void initState() {
    super.initState();

    // Bluetooth Scan
    FlutterBlue.instance.startScan();

    // 필터링한 블루투스 아이템 정보
    this.scanResults = FlutterBlue.instance.scanResults
        .transform(new StreamTransformer.fromHandlers(handleData: (data, sink) {
      sink.add(data.where((item) => item.device.name == 'CHIPSEN').toList());
    }));

    // 이미 연결 되어있는 데이터 확인
    FlutterBlue.instance.connectedDevices.then((devices) {
      var chipsenDevices = devices.where((item) => item.name == 'CHIPSEN');
      if (chipsenDevices.length > 0) {
        var device = chipsenDevices.first;

        print("ALready Connected");
        this.connectDevice(device, needConnect: false);
      }
    });

    // 검색 되었을떄
    this.scanResults.listen((data) {
      if (data.length > 0) {
        BluetoothDevice device = data[0].device;

        this.connectDevice(device);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<ScanResult>>(
        stream: scanResults,
        initialData: [],
        builder: (c, snapshot) {
          if (snapshot.data.length == 0) {
            return Center(child: CircularProgressIndicator());
          }

          return Center(
              child: Stack(
            children: <Widget>[
              Container(
                child: Image.asset(
                  'assets/pagelight_app_1-1.png',
                  width: 130,
                ),
                alignment: Alignment.center,
              ),
              Container(
                  height: 0,
                  child: Column(
                      children: snapshot.data
                          .map(
                            (r) => RaisedButton(
                              child: Text(
                                r.device.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(color: Colors.white),
                              ),
                              onPressed: () => r.device.connect(),
                            ),
                          )
                          .toList())),
              Container(
                margin: const EdgeInsets.only(bottom: 50.0),
                child: Image.asset(
                  'assets/pagelight_app_1-2.png',
                  width: 32,
                ),
                alignment: Alignment.bottomCenter,
              )
            ],
          ));
        },
      ),
    );
  }

  void connectDevice(BluetoothDevice device, {needConnect = true}) async {
    // Device 정보
    print("Device : $device");

    // Stop Scan
    await FlutterBlue.instance.stopScan();

    // Connect Device
    if (needConnect) {
      print("Connect Request");
      device.connect();
    }

    // State Change
    var subscription;
    subscription = device.state.listen((state) async {
      print("State : $state");
      if (state == BluetoothDeviceState.connected) {
        // Discover
        await device.discoverServices();

        // Move Page Screen
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return ControllerScreen(device: device);
        }));

        if (subscription != null) {
          subscription.cancel();
        }
      }
    });
  }
}
