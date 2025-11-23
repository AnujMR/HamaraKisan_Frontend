import 'package:flutter/material.dart';

class SimplePriceTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const SimplePriceTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          color: Colors.grey.shade300,
          child: const Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  "Commodity",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Avg Price",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Unit",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ------------------ BODY ROWS ------------------
        ...data.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(entry.key)),
                Expanded(
                  flex: 2,
                  child: Text(entry.value["avg_price"].toString()),
                ),
                Expanded(flex: 2, child: Text(entry.value["unit"])),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
