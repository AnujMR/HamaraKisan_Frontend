import 'package:flutter/material.dart';
import 'package:hamarakisan_front/screens/homeScreen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomBarChart extends StatefulWidget {
  const CustomBarChart({
    super.key,
    required this.title,
    required this.chartData,
    required this.xAxis,
    required this.yAxis,
  });
  final String title;
  final List<TopDistrictData> chartData;
  final ChartAxis xAxis;
  final ChartAxis yAxis;

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      backgroundColor: Colors.white,
      title: ChartTitle(
        text: widget.title,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      primaryXAxis: widget.xAxis,
      primaryYAxis: widget.yAxis,
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<TopDistrictData, String>>[
        ColumnSeries<TopDistrictData, String>(
          dataSource: widget.chartData,
          xValueMapper: (TopDistrictData data, _) => data.district,
          yValueMapper: (TopDistrictData data, _) => data.value,
          name: 'Value',
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: const LinearGradient(
            colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
