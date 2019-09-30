import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _ControllerScreenState createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  var isPowerOn = false;
  var brightness = 1.0;

  @override
  void initState() {
    super.initState();

    // Writable Characteristics
    this.widget.device.services.listen((services) {
      print("Service Listen : $services");
      services.forEach((service) {
        print(service.characteristics);
        service.characteristics.forEach((c) => print(c.uuid));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'assets/pagelight_app_2-1.png',
                      width: 85,
                    ),
                    alignment: Alignment.center,
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          margin: EdgeInsets.only(left: 46, top: 30),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: this.togglePower,
                            child: new Image.asset(
                              'assets/pagelight_app_2-2.png',
                              width: 100,
                            ),
                          ))),
                  Container(
                    margin: const EdgeInsets.only(bottom: 51.0, right: 31),
                    child: Image.asset(
                      'assets/pagelight_app_2-4.png',
                      width: 24,
                    ),
                    alignment: Alignment.bottomRight,
                  ),
                  Container(
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(-45 / 360),
                      child: Slider(
                        activeColor: Colors.black,
                        inactiveColor: Colors.black,
                        value: this.brightness,
                        min: 1.0,
                        max: 3.0,
                        divisions: 2,
                        onChanged: (value) {
                          setState(() {
                            this.brightness = value;
                          });
                          this.updateBrightness();
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 55.0, left: 30),
                    child: Image.asset(
                      'assets/pagelight_app_2-3.png',
                      width: 24,
                    ),
                    alignment: Alignment.bottomLeft,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 50.0),
                    child:
                        Image.asset('assets/pagelight_app_1-2.png', width: 32),
                    alignment: Alignment.bottomCenter,
                  )
                ],
              ))),
    );
  }

  void togglePower() async {
    var command = this.isPowerOn ? 'W0015300000' : 'W0015300001';

    this.widget.device.services.forEach((services) {
      services.forEach((service) {
        service.characteristics.forEach((c) {
          if (c.uuid.toString().toLowerCase() ==
              '0000fff2-0000-1000-8000-00805f9b34fb') {
            c.write(utf8.encode(command));
          }
        });
      });
    });

    setState(() {
      this.isPowerOn = !this.isPowerOn;
    });
  }

  void updateBrightness() async {
    var command = 'W011530000${this.brightness.toInt()}';

    this.widget.device.services.forEach((services) {
      services.forEach((service) {
        service.characteristics.forEach((c) {
          if (c.uuid.toString().toLowerCase() ==
              '0000fff2-0000-1000-8000-00805f9b34fb') {
            c.write(utf8.encode(command));
          }
        });
      });
    });
  }

  @override
  void dispose() {
    this.widget.device.disconnect();
    super.dispose();
  }
}
