import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'scanmodel.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<ScanItem> scanBox = Hive.box<ScanItem>('scans');

    return Scaffold(

      body: ValueListenableBuilder(
        valueListenable: scanBox.listenable(),
        builder: (context, Box<ScanItem> box, _) {

          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No scans yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [

              // 🔴 Swipe Instruction
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Swipe left to delete history',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baskvill', // optional font
                      ),
                    ),
                  ],
                ),
              ),

              // 📜 History List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final scan = box.getAt(index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Slidable(
                        key: ValueKey(scan),

                        // 👉 Swipe LEFT
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                scan!.delete(); // 🔥 Delete from Hive
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),

                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // 🔗 QR Code
                              Text(
                                scan!.code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Baskvill', // optional
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ⏰ Time
                              Text(
                                scan.time
                                    .toLocal()
                                    .toString()
                                    .substring(0, 19),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
