import SwiftUI

@main
struct BankAppApp: App {
    @StateObject private var viewModel = DashboardViewModel(service: MockBankService())

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(viewModel)
        }
    }
}
