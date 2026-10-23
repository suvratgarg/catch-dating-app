import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// SDK constructors that own pixels or interaction feedback (D18 / CAT-227).
/// Icon and Tooltip are inventoried now but stay dormant until CAT-226 ships.
const drawingMigrationKinds = <String>{
  'AnimatedContainer',
  'Container',
  'DecoratedBox',
  'ColoredBox',
  'Material',
  'Ink',
  'InkWell',
  'InkResponse',
  'GestureDetector',
  'Card',
  'ClipRect',
  'ClipRRect',
  'ClipRSuperellipse',
  'ClipOval',
  'ClipPath',
  'CustomPaint',
  'Opacity',
  'ShaderMask',
  'BackdropFilter',
  'Image',
  'CircleAvatar',
  'Divider',
  'VerticalDivider',
  'BoxDecoration',
  'ShapeDecoration',
  'BorderRadius',
  'BorderRadiusDirectional',
  'Radius',
  'Border',
  'BorderDirectional',
  'BorderSide',
  'RoundedRectangleBorder',
  'RoundedSuperellipseBorder',
  'BeveledRectangleBorder',
  'ContinuousRectangleBorder',
  'CircleBorder',
  'OvalBorder',
  'StadiumBorder',
  'StarBorder',
  'LinearBorder',
  'OutlineInputBorder',
  'UnderlineInputBorder',
  'LinearGradient',
  'RadialGradient',
  'SweepGradient',
  'Icon',
  'Tooltip',
};

const unavailableDrawingKinds = <String>{'Icon', 'Tooltip'};
final activeDrawingKinds = drawingMigrationKinds.difference(
  unavailableDrawingKinds,
);

typedef DrawingMigrationSite = ({InstanceCreationExpression node, String kind});

/// Resolved identities exclude similarly named app/third-party constructors.
List<DrawingMigrationSite> drawingMigrationSites(
  CompilationUnit unit,
  Set<String>? kinds,
) {
  final visitor = _DrawingCalls(kinds);
  unit.accept(visitor);
  return visitor.sites;
}

class _DrawingCalls extends RecursiveAstVisitor<void> {
  _DrawingCalls(this.kinds);
  final Set<String>? kinds;
  final sites = <DrawingMigrationSite>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    final constructor = node.constructorName.element?.baseElement;
    final kind = constructor?.enclosingElement.name;
    final uri = constructor?.library.uri.toString();
    if (kind == null ||
        !drawingMigrationKinds.contains(kind) ||
        (kinds != null && !kinds!.contains(kind)) ||
        uri == null ||
        !(uri.startsWith('package:flutter/') || uri == 'dart:ui')) {
      return;
    }
    sites.add((node: node, kind: kind));
  }
}
