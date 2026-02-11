import Flutter
import UIKit

/// SmartKeyboardInsetsPlugin - iOS implementation for keyboard metrics detection.
///
/// Provides accurate keyboard height and safe area bottom inset detection using
/// keyboard notifications for state changes and safeAreaInsets for system UI calculations.
public class SmartKeyboardInsetsPlugin: NSObject, FlutterPlugin {
    private var eventSink: FlutterEventSink?
    private var isObserving = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Set up MethodChannel for one-time method calls like getCurrentMetrics (Requirement 9.1)
        let methodChannel = FlutterMethodChannel(
            name: "smart_keyboard_insets/method",
            binaryMessenger: registrar.messenger()
        )
        
        // Set up EventChannel for continuous keyboard metrics streaming (Requirement 9.2)
        let eventChannel = FlutterEventChannel(
            name: "smart_keyboard_insets/event",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = SmartKeyboardInsetsPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }
    
    /// Handles method calls from Flutter side.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCurrentMetrics":
            result(getCurrentKeyboardMetrics())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Keyboard Observation
    
    /// Starts observing keyboard notifications.
    /// Prevents duplicate observer registration (Requirement 9.5).
    private func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        
        // Observe keyboardWillShowNotification (Requirement 8.1)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        // Observe keyboardWillHideNotification (Requirement 8.2)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Observe keyboardWillChangeFrameNotification (Requirement 8.3)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        // Send initial metrics immediately
        sendCurrentMetrics()
    }
    
    /// Stops observing keyboard notifications.
    /// Removes observers to prevent memory leaks (Requirement 8.7).
    private func stopObserving() {
        guard isObserving else { return }
        isObserving = false
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Notification Handlers
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        sendKeyboardMetrics(from: notification, isVisible: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        sendKeyboardMetrics(from: notification, isVisible: false)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let screenHeight = UIScreen.main.bounds.height
        let isVisible = endFrame.origin.y < screenHeight
        sendKeyboardMetrics(from: notification, isVisible: isVisible)
    }
    
    // MARK: - Metrics Calculation
    
    /// Sends keyboard metrics to Flutter via EventSink.
    /// Extracts keyboard height from keyboardFrameEndUserInfoKey (Requirement 8.4).
    private func sendKeyboardMetrics(from notification: Notification, isVisible: Bool) {
        guard let userInfo = notification.userInfo,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = isVisible ? endFrame.height : 0.0
        let safeAreaBottom = getSafeAreaBottom()
        
        eventSink?([
            "keyboardHeight": keyboardHeight,
            "safeAreaBottom": safeAreaBottom,
            "isKeyboardVisible": isVisible
        ])
    }
    
    /// Sends current metrics without a notification (for initial state).
    private func sendCurrentMetrics() {
        let metrics = getCurrentKeyboardMetrics()
        eventSink?(metrics)
    }
    
    /// Gets current keyboard metrics for method channel calls.
    private func getCurrentKeyboardMetrics() -> [String: Any] {
        return [
            "keyboardHeight": 0.0,
            "safeAreaBottom": getSafeAreaBottom(),
            "isKeyboardVisible": false
        ]
    }
    
    /// Gets the safe area bottom inset from the window (Requirement 8.5).
    private func getSafeAreaBottom() -> Double {
        if #available(iOS 13.0, *) {
            // Use the first connected scene's window
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                return window.safeAreaInsets.bottom
            }
        }
        // Fallback for older iOS versions
        if let window = UIApplication.shared.windows.first {
            return window.safeAreaInsets.bottom
        }
        return 0.0
    }
}

// MARK: - FlutterStreamHandler

extension SmartKeyboardInsetsPlugin: FlutterStreamHandler {
    /// Called when Flutter starts listening to the EventChannel (Requirement 9.3).
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startObserving()
        return nil
    }
    
    /// Called when Flutter cancels the EventChannel subscription (Requirement 9.4).
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopObserving()
        eventSink = nil
        return nil
    }
}
