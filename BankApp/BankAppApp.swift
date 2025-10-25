import SwiftUI

@main
struct BankAppApp: App {
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if let dashboardViewModel = sessionManager.dashboardViewModel {
                    DashboardView()
                        .environmentObject(dashboardViewModel)
                        .environmentObject(sessionManager)
                } else {
                    AuthenticationView()
                        .environmentObject(sessionManager)
                }
            }
            .preferredColorScheme(.dark)
            .tint(.tBankYellow)
        }
    }
}
