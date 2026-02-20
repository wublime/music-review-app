// Run: flutter run (or flutter run -d chrome for web)
import 'package:flutter/material.dart';
import 'screens/hype_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicReviewApp());
}

ThemeData _buildHypeTheme() {
  // Matching the deep, near-black from your reference image
  const Color background = Color(0xFF0F0F10); 
  const Color surface = Color(0xFF1A1A1C); // Slightly lighter for cards/nav
  const Color accent = Color(0xFFFFB300); 
  const Color primaryText = Colors.white;
  const Color secondaryText = Color(0xFF9CA3AF); // Zinc-400 equivalent

  final colorScheme = ColorScheme.dark(
    primary: accent,
    onPrimary: Colors.black,
    secondary: accent,
    surface: surface,
    onSurface: primaryText,
    onSurfaceVariant: secondaryText,
    // Using 'surface' for background to ensure a consistent deep dark look
    background: background, 
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    // If you have a cleaner font like 'Inter' or 'Geist', swap it here. 
    // Otherwise, Roboto is fine.
    fontFamily: 'Roboto', 
    
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: primaryText,
        fontSize: 18,
        fontWeight: FontWeight.w900, // Makes the "HYPE" logo pop
        letterSpacing: 1.2,
      ),
    ),

    // We keep this for other parts of the app, 
    // but the ReleaseCard now bypasses it for a sleeker look.
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: background.withOpacity(0.8),
      selectedItemColor: accent,
      unselectedItemColor: secondaryText,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // Flat look is more modern
    ),
  );
}

class MusicReviewApp extends StatelessWidget {
  const MusicReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Clean up the UI
      title: 'Hype Music',
      theme: _buildHypeTheme(),
      home: const HypeDashboard(),
    );
  }
}