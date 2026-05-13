import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/filters/detail/views/filter_detail_view.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';

void main() {
  setUpAll(() {
    AppConfig.initialize();
  });

  final testDetail = FilterDetail(
    id: '1',
    imageUrl: 'http://example.com/image.png',
    impurityCount: 10,
    metal: 2,
    other: 8,
    firstEffect: 5,
    secondAndThirdEffect: 3,
    fourthEffect: 1,
    fifthEffect: 1,
    quality: 85,
    processedAt: DateTime(2024, 5, 13),
  );

  testWidgets('FilterDetailView displays all info correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FilterDetailView(detail: testDetail),
      ),
    );

    expect(find.text('Detalle del Filtro'), findsOneWidget);
    expect(find.text('Sección Efectos'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // total impurities
    expect(find.text('5'), findsOneWidget); // Primer Efecto
    expect(find.byType(Hero), findsWidgets);
  });

  testWidgets('FilterDetailView opens full screen image on tap', (tester) async {
    // Evitar errores de red en los tests al intentar cargar Image.network
    await tester.pumpWidget(
      MaterialApp(
        home: FilterDetailView(detail: testDetail),
      ),
    );

    // Buscar el GestureDetector que envuelve la imagen
    final gestureDetector = find.byType(GestureDetector);
    expect(gestureDetector, findsOneWidget);

    // Tap the image
    await tester.tap(gestureDetector);
    await tester.pumpAndSettle();

    // Verificar que se abrió la vista de pantalla completa
    expect(find.byType(InteractiveViewer), findsOneWidget);
    
    // Regresar
    await tester.pageBack();
    await tester.pumpAndSettle();
    
    expect(find.text('Detalle del Filtro'), findsOneWidget);
  });
}
