import 'package:flutter/material.dart';

/// Breakpoints para diseño responsive
class Breakpoints {
  // Tamaños de pantalla
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  
  // Helpers para determinar el tipo de dispositivo
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
  
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;
  
  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
  
  // Helpers para orientación
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;
  
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}

/// Enum para tipos de dispositivo
enum DeviceType { mobile, tablet, desktop }

/// Clase para obtener información del dispositivo
class ResponsiveInfo {
  final BuildContext context;
  
  ResponsiveInfo(this.context);
  
  DeviceType get deviceType {
    if (Breakpoints.isMobile(context)) return DeviceType.mobile;
    if (Breakpoints.isTablet(context)) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  
  bool get isPortrait => Breakpoints.isPortrait(context);
  bool get isLandscape => Breakpoints.isLandscape(context);
  
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  
  /// Obtiene un valor según el tipo de dispositivo
  T valueByDevice<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
  
  /// Obtiene padding adaptativo
  EdgeInsets get adaptivePadding {
    return valueByDevice(
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }
  
  /// Obtiene espaciado adaptativo
  double get adaptiveSpacing {
    return valueByDevice(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }
  
  /// Obtiene valor numérico de padding adaptativo
  double get paddingValue {
    return valueByDevice(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }
  
  /// Obtiene tamaño de fuente adaptativo
  double fontSizeFor(double baseSize) {
    return valueByDevice(
      mobile: baseSize * 0.9,
      tablet: baseSize,
      desktop: baseSize * 1.1,
    );
  }
  
  /// Obtiene tamaño de íconos adaptativo
  double iconSizeFor(double baseSize) {
    return valueByDevice(
      mobile: baseSize * 0.85,
      tablet: baseSize,
      desktop: baseSize * 1.15,
    );
  }
}

/// Widget builder responsive que proporciona información del dispositivo
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveInfo(context));
  }
}

/// Layout responsive que muestra diferentes widgets según el dispositivo
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    final info = ResponsiveInfo(context);
    
    return info.valueByDevice(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Widget que cambia entre columna y fila según el espacio disponible
class AdaptiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double breakpoint;
  
  const AdaptiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.breakpoint = Breakpoints.mobile,
  });
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < breakpoint) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// Proporciona tamaños de texto adaptativos
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double scaleFactor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.scaleFactor = 1.0,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final info = ResponsiveInfo(context);
    final baseSize = style?.fontSize ?? 14.0;
    final adaptiveSize = info.fontSizeFor(baseSize) * scaleFactor;
    
    return Text(
      text,
      style: style?.copyWith(fontSize: adaptiveSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Grid adaptativo que ajusta el número de columnas según el ancho
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });
  
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return 1;
    if (width < Breakpoints.tablet) return 2;
    if (width < Breakpoints.desktop) return 3;
    return 4;
  }
  
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      children: children,
    );
  }
}
