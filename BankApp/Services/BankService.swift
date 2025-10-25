import Foundation

protocol BankServicing {
    func fetchAccounts() -> [Account]
    func fetchCards() -> [Card]
    func fetchBudgets() -> [Budget]
    func performTransfer(amount: Decimal, from source: Account, to destination: Account) -> TransferResult
    func toggleCardFreeze(_ card: Card) -> Card
}

struct TransferResult {
    var success: Bool
    var message: String
}

final class MockBankService: BankServicing {
    private var accounts: [Account]
    private var cards: [Card]
    private var budgets: [Budget]

    init(accounts: [Account] = Account.sampleAccounts,
         cards: [Card] = Card.sampleCards,
         budgets: [Budget] = Budget.sampleBudgets) {
        self.accounts = accounts
        self.cards = cards
        self.budgets = budgets
    }

    func fetchAccounts() -> [Account] {
        accounts
    }

    func fetchCards() -> [Card] {
        cards
    }

    func fetchBudgets() -> [Budget] {
        budgets
    }

    func performTransfer(amount: Decimal, from source: Account, to destination: Account) -> TransferResult {
        guard let sourceIndex = accounts.firstIndex(of: source),
              let destinationIndex = accounts.firstIndex(of: destination) else {
            return TransferResult(success: false, message: "Accounts not found")
        }

        guard accounts[sourceIndex].balance >= amount else {
            return TransferResult(success: false, message: "Insufficient funds")
        }

        accounts[sourceIndex].balance -= amount
        accounts[destinationIndex].balance += amount

        return TransferResult(success: true, message: "Transfer successful")
    }

    func toggleCardFreeze(_ card: Card) -> Card {
        guard let index = cards.firstIndex(of: card) else { return card }
        cards[index].isFrozen.toggle()
        return cards[index]
    }
}
