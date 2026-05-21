import Flutter
import FirebaseAuth
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase App Check is configured entirely from Dart
    // (FirebaseAppCheck.activate in lib/main.dart). Do not also register a
    // native provider factory here — that double-configures App Check and the
    // two paths can disagree on debug vs App Attest provider selection.
    application.registerForRemoteNotifications()
    if let rawMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String {
      let mapsApiKey = rawMapsApiKey
        .replacingOccurrences(of: "keyString:", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
      if !mapsApiKey.isEmpty, !mapsApiKey.hasPrefix("$(") {
        GMSServices.provideAPIKey(mapsApiKey)
      } else {
        NSLog(
          "[Catch] GoogleMapsApiKey is empty or unsubstituted; "
            + "GMSServices.provideAPIKey was skipped. Map screens will crash. "
            + "Check ios/Flutter/GoogleMapsKeys.xcconfig and the build pipeline."
        )
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }

    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    super.application(
      application,
      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
    )
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    super.application(
      application,
      didFailToRegisterForRemoteNotificationsWithError: error
    )
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if Auth.auth().canHandleNotification(userInfo) {
      completionHandler(.noData)
      return
    }

    super.application(
      application,
      didReceiveRemoteNotification: userInfo,
      fetchCompletionHandler: completionHandler
    )
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
