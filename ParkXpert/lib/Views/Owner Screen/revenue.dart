import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Revenue extends StatefulWidget {
  const Revenue({super.key});

  @override
  State<Revenue> createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
  bool isLineChart = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0081C9), // New AppBar color
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Parking Revenue",
          style: TextStyle(
            color: Colors.white, // Changed for better contrast
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White icon
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isLineChart ? Icons.bar_chart : Icons.show_chart_rounded,
              color: Colors.white, // White icon
            ),
            onPressed: () => setState(() {
              isLineChart = !isLineChart;
            }),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("parkings")
            .where("uid", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No parking data available."));
          }

          final List<_RevenueData> chartData = docs.map((doc) {
            final name = doc['parkingName'] ?? 'Parking';
            final earning = (doc['parkingEarning'] ?? 0).toDouble();
            return _RevenueData(name, earning);
          }).toList();

          final total = chartData.fold(0.0, (sum, item) => sum + item.earning);

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Revenue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Rs. ${total.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0081C9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SfCartesianChart(
                      title: ChartTitle(text: 'Revenue by Parking'),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      primaryXAxis: CategoryAxis(
                        labelRotation: 0,
                        labelIntersectAction: AxisLabelIntersectAction.wrap,
                      ),
                      series: isLineChart
                          ? <CartesianSeries<_RevenueData, String>>[
                              LineSeries<_RevenueData, String>(
                                name: 'Earning', // Tooltip label
                                dataSource: chartData,
                                xValueMapper: (data, _) => data.name,
                                yValueMapper: (data, _) => data.earning,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true),
                                markerSettings:
                                    const MarkerSettings(isVisible: true),
                                color: const Color(0xFF0081C9),
                              )
                            ]
                          : <CartesianSeries<_RevenueData, String>>[
                              ColumnSeries<_RevenueData, String>(
                                name: 'Earning', // Tooltip label
                                dataSource: chartData,
                                xValueMapper: (data, _) => data.name,
                                yValueMapper: (data, _) => data.earning,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true),
                                pointColorMapper: (_, __) =>
                                    const Color(0xFF0081C9),
                              )
                            ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RevenueData {
  final String name;
  final double earning;

  _RevenueData(this.name, this.earning);
}
