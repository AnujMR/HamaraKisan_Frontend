import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomLineChart extends StatefulWidget {
  const CustomLineChart({super.key, required this.title, required this.dataList, required this.xAxis, required this.yAxis});
  final String title;
  final List<CartesianSeries> dataList;
  final ChartAxis xAxis;
  final ChartAxis yAxis;


  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
                    title: ChartTitle(
        text: widget.title,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: widget.xAxis,
                    primaryYAxis: widget.yAxis,
                    series: widget.dataList,
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                    ),
                  );
  }
}