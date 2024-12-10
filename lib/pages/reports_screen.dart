import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
 @override
Widget build(BuildContext context) {
  // Check if the current screen can pop (i.e., if it was navigated to from another screen)
  bool canPop = Navigator.of(context).canPop();

  return Scaffold(
    backgroundColor: Colors.grey[300],
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header section with conditional back button
            if (canPop) // Only show back button if can pop (i.e., navigated from Profile)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Pop the screen if the back button is clicked
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Reports Overview', // Title
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            else
              // If not navigated from Profile, just show the title without the back button
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Reports Overview', // Title without back button
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Properties Overview section
            _buildSectionTitle(context, 'Properties Overview', Icons.home),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  PropertySummaryCard(label: 'Total Units', value: '12'),
                  SizedBox(width: 8),
                  PropertySummaryCard(label: 'Rented Units', value: '9'),
                  SizedBox(width: 8),
                  PropertySummaryCard(label: 'Vacant Units', value: '3'),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Earnings section
            _buildSectionTitle(context, 'Earnings Summary', Icons.money),
            SizedBox(height: 8),
            EarningsCard(totalEarnings: '2000', lastMonthEarnings: '1500'),

            SizedBox(height: 16),

            // Bills and Expenses section
            _buildSectionTitle(context, 'Bills and Expenses', Icons.attach_money),
            SizedBox(height: 8),
            BillsSummaryCard(totalBills: '800', utilities: '250', maintenance: '150'),

            SizedBox(height: 16),

            // Upcoming Payments/Reminders section
            _buildSectionTitle(context, 'Upcoming Payments', Icons.calendar_today),
            SizedBox(height: 8),
            UpcomingPaymentsCard(),

            SizedBox(height: 16),

            // Earnings vs Expenses Chart section
            _buildSectionTitle(context, 'Earnings vs Expenses \n(Last 6 months)', Icons.show_chart),
            SizedBox(height: 8),
            EarningsExpensesChart(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 30),
        SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 22,
              ),
        ),
      ],
    );
  }
}

class UpcomingPaymentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.lightBlue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Rent Payment',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              'Rent Due: 15th December 2024',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            Text(
              'Next Maintenance Fee',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              'Due: 1st January 2025',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertySummaryCard extends StatelessWidget {
  final String label;
  final String value;

  PropertySummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blueGrey[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black87)),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsCard extends StatelessWidget {
  final String totalEarnings;
  final String lastMonthEarnings;

  EarningsCard({required this.totalEarnings, required this.lastMonthEarnings});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Earnings',
                style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 8),
            Text('Kshs. ${int.parse(totalEarnings).toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.green)),
            SizedBox(height: 16),
            Text('Last Month Earnings',
                style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 8),
            Text('Kshs. ${int.parse(lastMonthEarnings).toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class BillsSummaryCard extends StatelessWidget {
  final String totalBills;
  final String utilities;
  final String maintenance;

  BillsSummaryCard(
      {required this.totalBills,
      required this.utilities,
      required this.maintenance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.pink[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Bills', style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 8),
            Text('Kshs. ${int.parse(totalBills).toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.pink)),
            SizedBox(height: 16),
            Text('Utilities', style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 8),
            Text('Kshs. ${int.parse(utilities).toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.pink)),
            SizedBox(height: 16),
            Text('Maintenance', style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 8),
            Text('Kshs. ${int.parse(maintenance).toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.pink)),
          ],
        ),
      ),
    );
  }
}

class EarningsExpensesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, 1500),
                    FlSpot(1, 1700),
                    FlSpot(2, 1600),
                    FlSpot(3, 1800),
                    FlSpot(4, 2000),
                    FlSpot(5, 1900),
                  ],
                  isCurved: true,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: [
                    FlSpot(0, 1200),
                    FlSpot(1, 1400),
                    FlSpot(2, 1300),
                    FlSpot(3, 1400),
                    FlSpot(4, 1500),
                    FlSpot(5, 1400),
                  ],
                  isCurved: true,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
