import 'package:flutter/material.dart';
import 'package:hamarakisan_front/commonWidgets/barChart.dart';
import 'package:hamarakisan_front/providers/homeProvider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PinnedMandisComparison extends StatefulWidget {
  const PinnedMandisComparison({super.key});

  @override
  State<PinnedMandisComparison> createState() => _PinnedMandisComparisonState();
}

class _PinnedMandisComparisonState extends State<PinnedMandisComparison> {
  List<String>  commodities = [];
  
  String selectedComm = "";
  int gradientIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commodities = Provider.of<HomeProvider>(context, listen: false).pinnedMandiComparison.keys.toList();
    if(commodities.isNotEmpty){
      selectedComm = commodities[0];
      gradientIndex = 0;
    }
  }

  List gradients = [
    [Color(0xFFe65c00), Color.fromARGB(255, 232, 195, 12)],
    [Color(0xFF2193b0), Color(0xFF6dd5ed)],
    [Color(0xFFcc2b5e), Color(0xFF753a88)],
    [Color(0xFFee9ca7), Color(0xFFffdde1)],
    [Color(0xFFbdc3c7), Color(0xFF2c3e50)],
    [Color.fromARGB(255, 15, 18, 197), Color(0xFF2657eb)],
    [Color(0xFF06beb6), Color(0xFF48b1bf)],
  ];

  @override
  Widget build(BuildContext context) {
    commodities = Provider.of<HomeProvider>(
      context,
    ).pinnedMandiComparison.keys.toList();
    final List<PinnedMandiCommData> chartData = Provider.of<HomeProvider>(context)
            .pinnedMandiComparison[selectedComm]!.entries
        .map((e) => PinnedMandiCommData(e.key, e.value))
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        SfCartesianChart(
            backgroundColor: Colors.white,
            title: ChartTitle(
              text: "Average Price Comparison for $selectedComm",
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            primaryXAxis: CategoryAxis(
              title: AxisTitle(text: 'Districts', textStyle: TextStyle(fontWeight: FontWeight.bold)),
              labelRotation: 45,
              axisLabelFormatter: (AxisLabelRenderDetails args) {
                String text = args.text;
                // Trim labels longer than 10 characters
                if (text.length > 10) {
                  text = '${text.substring(0, 8)}…';
                }
                return ChartAxisLabel(text, args.textStyle);
              },
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Avg Price',
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              majorTickLines: const MajorTickLines(size: 0),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<PinnedMandiCommData, String>>[
              ColumnSeries<PinnedMandiCommData, String>(
                animationDuration: 500,
                dataSource: chartData,
                xValueMapper: (PinnedMandiCommData data, _) => data.district,
                yValueMapper: (PinnedMandiCommData data, _) => data.value,
                name: 'Value',
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  colors: gradients[gradientIndex],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left:  MediaQuery.of(context).size.width * 0.05),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              
            ),
            child: Wrap(
              spacing: 8.0,
              children: commodities.map((comm) {
                final bool isSelected = comm == selectedComm;
                return ChoiceChip(
                  label: Text(comm),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedComm = comm;
                      gradientIndex = commodities.indexOf(comm) % gradients.length;
                    });
                  },
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ),
      ],),
    );
  }
}

class PinnedMandiCommData {
  PinnedMandiCommData(this.district, this.value);
  final String district;
  final int value;
}

