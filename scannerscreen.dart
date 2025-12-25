import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'scanmodel.dart';
import 'historyscreen.dart';
import 'unsplash.dart'; // SplashScreen import

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  final Box<ScanItem> scanBox = Hive.box<ScanItem>('scans');

  String scannedCode = '';
  DateTime? scannedTime;
  bool isScanning = false;

  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanLineAnimation =
        Tween<double>(begin: 0, end: 230).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  void startScan() {
    setState(() {
      scannedCode = '';
      isScanning = true;
    });
    _animationController.repeat(reverse: true);
  }

  void stopScan() {
    _animationController.stop();
    setState(() {
      isScanning = false;
    });
  }

  void _shareQRCode() {
    if (scannedCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code scanned yet!')),
      );
      return;
    }
    Share.share(
      'Here is my scanned QR code: $scannedCode',
      subject: 'QR Code',
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = _currentIndex == 0 ? 'Scan Screen' : 'History';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              ),
            );
          },
        ),
      ),
      body: _currentIndex == 0 ? _scanUI() : const HistoryScreen(),
      bottomNavigationBar: Stack(
        alignment: AlignmentDirectional.topCenter,
        clipBehavior: Clip.none,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.topCenter,
            children: [
              BottomNavigationBar(
                backgroundColor: Colors.black,
                currentIndex: _currentIndex,
                selectedItemColor: Colors.blue.shade400,
                unselectedItemColor: Colors.grey,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                ],
              ),
              Positioned(
                top: -20, // adjust to float above nav bar
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: scannedCode.isEmpty ? Colors.grey : Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: InkWell(
                    onTap: scannedCode.isEmpty ? null : _shareQRCode,
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _scanUI() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          'Scan QR Code',
          style: TextStyle(
            fontFamily: 'Baskvill',
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 60),
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (BarcodeCapture capture) {
                      if (!isScanning) return;
                      final barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final code = barcodes.first.rawValue;
                        if (code != null) {
                          stopScan();
                          setState(() {
                            scannedCode = code;
                            scannedTime = DateTime.now();
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _shareQRCode(); // Optional: auto share dialog
                          });
                          scanBox.add(
                              ScanItem(code: code, time: DateTime.now()));
                        }
                      }
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue.shade400,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (isScanning)
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanLineAnimation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          color: Colors.blue.shade300,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: startScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade300,
            padding:
            const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Start Scan',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          scannedCode.isEmpty
              ? 'Align QR inside the box'
              : 'Scanned:\n$scannedCode\n\n'
              'Time:\n${scannedTime!.toLocal().toString().substring(0, 19)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
