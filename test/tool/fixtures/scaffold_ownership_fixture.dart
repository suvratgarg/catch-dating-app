import 'package:flutter/material.dart' as material;

typedef MaterialScaffoldAlias = material.Scaffold;

class DirectScaffoldSubclass extends material.Scaffold {
  const DirectScaffoldSubclass({super.key})
    : super(body: const material.SizedBox());
}

class IndirectScaffoldSubclass extends DirectScaffoldSubclass {
  const IndirectScaffoldSubclass({super.key});
}

material.Widget buildPrefixedScaffold() =>
    const material.Scaffold(body: material.SizedBox());

material.Widget buildTypeAliasScaffold() =>
    const MaterialScaffoldAlias(body: material.SizedBox());

const materialScaffoldConstructor = material.Scaffold.new;

material.Widget buildConstructorAliasScaffold() =>
    materialScaffoldConstructor(body: const material.SizedBox());
