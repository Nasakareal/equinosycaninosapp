import 'package:flutter/material.dart';
import 'glass.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback openLeft;
  final VoidCallback openRight;

  const HomeAppBar({
    super.key,
    required this.openLeft,
    required this.openRight,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _IconTile(icon: Icons.menu_rounded, onTap: openLeft),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x2EFFFFFF)),
              gradient: const LinearGradient(
                colors: [Color(0x3D00E5FF), Color(0x3D7C4DFF)],
              ),
            ),
            child: Image.asset('assets/images/escudo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unidad Canina y Equina',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF3F7FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 15.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Panel operativo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0x88FFFFFF),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.2,
                  ),
                ),
              ],
            ),
          ),
          _IconTile(icon: Icons.account_circle_rounded, onTap: openRight),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconTile({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
        child: Icon(icon, color: const Color(0xFFF3F7FF)),
      ),
    );
  }
}
