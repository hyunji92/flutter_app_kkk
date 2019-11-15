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
  var brightness = 0;

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            child: InkWell(
                              customBorder: CircleBorder(),
                              onTap: () {
                                brightness = 0;
                                updateBrightness();
                              },
                              child: Image.asset(
                                'assets/ic_light_0.png',
                                width: 81,
                                height: 81,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            child: InkWell(
                              customBorder: CircleBorder(),
                              onTap: () {
                                brightness = 2;
                                updateBrightness();
                              },
                              child: Image.asset(
                                'assets/ic_light_50.png',
                                width: 81,
                                height: 81,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            child: InkWell(
                              customBorder: CircleBorder(),
                              onTap: () {
                                brightness = 3;
                                updateBrightness();
                              },
                              child: Image.asset(
                                'assets/ic_light_100.png',
                                width: 81,
                                height: 81,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
