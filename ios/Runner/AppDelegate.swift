import Flutter
import FirebaseAppCheck
import FirebaseAuth
import FirebaseCore
import GoogleMaps
import UIKit

final class AppAttestProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    AppAttestProvider(app: app)
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
      AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
    #else
      AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
    #endif

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
