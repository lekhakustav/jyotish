import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss

    @State private var mode: AuthMode
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var offerSignInInstead = false
    @State private var isSubmitting = false
    @FocusState private var emailFocused: Bool

    init(mode: AuthMode) {
        _mode = State(initialValue: mode)
    }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            VStack(spacing: 24) {
                Text(app.t(mode == .signIn ? "welcome.signIn" : "welcome.signUp"))
                    .scaledFont(size: 24, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                VStack(spacing: 18) {
                    underlined(app.t("welcome.emailPlaceholder")) {
                        TextField(app.t("welcome.emailPlaceholder"), text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($emailFocused)
                    }
                    underlined(app.t("welcome.passwordPlaceholder")) {
                        SecureField(app.t("welcome.passwordPlaceholder"), text: $password)
                    }
                }

                if let errorMessage {
                    VStack(spacing: 8) {
                        Text(errorMessage)
                            .scaledFont(size: 14)
                            .foregroundStyle(p.sindoor)
                            .multilineTextAlignment(.center)
                        if offerSignInInstead {
                            Button(app.t("welcome.signIn")) {
                                mode = .signIn
                                password = ""
                                self.errorMessage = nil
                                offerSignInInstead = false
                            }
                            .scaledFont(size: 15, weight: .semibold, design: .serif)
                            .foregroundStyle(p.saffron)
                        }
                    }
                }

                PrimaryButton(title: app.t(mode == .signIn ? "welcome.signIn" : "welcome.signUp"),
                              isLoading: isSubmitting) {
                    submit()
                }
                .disabled(!formValid || isSubmitting)
                .opacity(formValid ? 1 : 0.5)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
        }
        .overlay(alignment: .topTrailing) { SheetCloseButton().padding(8) }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { emailFocused = true } }
    }

    private func underlined<Content: View>(_ label: String, @ViewBuilder field: () -> Content) -> some View {
        field()
            .scaledFont(size: 19, design: .serif)
            .foregroundStyle(p.inkPrimary)
            .padding(.vertical, 10)
            .overlay(alignment: .bottom) {
                Rectangle().fill(p.templeGold.opacity(0.3)).frame(height: 1)
            }
    }

    private var formValid: Bool {
        email.contains("@") && password.count >= 6
    }

    private func submit() {
        errorMessage = nil
        offerSignInInstead = false
        isSubmitting = true
        Task {
            if mode == .signIn {
                let ok = await app.signInEmail(email: email, password: password)
                isSubmitting = false
                if ok { dismiss() } else { errorMessage = app.syncStatus }
                return
            }
            let outcome = await app.signUpEmail(email: email, password: password)
            isSubmitting = false
            switch outcome {
            case .success:
                dismiss()
            case .emailAlreadyExists:
                errorMessage = app.syncStatus
                offerSignInInstead = true
            case .failure:
                errorMessage = app.syncStatus
            }
        }
    }
}
