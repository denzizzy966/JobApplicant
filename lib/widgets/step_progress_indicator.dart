// lib/widgets/step_progress_indicator.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum ApplicationStep {
  details('Details'),
  education('Education'),
  workHistory('Work History'),
  review('Review');

  final String label;
  const ApplicationStep(this.label);
}

class StepProgressIndicator extends StatelessWidget {
  final ApplicationStep currentStep;

  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ...ApplicationStep.values.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = step.index <= currentStep.index;
            final isFirst = index == 0;
            final isLast = index == ApplicationStep.values.length - 1;

            return Expanded(
              child: Row(
                children: [
                  if (!isFirst)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: Colors.white,
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.white : Colors.white.withOpacity(0.5),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.label,
                        style: TextStyle(
                          color: isCompleted ? Colors.white : Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}