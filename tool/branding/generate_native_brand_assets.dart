import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as image;

const _tokenPath = 'design_context_pack/design_system/tokens.json';
const _baseIconPath = 'assets/branding/catch_icon.png';
const _roundIconPath = 'assets/branding/catch_icon_round.png';
const _hostIconPath = 'assets/branding/catch_hosts_icon.png';
const _hostSplashLightPath = 'assets/branding/catch_host_splash_mark_light.png';
const _hostSplashDarkPath = 'assets/branding/catch_host_splash_mark_dark.png';
const _generatedIconDir = 'assets/branding/generated';
const _consumerProjectRoot = 'apps/consumer';
const _hostProjectRoot = 'apps/host';
const _consumerLaunchScreenPath =
    'apps/consumer/ios/Runner/Base.lproj/LaunchScreen.storyboard';
const _hostLaunchScreenPath =
    'apps/host/ios/Runner/Base.lproj/LaunchScreen.storyboard';

// Host launch geometry mirrors CatchLayout.startupLogoExtent and
// CatchLayout.startupLogoTopInset. The same transparent mark canvas is then
// painted at the same safe-area anchor by the native launch screen, Flutter
// startup surface, and Host auth surface.
const _hostLaunchImageExtent = 96;
const _hostLaunchImageTopInset = 8;

// Consumer LaunchImage is a 256pt transparent square. Its generated Catch_
// alpha bounds begin at x=42/y=102. These geometry values mirror the Welcome
// reel's 320pt contract in CatchLayout without changing the Host launch screen.
const _consumerLaunchSourceExtent = 256;
const _consumerLaunchImageExtent = 138;
const _consumerLaunchMarkAlphaLeft = 42;
const _consumerLaunchMarkAlphaTop = 102;
const _consumerWelcomeMaxWidth = 430;
const _consumerWelcomeCatchLeft = 24;
const _consumerWelcomeReelTop = 50;
const _consumerWelcomeCatchFocusTop = 199;
const _consumerWelcomeCatchGlyphTopOffset = 4;
const _consumerWelcomeSafeTopGap = 4;

const _androidIconSizes = <String, int>{
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const _androidSplashSizes = <String, int>{
  'drawable-mdpi': 256,
  'drawable-hdpi': 384,
  'drawable-xhdpi': 512,
  'drawable-xxhdpi': 768,
  'drawable-xxxhdpi': 1024,
};

const _iosSplashSizes = <String, int>{'': 256, '@2x': 512, '@3x': 768};

const _iconVariants = <String, _IconVariant>{
  'dev': _IconVariant(
    generatedName: 'catch_icon_dev.png',
    androidSourceSet: 'consumerDev',
    appleIconSet: 'AppIcon-dev',
    filenamePrefix: 'dev',
    ribbons: [_IconRibbon(label: 'DEV', fillToken: 'bg', labelToken: 'ink')],
  ),
  'staging': _IconVariant(
    generatedName: 'catch_icon_staging.png',
    androidSourceSet: 'consumerStaging',
    appleIconSet: 'AppIcon-staging',
    filenamePrefix: 'staging',
    ribbons: [
      _IconRibbon(label: 'STG', fillToken: 'warning', labelToken: 'ink'),
    ],
  ),
  'host-dev': _IconVariant(
    generatedName: 'catch_icon_host_dev.png',
    androidSourceSet: 'hostDev',
    appleIconSet: 'AppIcon-host-dev',
    filenamePrefix: 'host-dev',
    iconBase: _IconBase.host,
    ribbons: [_IconRibbon(label: 'DEV', fillToken: 'bg', labelToken: 'ink')],
  ),
  'host-staging': _IconVariant(
    generatedName: 'catch_icon_host_staging.png',
    androidSourceSet: 'hostStaging',
    appleIconSet: 'AppIcon-host-staging',
    filenamePrefix: 'host-staging',
    iconBase: _IconBase.host,
    ribbons: [
      _IconRibbon(label: 'STG', fillToken: 'warning', labelToken: 'ink'),
    ],
  ),
  'host-prod': _IconVariant(
    generatedName: 'catch_icon_host_prod.png',
    androidSourceSet: 'hostProd',
    appleIconSet: 'AppIcon-host-prod',
    filenamePrefix: 'host-prod',
    iconBase: _IconBase.host,
    ribbons: [],
  ),
};

void main() {
  final tokens = _NativeBrandTokens.load();
  final baseIcon = image.decodePng(File(_baseIconPath).readAsBytesSync());
  if (baseIcon == null) {
    throw StateError('Could not decode $_baseIconPath.');
  }
  final roundIcon = image.decodePng(File(_roundIconPath).readAsBytesSync());
  if (roundIcon == null) {
    throw StateError('Could not decode $_roundIconPath.');
  }
  final hostIcon = image.decodePng(File(_hostIconPath).readAsBytesSync());
  if (hostIcon == null) {
    throw StateError('Could not decode $_hostIconPath.');
  }
  final hostSplashLight = image.decodePng(
    File(_hostSplashLightPath).readAsBytesSync(),
  );
  if (hostSplashLight == null) {
    throw StateError('Could not decode $_hostSplashLightPath.');
  }
  final hostSplashDark = image.decodePng(
    File(_hostSplashDarkPath).readAsBytesSync(),
  );
  if (hostSplashDark == null) {
    throw StateError('Could not decode $_hostSplashDarkPath.');
  }

  _syncPubspecTokens(tokens);
  _writeNativeBrandManifest(tokens);
  _writeConsumerProductionAndroidIcons(baseIcon, roundIcon);
  _writeConsumerProductionIosIconSet(baseIcon);
  _writeConsumerLaunchScreen();
  _writeHostSplashAssets(hostSplashLight, hostSplashDark);
  _writeHostLaunchScreen();

  for (final entry in _iconVariants.entries) {
    final variant = entry.value;
    final sourceIcon = switch (variant.iconBase) {
      _IconBase.consumer => baseIcon,
      _IconBase.host => hostIcon,
    };
    final icon = _buildVariantIcon(sourceIcon, variant, tokens);
    final generatedSourcePath = '$_generatedIconDir/${variant.generatedName}';
    _writePng(generatedSourcePath, icon);
    _writeAndroidIcons(variant.androidSourceSet, icon);
    _writeIosIconSet(variant, icon);
    _writeMacosIconSet(variant, icon);
    if (variant.iconBase == _IconBase.consumer) {
      _writeAndroidIcons(
        variant.androidSourceSet,
        icon,
        projectRoot: _consumerProjectRoot,
      );
      _writeIosIconSet(variant, icon, projectRoot: _consumerProjectRoot);
    } else {
      _writeAndroidIcons(
        variant.androidSourceSet,
        icon,
        projectRoot: _hostProjectRoot,
      );
      _writeIosIconSet(variant, icon, projectRoot: _hostProjectRoot);
    }
  }

  _verifyPubspecTokens(tokens);
  stdout.writeln('Generated native flavor brand assets from $_tokenPath.');
}

image.Image _buildVariantIcon(
  image.Image baseIcon,
  _IconVariant variant,
  _NativeBrandTokens tokens,
) {
  final icon = baseIcon.convert(numChannels: 4);
  for (final ribbon in variant.ribbons) {
    _drawRibbon(icon, ribbon, tokens);
  }
  return icon;
}

void _drawRibbon(
  image.Image icon,
  _IconRibbon ribbon,
  _NativeBrandTokens tokens,
) {
  final ribbonFill = tokens.color(ribbon.fillToken, 'light');
  final ribbonInk = tokens.color(ribbon.labelToken, 'light');
  final shadow = image.ColorRgba8(0, 0, 0, 88);
  final size = math.min(icon.width, icon.height);
  final depth = (size * 0.29).round();
  final band = (size * 0.105).round();
  final shadowOffset = (size * 0.014).round();

  image.fillPolygon(
    icon,
    vertices: _topLeftRibbonVertices(depth + shadowOffset, band),
    color: shadow,
  );
  image.fillPolygon(
    icon,
    vertices: _topLeftRibbonVertices(depth, band),
    color: ribbonFill,
  );

  final labelLayer = image.Image(width: 220, height: 72, numChannels: 4);
  labelLayer.clear(image.ColorRgba8(0, 0, 0, 0));
  image.drawString(
    labelLayer,
    ribbon.label,
    font: image.arial48,
    color: ribbonInk,
  );
  final scaledLabel = image.copyResize(
    labelLayer,
    width: (size * 0.23).round(),
    height: (size * 0.076).round(),
    interpolation: image.Interpolation.cubic,
  );
  final label = image.copyRotate(
    scaledLabel,
    angle: -45,
    interpolation: image.Interpolation.cubic,
  );
  image.compositeImage(
    icon,
    label,
    dstX: (size * 0.075).round(),
    dstY: (size * 0.035).round(),
  );
}

List<image.Point> _topLeftRibbonVertices(int depth, int band) {
  return [
    image.Point(0, depth),
    image.Point(depth),
    image.Point(depth + band),
    image.Point(0, depth + band),
  ];
}

void _writeAndroidIcons(
  String sourceSet,
  image.Image source, {
  String projectRoot = '',
}) {
  for (final entry in _androidIconSizes.entries) {
    final resized = image.copyResize(
      source,
      width: entry.value,
      height: entry.value,
      interpolation: image.Interpolation.cubic,
    );
    _writePng(
      _projectPath(
        projectRoot,
        'android/app/src/$sourceSet/res/${entry.key}/ic_launcher.png',
      ),
      resized,
    );
    _writePng(
      _projectPath(
        projectRoot,
        'android/app/src/$sourceSet/res/${entry.key}/ic_launcher_round.png',
      ),
      resized,
    );
  }
}

void _writeIosIconSet(
  _IconVariant variant,
  image.Image source, {
  String projectRoot = '',
}) {
  final opaqueSource = source.convert(numChannels: 3);
  final basePath = _projectPath(
    projectRoot,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset',
  );
  final outputPath = _projectPath(
    projectRoot,
    'ios/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset',
  );
  final contents = _readJsonMap('$basePath/Contents.json');
  final images = contents['images'] as List<dynamic>;

  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final outputFilename = filename.replaceFirst(
      'Icon-App-',
      'Icon-App-${variant.filenamePrefix}-',
    );
    item['filename'] = outputFilename;
    final pixelSize = _applePixelSize(item);
    _writePng(
      '$outputPath/$outputFilename',
      image.copyResize(
        opaqueSource,
        width: pixelSize,
        height: pixelSize,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }

  _writeJson('$outputPath/Contents.json', contents);
}

void _writeConsumerProductionAndroidIcons(
  image.Image squareIcon,
  image.Image roundIcon,
) {
  for (final entry in _androidIconSizes.entries) {
    _writePng(
      '$_consumerProjectRoot/android/app/src/main/res/${entry.key}/ic_launcher.png',
      image.copyResize(
        squareIcon,
        width: entry.value,
        height: entry.value,
        interpolation: image.Interpolation.cubic,
      ),
    );
    _writePng(
      '$_consumerProjectRoot/android/app/src/main/res/${entry.key}/ic_launcher_round.png',
      image.copyResize(
        roundIcon,
        width: entry.value,
        height: entry.value,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }
}

void _writeConsumerProductionIosIconSet(image.Image source) {
  final opaqueSource = source.convert(numChannels: 3);
  final outputPath =
      '$_consumerProjectRoot/ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final contents = _readJsonMap('$outputPath/Contents.json');
  final images = contents['images'] as List<dynamic>;
  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final pixelSize = _applePixelSize(item);
    _writePng(
      '$outputPath/$filename',
      image.copyResize(
        opaqueSource,
        width: pixelSize,
        height: pixelSize,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }
}

void _writeHostSplashAssets(image.Image light, image.Image dark) {
  final iosPath =
      '$_hostProjectRoot/ios/Runner/Assets.xcassets/LaunchImage.imageset';
  for (final entry in _iosSplashSizes.entries) {
    final suffix = entry.key;
    final size = entry.value;
    _writePng(
      '$iosPath/LaunchImage$suffix.png',
      image.copyResize(
        light,
        width: size,
        height: size,
        interpolation: image.Interpolation.cubic,
      ),
    );
    _writePng(
      '$iosPath/LaunchImageDark$suffix.png',
      image.copyResize(
        dark,
        width: size,
        height: size,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }

  for (final entry in _androidSplashSizes.entries) {
    final lightPath = '$_hostProjectRoot/android/app/src/main/res/${entry.key}';
    final darkPath =
        '$_hostProjectRoot/android/app/src/main/res/'
        '${entry.key.replaceFirst('drawable-', 'drawable-night-')}';
    final resizedLight = image.copyResize(
      light,
      width: entry.value,
      height: entry.value,
      interpolation: image.Interpolation.cubic,
    );
    final resizedDark = image.copyResize(
      dark,
      width: entry.value,
      height: entry.value,
      interpolation: image.Interpolation.cubic,
    );
    for (final filename in const ['splash.png', 'android12splash.png']) {
      _writePng('$lightPath/$filename', resizedLight);
      _writePng('$darkPath/$filename', resizedDark);
    }
  }
}

void _writeMacosIconSet(_IconVariant variant, image.Image source) {
  final basePath = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  final outputPath =
      'macos/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset';
  final contents = _readJsonMap('$basePath/Contents.json');
  final images = contents['images'] as List<dynamic>;

  for (final item in images.cast<Map<String, dynamic>>()) {
    final filename = item['filename'] as String?;
    if (filename == null) continue;
    final outputFilename = filename.replaceFirst(
      'app_icon_',
      'app_icon_${variant.filenamePrefix}_',
    );
    item['filename'] = outputFilename;
    final pixelSize = _applePixelSize(item);
    _writePng(
      '$outputPath/$outputFilename',
      image.copyResize(
        source,
        width: pixelSize,
        height: pixelSize,
        interpolation: image.Interpolation.cubic,
      ),
    );
  }

  _writeJson('$outputPath/Contents.json', contents);
}

int _applePixelSize(Map<String, dynamic> item) {
  final logicalSize = (item['size'] as String).split('x').first;
  final scale = (item['scale'] as String).replaceAll('x', '');
  return (double.parse(logicalSize) * double.parse(scale)).round();
}

void _writeConsumerLaunchScreen() {
  final imageLeading =
      _consumerWelcomeCatchLeft -
      ((_consumerLaunchMarkAlphaLeft * _consumerLaunchImageExtent) /
              _consumerLaunchSourceExtent)
          .round();
  final imageCenterOffset =
      imageLeading +
      (_consumerLaunchImageExtent ~/ 2) -
      (_consumerWelcomeMaxWidth ~/ 2);
  final scaledAlphaTop =
      ((_consumerLaunchMarkAlphaTop * _consumerLaunchImageExtent) /
              _consumerLaunchSourceExtent)
          .round();
  final imageTopWithoutTallSafeArea =
      _consumerWelcomeReelTop +
      _consumerWelcomeCatchFocusTop -
      scaledAlphaTop +
      _consumerWelcomeCatchGlyphTopOffset;
  final imageTopFromSafeArea =
      _consumerWelcomeSafeTopGap +
      _consumerWelcomeCatchFocusTop -
      scaledAlphaTop +
      _consumerWelcomeCatchGlyphTopOffset;

  final file = File(_consumerLaunchScreenPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Generated by tool/branding/generate_native_brand_assets.dart. -->
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="12121" systemVersion="16G29" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <deployment identifier="iOS"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="12089"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <layoutGuides>
                        <viewControllerLayoutGuide type="top" id="Ydg-fD-yQy"/>
                        <viewControllerLayoutGuide type="bottom" id="xbc-2k-c8Z"/>
                    </layoutGuides>
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleToFill" image="LaunchBackground" translatesAutoresizingMaskIntoConstraints="NO" id="tWc-Dq-wcI"/>
                            <imageView opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleAspectFit" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4"/>
                        </subviews>
                        <color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                        <constraints>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="leading" relation="greaterThanOrEqual" secondItem="Ze5-6b-2t3" secondAttribute="leading" constant="$imageLeading" id="1yB-uU-min"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="leading" secondItem="Ze5-6b-2t3" secondAttribute="leading" constant="$imageLeading" priority="749" id="3T2-ad-Qdv"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" constant="$imageCenterOffset" priority="750" id="6hC-xM-max"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="width" constant="$_consumerLaunchImageExtent" id="8Lw-Wd-256"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="height" constant="$_consumerLaunchImageExtent" id="9Lh-Ht-256"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="top" relation="greaterThanOrEqual" secondItem="Ze5-6b-2t3" secondAttribute="top" constant="$imageTopWithoutTallSafeArea" id="AtP-no-notch"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="top" relation="greaterThanOrEqual" secondItem="6Tk-OE-BBY" secondAttribute="top" constant="$imageTopFromSafeArea" id="BtP-safe-min"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="top" secondItem="Ze5-6b-2t3" secondAttribute="top" constant="$imageTopWithoutTallSafeArea" priority="749" id="CtP-no-pref"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="top" secondItem="6Tk-OE-BBY" secondAttribute="top" constant="$imageTopFromSafeArea" priority="750" id="DtP-safe-pref"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="bottom" secondItem="Ze5-6b-2t3" secondAttribute="bottom" id="RPx-PI-7Xg"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="top" secondItem="Ze5-6b-2t3" secondAttribute="top" id="SdS-ul-q2q"/>
                            <constraint firstAttribute="trailing" secondItem="tWc-Dq-wcI" secondAttribute="trailing" id="Swv-Gf-Rwn"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="leading" secondItem="Ze5-6b-2t3" secondAttribute="leading" id="kV7-tw-vXt"/>
                        </constraints>
                        <viewLayoutGuide key="safeArea" id="6Tk-OE-BBY"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="256" height="256"/>
        <image name="LaunchBackground" width="1" height="1"/>
    </resources>
</document>
''',
  );
}

void _writeHostLaunchScreen() {
  final file = File(_hostLaunchScreenPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Generated by tool/branding/generate_native_brand_assets.dart. -->
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="12121" systemVersion="16G29" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <deployment identifier="iOS"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="12089"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <layoutGuides>
                        <viewControllerLayoutGuide type="top" id="Ydg-fD-yQy"/>
                        <viewControllerLayoutGuide type="bottom" id="xbc-2k-c8Z"/>
                    </layoutGuides>
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleToFill" image="LaunchBackground" translatesAutoresizingMaskIntoConstraints="NO" id="tWc-Dq-wcI"/>
                            <imageView opaque="NO" clipsSubviews="YES" contentMode="scaleAspectFit" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4"/>
                        </subviews>
                        <color key="backgroundColor" red="0.956862745" green="0.956862745" blue="0.945098039" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                        <constraints>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="leading" secondItem="Ze5-6b-2t3" secondAttribute="leading" id="1Lw-Bg-Ld"/>
                            <constraint firstAttribute="trailing" secondItem="tWc-Dq-wcI" secondAttribute="trailing" id="2Lw-Bg-Tr"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="top" secondItem="Ze5-6b-2t3" secondAttribute="top" id="3Lw-Bg-Tp"/>
                            <constraint firstAttribute="bottom" secondItem="tWc-Dq-wcI" secondAttribute="bottom" id="4Lw-Bg-Bt"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="5Hs-Cx"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="top" secondItem="6Tk-OE-BBY" secondAttribute="top" constant="$_hostLaunchImageTopInset" id="6Hs-Tp"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="width" constant="$_hostLaunchImageExtent" id="7Hs-Wd"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="height" constant="$_hostLaunchImageExtent" id="8Hs-Ht"/>
                        </constraints>
                        <viewLayoutGuide key="safeArea" id="6Tk-OE-BBY"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="256" height="256"/>
        <image name="LaunchBackground" width="1" height="1"/>
    </resources>
</document>
''',
  );
}

void _writeNativeBrandManifest(_NativeBrandTokens tokens) {
  _writeJson('tool/branding/native_branding.generated.json', {
    'source': _tokenPath,
    'colors': {
      'splash_light_bg': tokens.colorHex('bg', 'light'),
      'splash_dark_bg': tokens.colorHex('bg', 'dark'),
      'web_theme': tokens.colorHex('ink', 'light'),
      'dev_ribbon': tokens.colorHex('bg', 'light'),
      'staging_ribbon': tokens.colorHex('warning', 'light'),
      'ribbon_ink': tokens.colorHex('ink', 'light'),
    },
    'generated': [
      _hostIconPath,
      _hostSplashLightPath,
      _hostSplashDarkPath,
      for (final variant in _iconVariants.values)
        'assets/branding/generated/${variant.generatedName}',
      for (final variant in _iconVariants.values)
        'android/app/src/${variant.androidSourceSet}/res/**/ic_launcher.png',
      for (final variant in _iconVariants.values)
        'android/app/src/${variant.androidSourceSet}/res/**/ic_launcher_round.png',
      for (final variant in _iconVariants.values)
        'ios/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset',
      for (final variant in _iconVariants.values)
        'macos/Runner/Assets.xcassets/${variant.appleIconSet}.appiconset',
      'apps/consumer/android/app/src/main/res/**/ic_launcher.png',
      'apps/consumer/android/app/src/main/res/**/ic_launcher_round.png',
      'apps/consumer/android/app/src/consumerDev/res/**/ic_launcher.png',
      'apps/consumer/android/app/src/consumerDev/res/**/ic_launcher_round.png',
      'apps/consumer/android/app/src/consumerStaging/res/**/ic_launcher.png',
      'apps/consumer/android/app/src/consumerStaging/res/**/ic_launcher_round.png',
      'apps/consumer/ios/Runner/Assets.xcassets/AppIcon.appiconset',
      'apps/consumer/ios/Runner/Assets.xcassets/AppIcon-dev.appiconset',
      'apps/consumer/ios/Runner/Assets.xcassets/AppIcon-staging.appiconset',
      _consumerLaunchScreenPath,
      'apps/host/android/app/src/hostDev/res/**/ic_launcher.png',
      'apps/host/android/app/src/hostDev/res/**/ic_launcher_round.png',
      'apps/host/android/app/src/hostStaging/res/**/ic_launcher.png',
      'apps/host/android/app/src/hostStaging/res/**/ic_launcher_round.png',
      'apps/host/android/app/src/hostProd/res/**/ic_launcher.png',
      'apps/host/android/app/src/hostProd/res/**/ic_launcher_round.png',
      'apps/host/android/app/src/main/res/**/splash.png',
      'apps/host/android/app/src/main/res/**/android12splash.png',
      'apps/host/ios/Runner/Assets.xcassets/AppIcon-host-dev.appiconset',
      'apps/host/ios/Runner/Assets.xcassets/AppIcon-host-staging.appiconset',
      'apps/host/ios/Runner/Assets.xcassets/AppIcon-host-prod.appiconset',
      'apps/host/ios/Runner/Assets.xcassets/LaunchImage.imageset',
      _hostLaunchScreenPath,
    ],
  });
}

String _projectPath(String projectRoot, String relativePath) {
  return projectRoot.isEmpty ? relativePath : '$projectRoot/$relativePath';
}

void _syncPubspecTokens(_NativeBrandTokens tokens) {
  final file = File('pubspec.yaml');
  final webTheme = tokens.colorHex('ink', 'light');
  final splashLight = tokens.colorHex('bg', 'light');
  final splashDark = tokens.colorHex('bg', 'dark');
  var pubspec = file.readAsStringSync();

  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    background_color: .+$', multiLine: true),
    '    background_color: "$webTheme"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    theme_color: .+$', multiLine: true),
    '    theme_color: "$webTheme"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color: .+$', multiLine: true),
    '  color: "$splashLight"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color_web: .+$', multiLine: true),
    '  color_web: "$splashLight"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color_dark: .+$', multiLine: true),
    '  color_dark: "$splashDark"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^  color_dark_web: .+$', multiLine: true),
    '  color_dark_web: "$splashDark"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    color: .+$', multiLine: true),
    '    color: "$splashLight"',
  );
  pubspec = _replaceRequiredLine(
    pubspec,
    RegExp(r'^    color_dark: .+$', multiLine: true),
    '    color_dark: "$splashDark"',
  );

  file.writeAsStringSync(pubspec);
}

String _replaceRequiredLine(String source, RegExp pattern, String replacement) {
  final matches = pattern.allMatches(source).length;
  if (matches != 1) {
    throw StateError(
      'Expected one pubspec.yaml match for ${pattern.pattern}, found $matches.',
    );
  }
  return source.replaceAll(pattern, replacement);
}

void _verifyPubspecTokens(_NativeBrandTokens tokens) {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final expected = <String>[
    "background_color: \"${tokens.colorHex('ink', 'light')}\"",
    "theme_color: \"${tokens.colorHex('ink', 'light')}\"",
    "color: \"${tokens.colorHex('bg', 'light')}\"",
    "color_web: \"${tokens.colorHex('bg', 'light')}\"",
    "color_dark: \"${tokens.colorHex('bg', 'dark')}\"",
    "color_dark_web: \"${tokens.colorHex('bg', 'dark')}\"",
  ];
  final missing = expected.where((line) => !pubspec.contains(line)).toList();
  if (missing.isNotEmpty) {
    throw StateError(
      'pubspec.yaml is not aligned with $_tokenPath:\n${missing.join('\n')}',
    );
  }
}

Map<String, dynamic> _readJsonMap(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

void _writeJson(String path, Object value) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

void _writePng(String path, image.Image icon) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(image.encodePng(icon));
}

class _NativeBrandTokens {
  const _NativeBrandTokens(this._tokens);

  final Map<String, dynamic> _tokens;

  static _NativeBrandTokens load() {
    final file = File(_tokenPath);
    if (!file.existsSync()) {
      throw StateError(
        'Missing native brand token cache: $_tokenPath. '
        'Regenerate the design context pack before native brand assets.',
      );
    }
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _NativeBrandTokens(json);
  }

  image.Color color(String name, String mode) {
    final hex = colorHex(name, mode).replaceFirst('#', '');
    final value = int.parse(hex, radix: 16);
    return image.ColorRgb8(
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    );
  }

  String colorHex(String name, String mode) {
    final color =
        (((_tokens['color'] as Map<String, dynamic>)[name]
                    as Map<String, dynamic>)['\$value']
                as Map<String, dynamic>)[mode]
            as String;
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      throw StateError('Token color.$name.$mode must be a #RRGGBB color.');
    }
    return color.toUpperCase();
  }
}

class _IconVariant {
  const _IconVariant({
    required this.generatedName,
    required this.androidSourceSet,
    required this.appleIconSet,
    required this.filenamePrefix,
    required this.ribbons,
    this.iconBase = _IconBase.consumer,
  });

  final String generatedName;
  final String androidSourceSet;
  final String appleIconSet;
  final String filenamePrefix;
  final List<_IconRibbon> ribbons;
  final _IconBase iconBase;
}

enum _IconBase { consumer, host }

class _IconRibbon {
  const _IconRibbon({
    required this.label,
    required this.fillToken,
    required this.labelToken,
  });

  final String label;
  final String fillToken;
  final String labelToken;
}
