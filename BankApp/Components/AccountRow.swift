import SwiftUI

struct AccountRow: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(account.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(account.number)
                        .font(.caption)
                        .foregroundColor(.tBankSecondaryText)
                }
                Spacer()
                Text(account.formattedBalance)
                    .font(.title3.bold())
                    .foregroundColor(account.balance < 0 ? .red : .tBankYellow)
            }

            Text(account.type.rawValue.uppercased())
                .font(.caption2.weight(.medium))
                .foregroundColor(.tBankYellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.tBankYellow.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [.tBankSurfaceHighlight, .tBankSurface], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
    }
}

struct AccountRow_Previews: PreviewProvider {
    static var previews: some View {
        AccountRow(account: Account.sampleAccounts.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
