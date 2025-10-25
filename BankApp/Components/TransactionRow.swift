import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var amountColor: Color {
        transaction.isDebit ? .white : .tBankYellow
    }

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color(for: transaction.category).opacity(0.8))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon(for: transaction.category))
                        .foregroundColor(.white)
                        .font(.footnote.weight(.bold))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(transaction.formattedDate)
                    .font(.caption)
                    .foregroundColor(.tBankSecondaryText)
            }
            Spacer()
            Text(transaction.formattedAmount)
                .font(.headline)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 8)
    }

    private func icon(for category: Transaction.Category) -> String {
        switch category {
        case .groceries: return "cart"
        case .dining: return "fork.knife"
        case .transport: return "car"
        case .entertainment: return "sparkles"
        case .utilities: return "bolt"
        case .deposit: return "arrow.down.to.line"
        }
    }

    private func color(for category: Transaction.Category) -> Color {
        switch category {
        case .groceries: return .green
        case .dining: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .utilities: return .gray
        case .deposit: return .mint
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction.sampleTransactions.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
