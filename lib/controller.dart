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
                    child: Text(
                      "page light",
                      style: Theme.of(context).textTheme.headline,
                    ),
                    alignment: Alignment.center,
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: this.togglePower,
                          child: IconButton(
                            iconSize: 128,
                            icon: Icon(
                              Icons.settings_power,
                              color:
                                  this.isPowerOn ? Colors.purple : Colors.black,
                            ),
                            onPressed: this.togglePower,
                          ))),
                  Container(
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(-15 / 360),
                      child: Slider(
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
