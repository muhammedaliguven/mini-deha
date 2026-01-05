import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/constants/colors.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({Key? key}) : super(key: key);

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  final LocalStorageService _storage = LocalStorageService();
  DateTime _currentDate = DateTime.now();
  Map<String, int> _scores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // No demo data seeding (Zero Start)
    final scores = await _storage.getSkillScores(date: _currentDate);
    if (mounted) {
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
      "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dataEntries = _scores.entries.toList();
    final monthName = _getMonthName(_currentDate.month);
    final year = _currentDate.year;
    
    // Prepare chart data (pad to 3 to prevent crash)
    final List<MapEntry<String, int>> chartEntries = List.from(dataEntries);
    while (chartEntries.length < 3) {
      chartEntries.add(const MapEntry("", 0));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Yetenek Karnesi 📊"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "$monthName $year Karnesi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MiniDehaColors.primaryDark),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Bu ayki gelişim raporu",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 40),
                  
                  // Radar Chart
                  Expanded(
                    child: dataEntries.isEmpty 
                    ? Center(child: Text("Henüz yeterli veri yok, video izleyin! 📺"))
                    : RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: MiniDehaColors.primary.withOpacity(0.4),
                            borderColor: MiniDehaColors.primary,
                            entryRadius: 3,
                            dataEntries: chartEntries.map((e) => RadarEntry(value: e.value.toDouble())).toList(),
                            borderWidth: 2,
                          ),
                        ],
                        radarBackgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),
                        radarBorderData: const BorderSide(color: Colors.transparent),
                        titlePositionPercentageOffset: 0.1, // Distance of titles from center
                        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                        getTitle: (index, angle) {
                          if (index >= chartEntries.length) return RadarChartTitle(text: "");
                          return RadarChartTitle(text: chartEntries[index].key);
                        },
                        tickCount: 1,
                        ticksTextStyle: const TextStyle(color: Colors.transparent),
                        tickBorderData: const BorderSide(color: Colors.transparent),
                        gridBorderData: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                    ),
                  ),
                  
                  // List View Score Summary
                  Expanded(
                    child: ListView.separated(
                      itemCount: dataEntries.length,
                      separatorBuilder: (c, i) => Divider(),
                      itemBuilder: (context, index) {
                        final entry = dataEntries[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[50], // Randomize colors later
                            child: Text("${index + 1}"),
                          ),
                          title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: MiniDehaColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${entry.value} Puan",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
