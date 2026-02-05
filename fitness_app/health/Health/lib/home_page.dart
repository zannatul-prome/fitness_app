 import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Timers
  Timer? _activityTimer;
  Timer? _stepTimer;

  // Fitness Data
  double runningKm = 0.0;
  int totalSteps = 0;
  int walkingTime = 0;
  int runningTime = 0;
  int swimmingTime = 0;
  double bmi = 22.5;
  double weight = 70.0;
  double height = 175.0;
  int waterIntake = 0;
  int waterGoal = 2500;

  // Activity tracking
  bool _isRunning = false;
  bool _isWalking = false;
  bool _isSwimming = false;

  // BMI Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Step goal
  int stepGoal = 10000;

  // Activity history
  List<String> activityHistory = [];

  // Calories burned
  double runningCalories = 0;
  double walkingCalories = 0;
  double swimmingCalories = 0;

  // Night mode
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _weightController.text = weight.toStringAsFixed(1);
    _heightController.text = height.toStringAsFixed(1);
    _calculateBMI();
    _startAutoCounting();
  }

  @override
  void dispose() {
    _stopAllTimers();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    double heightInMeters = height / 100;
    setState(() {
      bmi = weight / (heightInMeters * heightInMeters);
    });
  }

  void _startAutoCounting() {
    _stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRunning || _isWalking) {
        setState(() {
          totalSteps += _isRunning ? 3 : 2;
          if (_isRunning) runningKm += 0.003;
        });
      }
    });

    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) runningTime++;
        if (_isWalking) walkingTime++;
        if (_isSwimming) swimmingTime++;

        // tiny weight loss simulation
        if (_isRunning || _isWalking || _isSwimming) {
          weight -= 0.00001;
          _calculateBMI();
        }

        _updateCalories();
      });
    });
  }

  void _stopAllTimers() {
    _activityTimer?.cancel();
    _stepTimer?.cancel();
  }

  void _updateCalories() {
    runningCalories = runningTime * 0.12;
    walkingCalories = walkingTime * 0.05;
    swimmingCalories = swimmingTime * 0.1;
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getBMICategory() {
    if (bmi < 18.5) return "Underweight 🟦";
    if (bmi < 25) return "Normal 🟩";
    if (bmi < 30) return "Overweight 🟧";
    return "Obese 🟥";
  }

  Color _getBMIColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _showBMICalculator() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("BMI Calculator 📊"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newWeight = double.tryParse(_weightController.text);
                final newHeight = double.tryParse(_heightController.text);

                if (newWeight != null && newWeight > 0 && newHeight != null && newHeight > 0) {
                  setState(() {
                    weight = newWeight;
                    height = newHeight;
                    _calculateBMI();
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid weight and height'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 147, 179),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Calculate BMI', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _addWater([int amount = 500]) {
    setState(() {
      waterIntake += amount;
      if (waterIntake > waterGoal) waterIntake = waterGoal;
    });
  }

  void _resetAllCounters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset All Counters?"),
        content: const Text("This will reset all activity counters to zero."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                runningKm = 0.0;
                totalSteps = 0;
                walkingTime = 0;
                runningTime = 0;
                swimmingTime = 0;
                waterIntake = 0;
                _isRunning = false;
                _isWalking = false;
                _isSwimming = false;
                activityHistory.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("Reset", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _toggleActivity(String type) {
    setState(() {
      bool starting = false;
      if (type == "Running") {
        _isRunning = !_isRunning;
        starting = _isRunning;
      } else if (type == "Walking") {
        _isWalking = !_isWalking;
        starting = _isWalking;
      } else if (type == "Swimming") {
        _isSwimming = !_isSwimming;
        starting = _isSwimming;
      }
      activityHistory.add(
          "$type ${starting ? "started 🏁" : "stopped ⏹"} at ${TimeOfDay.now().format(context)}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("🏃‍♂️ Live Fitness Tracker"),
          backgroundColor: Colors.purpleAccent,
          actions: [
            IconButton(
              icon: const Icon(Icons.calculate),
              onPressed: _showBMICalculator,
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: _resetAllCounters,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                AuthService().logout();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Night Mode Toggle
              SwitchListTile(
                title: const Text("🌙 Dark Mode"),
                value: isDarkMode,
                onChanged: (val) => setState(() => isDarkMode = val),
              ),

              // Activity Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActivityButton("Running 🏃‍♂️", Colors.pink, _isRunning, () => _toggleActivity("Running")),
                    _buildActivityButton("Walking 🚶‍♂️", Colors.purple, _isWalking, () => _toggleActivity("Walking")),
                    _buildActivityButton("Swimming 🏊‍♂️", Colors.teal, _isSwimming, () => _toggleActivity("Swimming")),
                  ],
                ),
              ),

              // Step Goal Tracker
              _buildCard("🎯 Step Goal", [
                LinearProgressIndicator(
                  value: totalSteps / stepGoal > 1 ? 1 : totalSteps / stepGoal,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 15,
                ),
                const SizedBox(height: 5),
                Text("$totalSteps / $stepGoal steps (${(totalSteps/stepGoal*100).toStringAsFixed(0)}%)")
              ]),

              // BMI Card
              _buildBMICard(),

              // Calories Card
              _buildCard("🔥 Calories Burned", [
                _buildStatRow("Running 🏃‍♂️", "${runningCalories.toStringAsFixed(1)} kcal", Icons.local_fire_department),
                _buildStatRow("Walking 🚶‍♂️", "${walkingCalories.toStringAsFixed(1)} kcal", Icons.local_fire_department),
                _buildStatRow("Swimming 🏊‍♂️", "${swimmingCalories.toStringAsFixed(1)} kcal", Icons.local_fire_department),
              ]),

              // Water Tracker
              _buildWaterCard(),

              // Activity History
              _buildCard("📝 Activity History", [
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: activityHistory.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(activityHistory[index]),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "bmi",
              onPressed: _showBMICalculator,
              backgroundColor: Colors.pink[200],
              mini: true,
              child: const Icon(Icons.calculate),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              heroTag: "water",
              onPressed: () => _addWater(),
              backgroundColor: Colors.blue[200],
              icon: const Icon(Icons.water_drop),
              label: const Text("Add Water 💧"),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Widgets
  Widget _buildActivityButton(String label, Color color, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : Colors.grey[200],
        foregroundColor: isActive ? Colors.white : color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> content) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    return _buildCard("📊 BMI Calculator", [
      Row(
        children: [
          Icon(Icons.calculate, color: Colors.purple[800]),
          const SizedBox(width: 10),
          Text("Your BMI: ${bmi.toStringAsFixed(1)}"),
          const Spacer(),
          Text(_getBMICategory()),
        ],
      )
    ]);
  }

  Widget _buildWaterCard() {
    return _buildCard("💧 Water Intake", [
      Text("$waterIntake / $waterGoal ml (${(waterIntake/waterGoal*100).toStringAsFixed(0)}%)"),
      const SizedBox(height: 5),
      LinearProgressIndicator(
        value: waterIntake / waterGoal,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
        minHeight: 15,
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () => _addWater(250), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]), child: const Text("+250ml")),
          ElevatedButton(onPressed: () => _addWater(500), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]), child: const Text("+500ml")),
          ElevatedButton(onPressed: () => _addWater(1000), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]), child: const Text("+1000ml")),
        ],
      ),
    ]);
  }
}
