import Flutter
import ContactsUI
import EventKit
import EventKitUI
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
    if let contactsRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativePhoneContactsPlugin") {
      NativePhoneContactsPlugin.register(with: contactsRegistrar)
    }
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "NativeCalendarPlugin"
    ) else {
      NSLog("[Catch] NativeCalendarPlugin registrar unavailable")
      return
    }
    NativeCalendarPlugin.register(with: registrar)
  }
}

private final class NativeCalendarPlugin: NSObject, FlutterPlugin {
  private static let channelName = "catch/calendar"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = NativeCalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "addToCalendar" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard let arguments = call.arguments as? [String: Any] else {
      result(false)
      return
    }

    addToCalendar(arguments: arguments, result: result)
  }

  private func addToCalendar(arguments: [String: Any], result: @escaping FlutterResult) {
    guard
      let title = arguments["title"] as? String,
      let startMillis = arguments["startTimeMillis"] as? NSNumber,
      let endMillis = arguments["endTimeMillis"] as? NSNumber
    else {
      result(false)
      return
    }

    let eventStore = EKEventStore()
    let event = EKEvent(eventStore: eventStore)
    event.title = title
    event.notes = arguments["description"] as? String
    event.location = arguments["location"] as? String
    event.startDate = Date(timeIntervalSince1970: startMillis.doubleValue / 1000)
    event.endDate = Date(timeIntervalSince1970: endMillis.doubleValue / 1000)

    presentEventEditorWhenAuthorized(
      event: event,
      eventStore: eventStore,
      result: result
    )
  }

  private func presentEventEditorWhenAuthorized(
    event: EKEvent,
    eventStore: EKEventStore,
    result: @escaping FlutterResult
  ) {
    let status = EKEventStore.authorizationStatus(for: .event)

    if #available(iOS 17.0, *) {
      switch status {
      case .fullAccess, .writeOnly, .authorized:
        presentEventEditor(event: event, eventStore: eventStore, result: result)
      case .notDetermined:
        eventStore.requestWriteOnlyAccessToEvents { granted, _ in
          DispatchQueue.main.async {
            guard granted else {
              result(false)
              return
            }
            self.presentEventEditor(
              event: event,
              eventStore: eventStore,
              result: result
            )
          }
        }
      case .denied, .restricted:
        result(false)
      @unknown default:
        result(false)
      }
    } else {
      if status == .authorized {
        presentEventEditor(event: event, eventStore: eventStore, result: result)
      } else if status == .notDetermined {
        eventStore.requestAccess(to: .event) { granted, _ in
          DispatchQueue.main.async {
            guard granted else {
              result(false)
              return
            }
            self.presentEventEditor(
              event: event,
              eventStore: eventStore,
              result: result
            )
          }
        }
      } else {
        result(false)
      }
    }
  }

  private func presentEventEditor(
    event: EKEvent,
    eventStore: EKEventStore,
    result: @escaping FlutterResult
  ) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.presentEventEditor(
          event: event,
          eventStore: eventStore,
          result: result
        )
      }
      return
    }

    guard let presentingController = topViewController() else {
      result(false)
      return
    }

    let editor = EKEventEditViewController()
    editor.event = event
    editor.eventStore = eventStore
    editor.editViewDelegate = self
    editor.modalPresentationStyle = .fullScreen

    presentingController.present(editor, animated: true) {
      result(true)
    }
  }

  private func topViewController() -> UIViewController? {
    let root = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController

    var top = root
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

extension NativeCalendarPlugin: EKEventEditViewDelegate {
  func eventEditViewController(
    _ controller: EKEventEditViewController,
    didCompleteWith action: EKEventEditViewAction
  ) {
    controller.dismiss(animated: true)
  }
}

// Selected records only: CNContactPicker needs no CNContactStore authorization.
private final class NativePhoneContactsPlugin: NSObject, FlutterPlugin,
  CNContactPickerDelegate, UIAdaptivePresentationControllerDelegate {
  private var pending: FlutterResult?
  private weak var picker: CNContactPickerViewController?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "catch/phone_contacts", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(NativePhoneContactsPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "pickContacts" else { result(FlutterMethodNotImplemented); return }
    guard pending == nil else { result(["status": "failed"]); return }
    let root = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }
      .first { $0.isKeyWindow }?.rootViewController
    var top = root
    while let presented = top?.presentedViewController { top = presented }
    guard let presenter = top, presenter.viewIfLoaded?.window != nil,
      !presenter.isBeingDismissed else { result(["status": "unavailable"]); return }
    let controller = CNContactPickerViewController()
    controller.delegate = self
    controller.displayedPropertyKeys = [CNContactPhoneNumbersKey]
    pending = result
    picker = controller
    presenter.present(controller, animated: true)
    controller.presentationController?.delegate = self
  }

  // Implementing the plural delegate opts into system multi-selection.
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
    guard contacts.count <= 100 else { finish(["status": "too_many"]); return }
    let selected: [[String: Any]] = contacts.map { contact in
      ["id": contact.identifier,
       "name": CNContactFormatter.string(from: contact, style: .fullName) ?? "",
       "phones": contact.phoneNumbers.map { number in
         ["value": number.value.stringValue,
          "label": number.label.map { CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0) } ?? ""]
       }]
    }
    finish(["status": "selected", "contacts": selected])
  }

  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    finish(["status": "cancelled"])
  }

  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    finish(["status": "cancelled"])
  }

  private func finish(_ response: [String: Any]) {
    let callback = pending
    pending = nil
    picker?.dismiss(animated: true)
    picker = nil
    callback?(response)
  }
}
