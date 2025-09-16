import 'package:flutter/material.dart';
import '../widgets/info_card.dart'; // Import InfoCard widget
import 'package:fl_chart/fl_chart.dart'; // Import chart package
import '../services/firebase_service.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';

// Reverted to original StatefulWidget name
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Add controllers for setpoint input fields
  final _pressureSetpointController = TextEditingController(text: '1000');
  final _temperatureSetpointController = TextEditingController(text: '45');

  // Add state variables for real-time data
  String _waterLevel = 'UNKNOWN';
  double _pressure = 0.0;
  double _temperature = 0.0;
  double _pressureSetpoint = 1000.0;
  double _temperatureSetpoint = 45.0;

  // Add lists for chart data
  final List<FlSpot> _waterLevelSpots = [];
  final List<FlSpot> _pressureSpots = [];
  final List<FlSpot> _temperatureSpots = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Listen to water level changes
    _firebaseService.getWaterLevelStream().listen((value) {
      setState(() {
        _waterLevel = value;
        
        // Convert water level string to a numeric value for the chart if possible
        double? waterLevelValue;
        if (value != 'UNKNOWN') {
          // Try to parse as double if it's a number
          waterLevelValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
        }
        
        // If we got a valid number, add it to the chart data
        if (waterLevelValue != null) {
          _updateChartData(_waterLevelSpots, waterLevelValue);
        }
      });
    });

    // Listen to pressure changes
    _firebaseService.getPressureStream().listen((value) {
      setState(() {
        _pressure = value;
        _updateChartData(_pressureSpots, value);
      });
    });

    // Listen to temperature changes
    _firebaseService.getTemperatureStream().listen((value) {
      setState(() {
        _temperature = value;
        _updateChartData(_temperatureSpots, value);
      });
    });

    // Listen to pressure setpoint changes
    _firebaseService.getPressureSetpointStream().listen((value) {
      setState(() {
        _pressureSetpoint = value;
        _pressureSetpointController.text = value.toString();
      });
    });

    // Listen to temperature setpoint changes
    _firebaseService.getTemperatureSetpointStream().listen((value) {
      setState(() {
        _temperatureSetpoint = value;
        _temperatureSetpointController.text = value.toString();
      });
    });
  }

  void _updateChartData(List<FlSpot> spots, double value) {
    spots.add(FlSpot(spots.length.toDouble(), value));
    if (spots.length > 7) {
      spots.removeAt(0);
    }
  }

  @override
  void dispose() {
    _pressureSetpointController.dispose();
    _temperatureSetpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use theme background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('BoilNexus Dashboard'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white, // Set text/icon color explicitly
        elevation: 0, // Flat app bar
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: const Color(0xFF1D1E33), // Match your card/input color
                  elevation: 8,
                  title: Column(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'Confirm Logout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                // Call AuthService to sign out and clear local data
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Cards section (restored implementation)
            _buildInfoSection(),
            const SizedBox(height: 24),
            // Placeholder for Setpoint Controls (restored placeholder)
            _buildSetpointSection(),
            const SizedBox(height: 24),
            // Placeholder for Chart (restored placeholder)
            _buildChartSection(),
          ],
        ),
      ),
    );
  }

  // Restored Info Section implementation
  Widget _buildInfoSection() {
    return Column(
      children: [
        InfoCard(
          title: 'Water level',
          currentValue: _waterLevel,
          setpointValue: 'N/A',
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Pressure',
          currentValue: '${_pressure.toStringAsFixed(1)} bar',
          setpointValue: '${_pressureSetpoint.toStringAsFixed(1)} bar',
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Temperature',
          currentValue: '${_temperature.toStringAsFixed(1)}°C',
          setpointValue: '${_temperatureSetpoint.toStringAsFixed(1)} °C',
        ),
      ],
    );
  }

  // Implement Setpoint Controls section
  Widget _buildSetpointSection() {
    final theme = Theme.of(context);
    InputDecoration setpointInputDecoration(String label) => InputDecoration(
          // Use theme defaults where possible
          // fillColor: theme.inputDecorationTheme.fillColor?.withOpacity(0.5), // Slightly different background?
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: label,
          hintStyle: TextStyle(color: theme.hintColor?.withOpacity(0.5)),
        );

    ButtonStyle applyButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce extra padding
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Setpoints', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSetpointRow(
            label: 'Pressure (bar)',
            controller: _pressureSetpointController,
            inputDecoration: setpointInputDecoration('1000'),
            buttonStyle: applyButtonStyle,
            onApply: () async {
              final value = double.tryParse(_pressureSetpointController.text);
              if (value != null) {
                await _firebaseService.updatePressureSetpoint(value);
              }
              FocusScope.of(context).unfocus();
            },
          ),
          const SizedBox(height: 12),
          _buildSetpointRow(
            label: 'Temperature (°C)',
            controller: _temperatureSetpointController,
            inputDecoration: setpointInputDecoration('45'),
            buttonStyle: applyButtonStyle,
            onApply: () async {
              final value = double.tryParse(_temperatureSetpointController.text);
              if (value != null) {
                await _firebaseService.updateTemperatureSetpoint(value);
              }
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for a single setpoint row
  Widget _buildSetpointRow({
    required String label,
    required TextEditingController controller,
    required VoidCallback onApply,
    required InputDecoration inputDecoration,
    required ButtonStyle buttonStyle,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
        // const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: SizedBox(
            // height: 40, // Constrain height
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: inputDecoration,
               style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onApply,
          style: buttonStyle,
          child: Text('APPLY'),
        ),
      ],
    );
  }

  // Implement Chart section
  Widget _buildChartSection() {
    final theme = Theme.of(context);
    
    Widget buildCombinedChart() {
      // Calculate dynamic maxY based on current values
      double maxY = [
        _waterLevel == 'EMPTY' ? 0.0 : double.tryParse(_waterLevel.replaceAll('%', '')) ?? 0.0,
        _pressure,
        _temperature,
      ].reduce((curr, next) => curr > next ? curr : next).toDouble();
      
      // Add 20% padding to maxY and round up to nearest hundred
      maxY = (maxY * 1.2 / 100).ceil() * 100;
      // Ensure minimum scale of 100
      maxY = math.max(maxY, 100);
      
      return Container(
        height: 300,
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Color(0xFF1B1E27),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY / 5, // Dynamic interval based on maxY
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                    titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                        interval: maxY / 5, // Dynamic interval based on maxY
                        reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const titles = ['Water', 'Pressure', 'Temp'];
                          final index = value.toInt();
                          if (index >= 0 && index < titles.length) {
                            return Text(
                              titles[index],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                ),
                              );
                            }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    // Water Level Bar
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: _waterLevel == 'EMPTY' ? 0.0 : double.tryParse(_waterLevel.replaceAll('%', '')) ?? 0.0,
                          color: Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                    // Pressure Bar
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: _pressure,
                          color: Colors.greenAccent,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                    // Temperature Bar
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: _temperature,
                          color: Colors.orangeAccent,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tooltipMargin: 0,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String value = '';
                        switch (group.x) {
                          case 0:
                            value = _waterLevel;
                            break;
                          case 1:
                            value = '${_pressure.toStringAsFixed(1)} bar';
                            break;
                          case 2:
                            value = '${_temperature.toStringAsFixed(1)}°C';
                            break;
                        }
                        return BarTooltipItem(
                          value,
                          TextStyle(
                            color: rod.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Legend
            Container(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Colors.blue, 'Water Level', _waterLevel),
                  _buildLegendItem(Colors.greenAccent, 'Pressure', '${_pressure.toStringAsFixed(1)} bar'),
                  _buildLegendItem(Colors.orangeAccent, 'Temperature', '${_temperature.toStringAsFixed(1)}°C'),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Text(
            'Real-time Monitoring',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        buildCombinedChart(),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 