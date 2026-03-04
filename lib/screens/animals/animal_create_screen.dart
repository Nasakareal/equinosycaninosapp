import 'package:flutter/material.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';

class AnimalCreateScreen extends StatelessWidget {
  const AnimalCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x24FFFFFF)),
                            color: const Color(0x0AFFFFFF),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFFF3F7FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Agregar animal',
                          style: TextStyle(
                            color: Color(0xFFF3F7FF),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Aquí va el formulario para crear un animal.\nLo haremos igual que en web, validado y bonito.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xB6FFFFFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.6,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
