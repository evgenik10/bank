import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published private(set) var accounts: [Account] = []
    @Published private(set) var cards: [Card] = []
    @Published private(set) var budgets: [Budget] = []
    @Published var transferStatus: TransferResult?

    private let service: BankServicing
    private var cancellables = Set<AnyCancellable>()

    init(service: BankServicing) {
        self.service = service
        loadData()
    }

    func loadData() {
        accounts = service.fetchAccounts()
        cards = service.fetchCards()
        budgets = service.fetchBudgets()
    }

    func performTransfer(amount: Decimal, from source: Account, to destination: Account) {
        guard source.id != destination.id else {
            transferStatus = TransferResult(success: false, message: "Select different accounts")
            return
        }
        transferStatus = service.performTransfer(amount: amount, from: source, to: destination)
        loadData()
    }

    func toggleFreeze(card: Card) {
        let updated = service.toggleCardFreeze(card)
        if let index = cards.firstIndex(of: card) {
            cards[index] = updated
        }
    }
}
