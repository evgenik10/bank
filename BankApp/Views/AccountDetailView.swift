import SwiftUI

struct AccountDetailView: View {
    let account: Account

    var body: some View {
        List {
            Section(header: Text("Balance")) {
                Text(account.formattedBalance)
                    .font(.largeTitle.bold())
                    .padding(.vertical)
            }

            Section(header: Text("Recent Transactions")) {
                ForEach(account.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountDetailView(account: Account.sampleAccounts.first!)
        }
    }
}
