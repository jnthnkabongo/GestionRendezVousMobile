import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/planning.dart';
import 'package:frontend/pages/rendez_vous.dart';
import 'package:frontend/pages/visites.dart';
import 'package:frontend/pages/parametres.dart';

class HomeWithBottomNav extends StatefulWidget {
  const HomeWithBottomNav({super.key});

  @override
  State<HomeWithBottomNav> createState() => _HomeWithBottomNavState();
}

class _HomeWithBottomNavState extends State<HomeWithBottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Dashboard(),
    const Planning(),
    const RendezVous(),
    const Visites(),
    const Parametres(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Accueil',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_view_month_outlined,
                  selectedIcon: Icons.calendar_view_month,
                  label: 'Planing',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                  label: 'Rendez-vous',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_pin_outlined,
                  selectedIcon: Icons.person_pin,
                  label: 'Visites',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Paramètres',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC9A227).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected ? selectedIcon : icon),
                color: isSelected
                    ? const Color(0xFFC9A227)
                    : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFC9A227)
                    : Colors.grey.shade600,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}