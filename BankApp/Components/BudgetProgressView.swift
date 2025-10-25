import SwiftUI

struct BudgetProgressView: View {
    let budget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(budget.formattedSpent) / \(budget.formattedLimit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ProgressView(value: budget.progress)
                .progressViewStyle(.linear)
                .tint(color(for: budget.category))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
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

struct BudgetProgressView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetProgressView(budget: Budget.sampleBudgets.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
