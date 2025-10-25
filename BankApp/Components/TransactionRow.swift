import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var amountColor: Color {
        transaction.isDebit ? .primary : .green
    }

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color(for: transaction.category))
                .frame(width: 40, height: 40)
                .overlay(Text(String(transaction.category.rawValue.prefix(1))).foregroundColor(.white))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                Text(transaction.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.formattedAmount)
                .font(.headline)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 8)
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
