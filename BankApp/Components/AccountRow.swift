import SwiftUI

struct AccountRow: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(.headline)
                    Text(account.number)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(account.formattedBalance)
                    .font(.title3.bold())
                    .foregroundColor(account.balance < 0 ? .red : .primary)
            }
            Text(account.type.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(Capsule())
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct AccountRow_Previews: PreviewProvider {
    static var previews: some View {
        AccountRow(account: Account.sampleAccounts.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
