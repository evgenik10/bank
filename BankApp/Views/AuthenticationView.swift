import SwiftUI
import UIKit

struct AuthenticationView: View {
    enum Mode: String, CaseIterable { case login = "Sign In"; case register = "Create Account" }

    @EnvironmentObject private var sessionManager: SessionManager

    @State private var mode: Mode = .login
    @State private var selectedRole: User.Role = .customer
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var cardNumber: String = ""
    @State private var smsCode: String = ""
    @State private var representativeCode: String = ""

    @State private var validationError: String?
    @State private var verificationInfo: String?
    @State private var cardIdentity: CardholderIdentity?
    @State private var codeRequested = false
    @State private var isCardVerified = false
    @State private var isSendingCode = false
    @State private var isVerifyingCode = false
    @State private var showOrderSheet = false

    private var sanitizedCardNumber: String { cardNumber.filter(\.isNumber) }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.tBankBlack, .tBankSurface], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        AuthHeader()

                        Picker("Mode", selection: $mode) {
                            ForEach(Mode.allCases, id: \.self) { value in
                                Text(value.rawValue).tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 8)

                        if mode == .login {
                            loginForm
                        } else {
                            registrationForm
                        }

                        if let errorMessage = validationError ?? sessionManager.authError {
                            MessageBanner(text: errorMessage, style: .error)
                        }

                        if let verificationInfo, mode == .register {
                            MessageBanner(text: verificationInfo, style: .info)
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
                        }
                        .disabled(sessionManager.isLoading || (mode == .register && selectedRole == .customer && !isCardVerified))

                        if mode == .register {
                            Button(action: { showOrderSheet.toggle() }) {
                                Text("Don't have a card yet? Order one")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.tBankYellow)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("T•Bank")
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(.tBankYellow)
        .sheet(isPresented: $showOrderSheet) {
            CardOrderView()
        }
        .onChange(of: mode) { newValue in
            validationError = nil
            verificationInfo = nil
            if newValue == .login {
                selectedRole = .customer
            }
        }
        .onChange(of: selectedRole) { role in
            if role == .representative {
                resetCardVerification()
            }
        }
        .onChange(of: cardNumber) { _ in
            codeRequested = false
            isCardVerified = false
            cardIdentity = nil
            verificationInfo = nil
        }
    }

    private var loginForm: some View {
        AuthCard {
            FloatingTextField(title: "Email", text: $email, keyboard: .emailAddress, textContentType: .username)
            FloatingSecureField(title: "Password", text: $password)
        }
    }

    private var registrationForm: some View {
        AuthCard {
            RolePicker(selectedRole: $selectedRole)
                .padding(.bottom, 12)

            FloatingTextField(title: "Full name", text: $name, keyboard: .namePhonePad, autocapitalization: .words, textContentType: .name)
            FloatingTextField(title: "Email", text: $email, keyboard: .emailAddress, textContentType: .emailAddress)
            FloatingSecureField(title: "Password", text: $password)

            if selectedRole == .customer {
                verificationSection
            } else {
                FloatingTextField(title: "Team access code", text: $representativeCode, keyboard: .asciiCapable)
            }
        }
    }

    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider().overlay(Color.white.opacity(0.1))

            Text("Secure your account")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.tBankSecondaryText)

            FloatingTextField(title: "Card number", text: $cardNumber, keyboard: .numberPad, textContentType: .creditCardNumber)

            HStack(spacing: 12) {
                Button(action: requestSmsCode) {
                    if isSendingCode {
                        ProgressView().tint(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.tBankYellow)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        Text(codeRequested ? "Resend code" : "Send SMS code")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.tBankYellow)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .disabled(isSendingCode || sanitizedCardNumber.count < 12)

                if codeRequested {
                    Button(action: confirmSmsCode) {
                        if isVerifyingCode {
                            ProgressView().tint(.tBankYellow)
                        } else {
                            Text("Verify")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.tBankYellow)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            if codeRequested {
                FloatingTextField(title: "SMS code", text: $smsCode, keyboard: .numberPad)
            }

            if let identity = cardIdentity {
                VStack(alignment: .leading, spacing: 8) {
                    Text(identity.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text("Card \(identity.maskedNumber) confirmed")
                        .font(.caption)
                        .foregroundColor(.tBankSecondaryText)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.top, 12)
    }

    private func requestSmsCode() {
        validationError = nil
        verificationInfo = nil
        cardIdentity = nil
        codeRequested = false
        isCardVerified = false
        smsCode = ""
        let digits = sanitizedCardNumber
        guard digits.count >= 12 else {
            validationError = "Enter a valid card number."
            return
        }

        isSendingCode = true
        Task {
            do {
                let identity = try await sessionManager.requestCardVerification(for: digits)
                await MainActor.run {
                    cardIdentity = identity
                    codeRequested = true
                    if let code = identity.demoCode {
                        verificationInfo = "Code \(code) sent to the phone linked with \(identity.maskedNumber)."
                    } else {
                        verificationInfo = "Code sent to the phone linked with \(identity.maskedNumber)."
                    }
                }
            } catch {
                await MainActor.run {
                    validationError = error.localizedDescription
                }
            }
            await MainActor.run {
                isSendingCode = false
            }
        }
    }

    private func confirmSmsCode() {
        validationError = nil
        let digits = sanitizedCardNumber
        guard digits.count >= 12, !smsCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationError = "Enter the SMS code sent to you."
            return
        }

        isVerifyingCode = true
        Task {
            do {
                let identity = try await sessionManager.confirmCardVerification(cardNumber: digits, code: smsCode)
                await MainActor.run {
                    cardIdentity = identity
                    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        name = identity.name
                    }
                    verificationInfo = "Card verified for \(identity.name)."
                    isCardVerified = true
                }
            } catch {
                await MainActor.run {
                    validationError = error.localizedDescription
                    isCardVerified = false
                }
            }
            await MainActor.run {
                isVerifyingCode = false
            }
        }
    }

    private func resetCardVerification() {
        cardNumber = ""
        smsCode = ""
        cardIdentity = nil
        codeRequested = false
        isCardVerified = false
        verificationInfo = nil
    }

    private func submit() {
        validationError = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            validationError = "Email and password are required."
            return
        }

        switch mode {
        case .login:
            sessionManager.login(email: trimmedEmail, password: trimmedPassword)
        case .register:
            switch selectedRole {
            case .customer:
                guard isCardVerified else {
                    validationError = "Verify your card to continue."
                    return
                }
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                sessionManager.register(name: trimmedName.isEmpty ? (cardIdentity?.name ?? "") : trimmedName,
                                        email: trimmedEmail,
                                        password: trimmedPassword,
                                        role: .customer,
                                        cardNumber: sanitizedCardNumber)
            case .representative:
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedName.isEmpty else {
                    validationError = "Please enter your name."
                    return
                }
                guard representativeCode.uppercased() == "REP-2024" else {
                    validationError = "Invalid team access code."
                    return
                }
                sessionManager.register(name: trimmedName,
                                        email: trimmedEmail,
                                        password: trimmedPassword,
                                        role: .representative)
            }
        }
    }
}

private struct AuthHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("T•Bank")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Experience the neon banking suite with secure onboarding and concierge support.")
                .font(.subheadline)
                .foregroundColor(.tBankSecondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AuthCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct RolePicker: View {
    @Binding var selectedRole: User.Role

    var body: some View {
        HStack(spacing: 12) {
            ForEach(User.Role.allCases, id: \.self) { role in
                Button(action: { selectedRole = role }) {
                    Text(role.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedRole == role ? .black : .tBankSecondaryText)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selectedRole == role ? Color.tBankYellow : Color.tBankSurfaceHighlight)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct MessageBanner: View {
    enum Style { case error, info }

    var text: String
    var style: Style

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundColor(style == .error ? .black : .tBankYellow)
            .padding()
            .frame(maxWidth: .infinity)
            .background(style == .error ? Color.red.opacity(0.9) : Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct FloatingTextField: View {
    var title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.tBankSecondaryText)
            TextField("", text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .textContentType(textContentType)
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

private struct CardOrderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var submitted = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact")) {
                    TextField("Full name", text: $fullName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }

                Section(header: Text("Delivery")) {
                    TextField("Street address", text: $address)
                }

                if submitted {
                    Section {
                        Text("Thanks! Our concierge team will reach out within 24 hours.")
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Order a card")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(submitted ? "Close" : "Submit") {
                        if submitted {
                            dismiss()
                        } else {
                            submitted = true
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
