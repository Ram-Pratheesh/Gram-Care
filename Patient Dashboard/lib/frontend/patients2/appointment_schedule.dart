import 'package:flutter/material.dart';

void main() {
  runApp(const AppointmentSchedulePage());
}

class AppointmentSchedulePage extends StatefulWidget {
  const AppointmentSchedulePage({super.key});

  @override
  State<AppointmentSchedulePage> createState() =>
      _AppointmentSchedulePageState();
}

class _AppointmentSchedulePageState extends State<AppointmentSchedulePage> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;

  final List<DateTime> dates = List.generate(
    7,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  final List<String> times = [
    "08:00 AM",
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "01:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
  ];

  String formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return "${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Book an Appointment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---- Date Selection ----
            const Text(
              "Select Appointment Date",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedDateIndex;
                  DateTime date = dates[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedDateIndex = index);
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formatDate(date).split(",")[1].trim().split(" ")[1],
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            formatDate(date).split(",")[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// ---- Time Selection ----
            const Text(
              "Select Appointment Time",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(times.length, (index) {
                bool isSelected = index == selectedTimeIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedTimeIndex = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      times[index],
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            /// ---- Confirm Button ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                onPressed:
                    selectedTimeIndex == -1
                        ? null
                        : () {
                          Navigator.pushNamed(
                            context,
                            '/confirmation',
                            arguments: {
                              "date": formatDate(dates[selectedDateIndex]),
                              "time": times[selectedTimeIndex],
                            },
                          );
                        },
                child: const Text(
                  "Confirm Appointment",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
