import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final title = 'Flutter BLE Scan Demo';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  var scan_mode = 0;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  /* 시작, 정지 */
  void toggleState() {
    isScanning = !isScanning;

    if (isScanning) {
      flutterBlue.startScan(
          scanMode: ScanMode(scan_mode), allowDuplicates: true);
      scan();
    } else {
      flutterBlue.stopScan();
    }
    setState(() {});
  }

  /* 
  Scan Mode
  Ts = scan interval 
  Ds = duration of every scan window
             | Ts [s] | Ds [s]
  LowPower   | 5.120  | 1.024
  BALANCED   | 4.096  | 1.024
  LowLatency | 4.096  | 4.096

  LowPower = ScanMode(0);
  BALANCED = ScanMode(1);
  LowLatency = ScanMode(2);

  opportunistic = ScanMode(-1);
   */

  /* Scan */
  void scan() async {
    if (isScanning) {
      // Listen to scan results

      flutterBlue.scanResults.listen((results) {
        // do something with scan results

        scanResultList = results;
        // update state
        setState(() {});
      });
    }
  }

  /* device RSSI */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* device MAC address  */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  /* device name  */
  Widget deviceName(ScanResult r) {
    String name;

    if (r.device.name.isNotEmpty) {
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      name = r.advertisementData.localName;
    } else {
      name = 'N/A';
    }
    return Text(name);
  }

  /* BLE icon widget */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
  }

  void onTap(ScanResult r) {
    print('${r.device.name}');
  }

  /* ble item widget */
  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  /* UI */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleState,
        child: Icon(isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
