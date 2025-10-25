import SwiftUI

struct AccountDetailView: View {
    let account: Account

    var body: some View {
        List {
            Section(header: sectionHeader("Balance")) {
                Text(account.formattedBalance)
                    .font(.largeTitle.bold())
                    .padding(.vertical)
                    .foregroundColor(.tBankYellow)
            }

            Section(header: sectionHeader("Recent Transactions")) {
                ForEach(account.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                        .listRowBackground(Color.tBankSurface)
                }
            }
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.tBankBlack)
        .listRowBackground(Color.tBankSurface)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundColor(.tBankSecondaryText)
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountDetailView(account: Account.sampleAccounts.first!)
        }
    }
}
