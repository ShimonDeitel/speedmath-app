import SwiftUI

extension View {
    /// Real tap-outside keyboard dismissal — a tap gesture that resigns
    /// first responder, not a `.scrollDismissesKeyboard` proxy. Uses
    /// `.simultaneousGesture` rather than `.onTapGesture`: a plain
    /// `.onTapGesture` loses gesture arbitration to a List/Form's own row
    /// gestures on almost all of its content, so it can silently never fire.
    /// `.simultaneousGesture` recognizes alongside those instead of
    /// competing with them.
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
    }
}
