import SwiftUI

struct AuthenticationView: View {
    enum Mode: String, CaseIterable { case login = "Sign In"; case register = "Create Account" }

    @EnvironmentObject private var sessionManager: SessionManager

    @State private var mode: Mode = .login
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRepresentative: Bool = false
    @State private var validationError: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.tBankBlack.ignoresSafeArea()

                VStack(spacing: 24) {
                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    VStack(spacing: 18) {
                        if mode == .register {
                            FloatingTextField(title: "Full name", text: $name, keyboard: .namePhonePad, autocapitalization: .words)
                        }
                        FloatingTextField(title: "Email", text: $email, keyboard: .emailAddress)
                        FloatingSecureField(title: "Password", text: $password)

                        if mode == .register {
                            Toggle(isOn: $isRepresentative) {
                                Text("Register as a representative")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.tBankSecondaryText)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .tBankYellow))
                        }
                    }
                    .padding()
                    .background(Color.tBankSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal)

                    if let message = validationError ?? sessionManager.authError {
                        Text(message)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    Button(action: submit) {
                        HStack {
                            if sessionManager.isLoading { ProgressView().tint(.black) }
                            Text(mode == .login ? "Sign In" : "Create Account")
                                .font(.headline.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.tBankYellow)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal)
                    }
                    .disabled(sessionManager.isLoading)

                    Spacer()
                }
                .padding(.top, 32)
            }
            .navigationTitle("T•Bank")
            .toolbarBackground(Color.tBankBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func submit() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        validationError = nil

        switch mode {
        case .login:
            sessionManager.login(email: trimmedEmail, password: trimmedPassword)
        case .register:
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                validationError = "Please enter your name."
                return
            }
            sessionManager.register(name: trimmedName, email: trimmedEmail, password: trimmedPassword, role: isRepresentative ? .representative : .customer)
        }
    }
}

private struct FloatingTextField: View {
    var title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.tBankSecondaryText)
            TextField("", text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .disableAutocorrection(true)
                .foregroundColor(.white)
                .padding()
                .background(Color.tBankSurfaceHighlight)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct FloatingSecureField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.tBankSecondaryText)
            SecureField("", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundColor(.white)
                .padding()
                .background(Color.tBankSurfaceHighlight)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
