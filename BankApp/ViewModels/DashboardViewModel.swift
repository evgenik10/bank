import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var user: User
    @Published private(set) var accounts: [Account] = []
    @Published private(set) var cards: [Card] = []
    @Published private(set) var budgets: [Budget] = []
    @Published private(set) var deliveryAssignments: [CardDeliveryAssignment] = []
    @Published var transferStatus: TransferResult?
    @Published var errorMessage: String?

    private let service: BankServicing

    init(service: BankServicing) {
        self.service = service
        self.user = service.user
        Task { await loadData() }
    }

    func loadData() async {
        do {
            if user.role == .representative {
                accounts = []
                cards = []
                budgets = []
                deliveryAssignments = try await service.fetchDeliveryAssignments()
            } else {
                accounts = try await service.fetchAccounts()
                cards = try await service.fetchCards()
                budgets = try await service.fetchBudgets()
                deliveryAssignments = []
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func performTransfer(amount: Decimal, from source: Account, to destination: Account) {
        guard source.id != destination.id else {
            transferStatus = TransferResult(success: false, message: "Select different accounts")
            return
        }

        Task {
            do {
                let result = try await service.performTransfer(amount: amount, from: source, to: destination)
                transferStatus = result
                await loadData()
            } catch {
                transferStatus = TransferResult(success: false, message: error.localizedDescription)
            }
        }
    }

    func toggleFreeze(card: Card) {
        Task {
            do {
                let updated = try await service.toggleCardFreeze(card)
                if let index = cards.firstIndex(of: card) {
                    cards[index] = updated
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
