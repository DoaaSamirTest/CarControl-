import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';  // لاستعمال Uint8List
import 'dart:convert';  // لاستعمال utf8


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Control Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ControlScreen(),
    );
  }
}

class ControlScreen extends StatefulWidget {
  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  BluetoothConnection? connection;
  bool isConnected = false;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  // الحصول على الأجهزة المقترنة
  void _getBondedDevices() async {
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  // الاتصال بجهاز Bluetooth
  void _connect(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      print(e);
    }
  }

  // إرسال الأوامر للعربة
  void _sendCommand(String command) async {
  if (connection == null || !connection!.isConnected) {
    print("⚠️ Device not connected! Please check the connection first.");
    return;
  }

  try {
    Uint8List data = Uint8List.fromList(utf8.encode(command)); // ✅ التحويل إلى Uint8List
    connection!.output.add(data);
    await connection!.output.allSent;
    print("Command sent: $command");
  } catch (e) {
    print("An error occurred while sending: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 148, 133, 189),
        title: Text('Car Control Application',style: TextStyle(fontSize: 20),),
        
        
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth,color: Colors.black,size: 40,),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Select Bluetooth Device'),
                  content: Container(
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(devices[index].name ?? 'Unknown'),
                          onTap: () {
                            _connect(devices[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage("images/pexels-maltelu-1397751.jpg"), // تأكد إن اسم الصورة صحيح وموجود في المسار
      fit: BoxFit.fill, // يخلي الصورة تغطي الشاشة كلها
    ),
  ),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _sendCommand('F'),
          child: Icon(Icons.arrow_upward, size: 50),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(20),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _sendCommand('L'),
              child: Icon(Icons.arrow_back, size: 50),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
              ),
            ),
            SizedBox(width: 100),
            ElevatedButton(
              onPressed: () => _sendCommand('R'),
              child: Icon(Icons.arrow_forward, size: 50),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _sendCommand('B'),
          child: Icon(Icons.arrow_downward, size: 50),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(20),
          ),
        ),
        SizedBox(height: 120),
        ElevatedButton(
          onPressed: () => _sendCommand('S'),
          child: Text(
            'STOP',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 148, 133, 189),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          ),
        ),
      ],
    ),
  ),
      )
    );

  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }
}
