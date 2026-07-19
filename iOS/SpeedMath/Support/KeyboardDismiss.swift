import SwiftUI

extension View {
    /// Real tap-outside keyboard dismissal — a plain background tap gesture
    /// that resigns first responder, not a `.scrollDismissesKeyboard` proxy.
    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
