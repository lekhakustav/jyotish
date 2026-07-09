import AuthenticationServices
import SwiftUI

/// Second screen of the welcome flow — same three providers whether the
/// user is signing in or creating an account; Apple/Google inherently
/// handle both in one tap, so only the labels change by mode.
struct AuthMethodView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @Environment(\.colorScheme) private var colorScheme
    let mode: AuthMode

    @State private var currentNonce = ""
    @State private var showEmailAuth = false
    @State private var activeProvider: Provider?

    private enum Provider { case apple, google }
    private var isSignUp: Bool { mode == .signUp }

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text(app.t(isSignUp ? "welcome.signUp" : "welcome.signIn"))
                    .scaledFont(size: 30, weight: .bold, design: .serif)
                    .foregroundStyle(p.inkPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                VStack(spacing: 14) {
                    SignInWithAppleButton(isSignUp ? .signUp : .signIn) { request in
                        app.syncStatus = nil
                        activeProvider = .apple
                        let nonce = AppleSignInNonce.random()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = AppleSignInNonce.sha256(nonce)
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                app.signInApple(credential: credential, rawNonce: currentNonce, mode: mode)
                            } else {
                                activeProvider = nil
                            }
                        case .failure(let error):
                            activeProvider = nil
                            if (error as? ASAuthorizationError)?.code != .canceled {
                                app.syncStatus = error.localizedDescription
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .whiteOutline : .black)
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        if activeProvider == .apple && app.isAuthenticating {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.black)
                                .overlay { ProgressView().tint(.white) }
                        }
                    }
                    .disabled(app.isAuthenticating)

                    SecondaryButton(title: app.t(isSignUp ? "welcome.googleSignUp" : "welcome.googleSignIn"),
                                    icon: "g.circle.fill",
                                    isLoading: activeProvider == .google && app.isAuthenticating) {
                        app.syncStatus = nil
                        activeProvider = .google
                        app.signInGoogle(mode: mode)
                    }
                    .disabled(app.isAuthenticating)
                    SecondaryButton(title: app.t(isSignUp ? "welcome.emailSignUp" : "welcome.emailSignIn"),
                                    icon: "envelope.fill") {
                        showEmailAuth = true
                    }
                    .disabled(app.isAuthenticating)

                    if let syncStatus = app.syncStatus {
                        Text(syncStatus)
                            .scaledFont(size: 14)
                            .foregroundStyle(p.sindoor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showEmailAuth) { EmailAuthView(mode: mode) }
        .onAppear { app.syncStatus = nil }
    }
}
