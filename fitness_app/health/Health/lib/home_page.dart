import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_service.dart';

class Exercise {
  final String name;
  final String emoji;
  final Color color;
  int time;

  Exercise({
    required this.name,
    required this.emoji,
    required this.color,
    this.time = 0,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _activityTimer;
  Timer? _stepTimer;
  Map<String, Timer?> _exerciseTimers = {};

  double runningKm = 0.0;
  int totalSteps = 0;
  int walkingTime = 0;
  int runningTime = 0;
  int swimmingTime = 0;
  double runningCalories = 0;
  double walkingCalories = 0;
  double swimmingCalories = 0;

  double bmi = 22.5;
  double weight = 70.0;
  double height = 175.0;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  int waterIntake = 0;
  int waterGoal = 2500;
  int stepGoal = 10000;

  bool _isRunning = false;
  bool _isWalking = false;
  bool _isSwimming = false;
  bool isDarkMode = false;

  List<String> activityHistory = [];

  // Color Palette
  final List<Color> colors = [
    const Color(0xFF576A8F),
    const Color(0xFFB7BDF7),
    const Color(0xFF628141),
    const Color(0xFFF075AE),
    const Color.fromRGBO(139, 216, 120, 1),
    const Color.fromARGB(255, 11, 163, 125),
    const Color(0xFFFFE1D2),
    const Color.fromARGB(255, 152, 196, 218),
  ];

  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    _weightController.text = weight.toStringAsFixed(1);
    _heightController.text = height.toStringAsFixed(1);
    _calculateBMI();
    _startAutoCounting();

    final List<String> exNames = [
      "Jumping Jack",
      "Squats",
      "Leg Raises",
      "Russian Twist",
      "Roping",
      "Plank",
      "Bicycle",
      "Flutter Kicks",
      "Push-ups",
      "Clap Overhead"
    ];
    final List<String> exEmojis = [
      "🤸‍♂️",
      "🦵",
      "🦵",
      "🌀",
      "🪢",
      "🪵",
      "🚴‍♂️",
      "🦵",
      "💪",
      "👏"
    ];

    for (int i = 0; i < exNames.length; i++) {
      exercises.add(Exercise(name: exNames[i], emoji: exEmojis[i], color: colors[i % colors.length]));
    }
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    _stepTimer?.cancel();
    _exerciseTimers.forEach((key, timer) => timer?.cancel());
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
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
        if (_isRunning || _isWalking || _isSwimming) {
          weight -= 0.00001;
          _calculateBMI();
        }
        _updateCalories();
      });
    });
  }

  void _updateCalories() {
    runningCalories = runningTime * 0.12;
    walkingCalories = walkingTime * 0.05;
    swimmingCalories = swimmingTime * 0.1;
  }

  void _calculateBMI() {
    double w = double.tryParse(_weightController.text) ?? weight;
    double h = double.tryParse(_heightController.text) ?? height;
    if (w > 0 && h > 0) {
      double heightInMeters = h / 100;
      setState(() {
        bmi = w / (heightInMeters * heightInMeters);
      });
    }
  }

  String _getBMICategory() {
    if (bmi < 18.5) return "Underweight 🟦";
    if (bmi < 25) return "Normal 🟦";
    if (bmi < 30) return "Overweight 🟧";
    return "Obese 🟥";
  }

  Color _getBMIColor() {
    if (bmi < 18.5) return const Color.fromARGB(255, 11, 124, 216);
    if (bmi < 25) return const Color.fromARGB(255, 2, 114, 6);
    if (bmi < 30) return const Color.fromARGB(255, 241, 128, 185);
    return Colors.red;
  }

  void _toggleActivity(String type) {
    bool starting = false;
    setState(() {
      if (type == "Running") {
        _isRunning = !_isRunning;
        starting = _isRunning;
        if (_isRunning) _isWalking = _isSwimming = false;
      } else if (type == "Walking") {
        _isWalking = !_isWalking;
        starting = _isWalking;
        if (_isWalking) _isRunning = _isSwimming = false;
      } else if (type == "Swimming") {
        _isSwimming = !_isSwimming;
        starting = _isSwimming;
        if (_isSwimming) _isRunning = _isWalking = false;
      }
      activityHistory.add(
          "$type ${starting ? "started 🏁" : "stopped ⏹"} at ${TimeOfDay.now().format(context)}");
    });
  }

  void _toggleExercise(Exercise ex) {
    bool starting = false;
    if (_exerciseTimers[ex.name] != null) {
      _exerciseTimers[ex.name]?.cancel();
      _exerciseTimers[ex.name] = null;
      activityHistory.add("${ex.name} stopped ⏹ at ${TimeOfDay.now().format(context)}");
    } else {
      starting = true;
      _exerciseTimers[ex.name] =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          ex.time++;
        });
      });
      activityHistory.add("${ex.name} started 🏁 at ${TimeOfDay.now().format(context)}");
    }
  }

  void _addWater([int amount = 500]) {
    setState(() {
      waterIntake += amount;
      if (waterIntake > waterGoal) waterIntake = waterGoal;
    });
  }

  void _resetAll() {
    setState(() {
      _isRunning = _isWalking = _isSwimming = false;
      runningKm = 0.0;
      totalSteps = 0;
      walkingTime = 0;
      runningTime = 0;
      swimmingTime = 0;
      runningCalories = 0;
      walkingCalories = 0;
      swimmingCalories = 0;
      weight = 70.0;
      height = 175.0;
      _weightController.text = weight.toStringAsFixed(1);
      _heightController.text = height.toStringAsFixed(1);
      _calculateBMI();
      waterIntake = 0;
      exercises.forEach((ex) => ex.time = 0);
      _exerciseTimers.forEach((key, timer) => timer?.cancel());
      _exerciseTimers.clear();
      activityHistory.clear();
    });
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor:Color.fromARGB(212, 212, 208, 208),
        appBar: AppBar(
          title: const Text("🏃‍♂️ Live Fitness Tracker"),
          backgroundColor: colors[4],
          actions: [
            IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => setState(() => isDarkMode = !isDarkMode)),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => AuthService().logout(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Live Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActivityButton("Running", runningKm.toStringAsFixed(2), _isRunning, Colors.black),
                  const SizedBox(width: 8),
                  _buildActivityButton("Walking", totalSteps.toString(), _isWalking, const Color.fromARGB(255, 74, 8, 187)),
                  const SizedBox(width: 8),
                  _buildActivityButton("Swimming", _formatTime(swimmingTime), _isSwimming, const Color.fromARGB(255, 228, 3, 228)),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard("Steps", "$totalSteps", "Goal: $stepGoal", colors[7], Icons.directions_walk),
                  _buildStatCard("Running", "${runningKm.toStringAsFixed(2)} km", _formatTime(runningTime), colors[2], Icons.directions_run),
                  _buildStatCard("Walking", _formatTime(walkingTime), "${walkingCalories.toStringAsFixed(1)} kcal", colors[3], Icons.timer),
                  _buildStatCard("Swimming", _formatTime(swimmingTime), "${swimmingCalories.toStringAsFixed(1)} kcal", colors[5], Icons.pool),
                ],
              ),
              const SizedBox(height: 20),
              _buildBMICard(),
              const SizedBox(height: 20),
              _buildWaterIntakeCard(),
              const SizedBox(height: 20),
              _buildActivityHistory(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _resetAll,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  "Reset All",
               style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)), // <-- text color
              ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors[2],
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              ...exercises.map(_buildExerciseCard).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton(String label, String value, bool isActive, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _toggleActivity(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : Colors.white,
          foregroundColor: isActive ? Colors.white : color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: const Color.fromARGB(255, 5, 5, 5)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 255, 255, 255))),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    return Card(
      color: Color.fromARGB(255, 193, 169, 216),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder(), filled: true, fillColor: Color.fromARGB(255, 100, 163, 159)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder(), filled: true, fillColor: Color.fromARGB(255, 100, 163, 159)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(backgroundColor: colors[0], minimumSize: const Size(double.infinity, 48)),
              child: const Text("Calculate BMI", style: TextStyle(color: Colors.white)),
            ),
            if (bmi > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("BMI: ${bmi.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 15, 15, 15))),
                    Text(_getBMICategory(), style: TextStyle(fontWeight: FontWeight.bold, color: _getBMIColor())),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    double progress = waterIntake / waterGoal;
    return Card(
      color: colors[1],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.water_drop, color: Colors.white),
              const SizedBox(width: 8),
              const Text("Water Intake", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(250, 8, 8, 8))),
              const Spacer(),
              Text("$waterIntake/$waterGoal ml", style: const TextStyle(color: Color.fromARGB(255, 239, 241, 239), fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: const Color.fromARGB(255, 255, 255, 255), color: Colors.blueAccent),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _addWater(250), child: const Text("+250ml")),
                ElevatedButton(onPressed: () => _addWater(500), child: const Text("+500ml")),
                ElevatedButton(onPressed: () => _addWater(1000), child: const Text("+1000ml")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHistory() {
    return _buildCard("📝 Activity History", activityHistory.map((a) => ListTile(leading: const Icon(Icons.history, size: 20), title: Text(a))).toList());
  }

  Widget _buildExerciseCard(Exercise ex) {
    bool isActive = _exerciseTimers[ex.name] != null;
    double progress = ex.time / 300;
    if (progress > 1) progress = 1;

    return Card(
      color: ex.color.withOpacity(0.8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color.fromARGB(255, 0, 0, 0), child: Text(ex.emoji)),
        title: Text(ex.name, style: TextStyle(color: const Color.fromARGB(255, 253, 253, 253), fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time: ${_formatTime(ex.time)}", style: const TextStyle(color: Color.fromARGB(255, 128, 10, 240))),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress, color: const Color.fromARGB(255, 253, 205, 255), backgroundColor: Colors.black26, minHeight: 4),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _toggleExercise(ex),
          style: ElevatedButton.styleFrom(backgroundColor: isActive ? const Color.fromARGB(255, 76, 221, 107) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: Text(isActive ? "PAUSE" : "START", style: TextStyle(color: isActive ? const Color.fromARGB(255, 207, 45, 34) : ex.color)),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> content) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        color: colors[6],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 245, 30, 30))),
              ...content,
            ],
          ),
        ),
      ),
    );
  }
}
