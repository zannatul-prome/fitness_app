import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Timer for automatic updates
  Timer? _activityTimer;
  Timer? _stepTimer;
  
  // Fitness Data - These will auto-increment
  double runningKm = 0.0;
  int totalSteps = 0;
  int walkingTime = 0; // seconds
  int runningTime = 0; // seconds
  int swimmingTime = 0; // seconds
  double bmi = 22.5;
  double weight = 70.0; // kg
  double height = 175.0; // cm
  int waterIntake = 0; // ml
  int waterGoal = 2500; // ml
  
  // Activity tracking
  bool _isRunning = false;
  bool _isWalking = false;
  bool _isSwimming = false;
  
  // BMI Calculation
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startAutoCounting();
    // Initialize text controllers with current values
    _weightController.text = weight.toStringAsFixed(1);
    _heightController.text = height.toStringAsFixed(1);
    _calculateBMI(); // Initial BMI calculation
  }

  @override
  void dispose() {
    _stopAllTimers();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    // BMI = weight(kg) / (height(m) * height(m))
    double heightInMeters = height / 100;
    setState(() {
      bmi = weight / (heightInMeters * heightInMeters);
    });
  }

  void _startAutoCounting() {
    // Simulate step counting (every 2 seconds)
    _stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRunning || _isWalking) {
        setState(() {
          totalSteps += _isRunning ? 3 : 2; // More steps when running
          if (_isRunning) {
            runningKm += 0.003; // Approx 3 meters per step
          }
        });
      }
    });

    // Simulate time counting for activities
    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) runningTime++;
        if (_isWalking) walkingTime++;
        if (_isSwimming) swimmingTime++;
        
        // Auto-calculate BMI based on simulated weight loss
        if (_isRunning || _isWalking || _isSwimming) {
          weight -= 0.00001; // Tiny weight loss during activity
          _calculateBMI();
        }
      });
    });
  }

  void _stopAllTimers() {
    _activityTimer?.cancel();
    _stepTimer?.cancel();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getBMICategory() {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
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
        title: const Text("BMI Calculator"),
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
                
                if (newWeight != null && newWeight > 0 && 
                    newHeight != null && newHeight > 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏃‍♂️ Live Fitness Tracker"),
        backgroundColor: const Color.fromARGB(255, 255, 146, 255),
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
            // Live Activity Buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                children: [
                  const Text(
                    "Start Activity (Auto-counts when active)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActivityButton("Running", Icons.directions_run, const Color.fromARGB(255, 243, 4, 163), _isRunning, () {
                        setState(() => _isRunning = !_isRunning);
                      }),
                      _buildActivityButton("Walking", Icons.directions_walk, const Color.fromARGB(255, 136, 11, 219), _isWalking, () {
                        setState(() => _isWalking = !_isWalking);
                      }),
                      _buildActivityButton("Swimming", Icons.pool, const Color.fromARGB(255, 2, 100, 79), _isSwimming, () {
                        setState(() => _isSwimming = !_isSwimming);
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // BMI Calculator Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calculate, color: Color.fromARGB(255, 78, 3, 197), size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "BMI Calculator",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: _showBMICalculator,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // Current BMI Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getBMIColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _getBMIColor()),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Your BMI",
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _getBMIColor(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getBMICategory(),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getBMIColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Current Weight & Height
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoTile("Weight", "${weight.toStringAsFixed(1)} kg", Icons.scale),
                          _buildInfoTile("Height", "${height.toStringAsFixed(1)} cm", Icons.height),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // BMI Scale
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BMI Categories:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildBMIRange("Underweight", "< 18.5", const Color.fromARGB(255, 5, 107, 190)),
                              _buildBMIRange("Normal", "18.5 - 24.9", const Color.fromARGB(255, 6, 122, 10)),
                              _buildBMIRange("Overweight", "25 - 29.9", const Color.fromARGB(255, 218, 85, 9)),
                              _buildBMIRange("Obese", "≥ 30", const Color.fromARGB(255, 228, 4, 116)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Dashboard Card
            _buildCard(
              "📊 Dashboard Overview",
              [
                _buildStatRow("Total Steps", "$totalSteps", Icons.directions_walk),
                _buildStatRow("Running Distance", "${runningKm.toStringAsFixed(2)} km", Icons.directions_run),
                _buildStatRow("Current Weight", "${weight.toStringAsFixed(1)} kg", Icons.scale),
                _buildStatRow("Current Height", "${height.toStringAsFixed(1)} cm", Icons.height),
              ],
            ),

            // Activity Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildActivityCard(
                    "Running Activity",
                    Icons.directions_run,
                    runningTime,
                    runningKm,
                    const Color.fromARGB(255, 62, 11, 180),
                  ),
                  const SizedBox(height: 10),
                  _buildActivityCard(
                    "Walking Activity",
                    Icons.directions_walk,
                    walkingTime,
                    totalSteps / 1300, // Convert steps to approximate km
                    const Color.fromARGB(255, 207, 0, 214),
                  ),
                  const SizedBox(height: 10),
                  _buildActivityCard(
                    "Swimming Activity",
                    Icons.pool,
                    swimmingTime,
                    0.5 * (swimmingTime / 60), // Approx 0.5 km per 60 min
                    const Color.fromARGB(255, 29, 209, 191),
                  ),
                ],
              ),
            ),

            // Water Tracker Card
            _buildCard(
              "💧 Water Intake",
              [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$waterIntake/$waterGoal ml",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 68, 6, 184),
                          ),
                        ),
                        Text(
                          "${(waterIntake / waterGoal * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 119, 8, 153),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: waterIntake / waterGoal,
                      backgroundColor: const Color.fromARGB(255, 255, 177, 177),
                      color: const Color.fromARGB(255, 159, 0, 207),
                      minHeight: 15,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWaterButton(250),
                        _buildWaterButton(500),
                        _buildWaterButton(1000),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Stats Card
            _buildCard(
              "📈 Live Statistics",
              [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildLiveStatTile("Walking Time", _formatTime(walkingTime), Icons.timer, Colors.blue),
                    _buildLiveStatTile("Running Time", _formatTime(runningTime), Icons.timer, Colors.green),
                    _buildLiveStatTile("Swim Time", _formatTime(swimmingTime), Icons.timer, Colors.teal),
                    _buildLiveStatTile("Total Time", _formatTime(walkingTime + runningTime + swimmingTime), Icons.timer, Colors.purple),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "bmi",
            onPressed: _showBMICalculator,
            backgroundColor: const Color.fromARGB(255, 225, 138, 252),
            mini: true,
            child: const Icon(Icons.calculate),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "water",
            onPressed: _addWater,
            backgroundColor: const Color.fromARGB(255, 207, 178, 224),
            icon: const Icon(Icons.water_drop),
            label: const Text("Add Water"),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> content) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              ...content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBMIRange(String label, String range, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            range,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, IconData icon, int time, double distance, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Time: ${_formatTime(time)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Distance: ${distance.toStringAsFixed(2)} km",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (title.contains("Running") && _isRunning) || 
                       (title.contains("Walking") && _isWalking) || 
                       (title.contains("Swimming") && _isSwimming)
                    ? color
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                (title.contains("Running") && _isRunning) || 
                (title.contains("Walking") && _isWalking) || 
                (title.contains("Swimming") && _isSwimming)
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityButton(String label, IconData icon, Color color, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : Colors.grey[200],
        foregroundColor: isActive ? Colors.white : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(int amount) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          waterIntake += amount;
          if (waterIntake > waterGoal) waterIntake = waterGoal;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: const Color.fromARGB(255, 219, 18, 112),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text("+${amount}ml"),
    );
  }

  void _addWater() {
    setState(() {
      waterIntake += 500;
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
              });
              Navigator.pop(context);
            },
            child: const Text("Reset", style: TextStyle(color: Color.fromARGB(255, 124, 216, 63))),
          ),
        ],
      ),
    );
  }
}