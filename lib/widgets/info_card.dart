import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final String setpointValue;
  final IconData? icon; // Optional icon

  const InfoCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.setpointValue,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Use theme card color or specific color
      color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, // Use elevation 0 as per the design
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Icon(icon, color: theme.hintColor, size: 20),
                  ),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Setpoint: $setpointValue',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            Text(
              currentValue,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
} 