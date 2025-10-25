import Foundation

@MainActor
final class SessionManager: ObservableObject {
    enum AuthState {
        case unauthenticated
        case authenticating
        case authenticated(User)
    }

    @Published private(set) var authState: AuthState = .unauthenticated
    @Published private(set) var authError: String?
    @Published private(set) var dashboardViewModel: DashboardViewModel?

    private let backend: BankBackend

    init(backend: BankBackend = InMemoryBankBackend.shared) {
        self.backend = backend
    }

    var isLoading: Bool {
        if case .authenticating = authState { return true }
        return false
    }

    func login(email: String, password: String) {
        authError = nil
        authState = .authenticating

        Task {
            do {
                let user = try await backend.login(email: email, password: password)
                await startSession(for: user)
            } catch {
                authState = .unauthenticated
                authError = error.localizedDescription
            }
        }
    }

    func register(name: String, email: String, password: String, role: User.Role, cardNumber: String? = nil, representativeCode: String? = nil) {
        authError = nil
        authState = .authenticating

        Task {
            do {
                let user = try await backend.register(name: name,
                                                      email: email,
                                                      password: password,
                                                      role: role,
                                                      cardNumber: cardNumber,
                                                      representativeCode: representativeCode)
                await startSession(for: user)
            } catch {
                authState = .unauthenticated
                authError = error.localizedDescription
            }
        }
    }

    func requestCardVerification(for cardNumber: String) async throws -> CardholderIdentity {
        try await backend.requestCardVerification(for: cardNumber)
    }

    func confirmCardVerification(cardNumber: String, code: String) async throws -> CardholderIdentity {
        try await backend.confirmCardVerification(cardNumber: cardNumber, code: code)
    }

    func logout() {
        dashboardViewModel = nil
        authState = .unauthenticated
        authError = nil
    }

    private func startSession(for user: User) async {
        let service = BackendBankService(user: user, backend: backend)
        let viewModel = DashboardViewModel(service: service)
        dashboardViewModel = viewModel
        authState = .authenticated(user)
    }
}
