import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @State private var showingTransferSheet = false
    @State private var showingSupport = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    accountsSection
                    cardsSection
                    budgetsSection
                }
                .padding()
            }
            .navigationTitle("Banking")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingTransferSheet.toggle()
                    } label: {
                        Label("Transfer", systemImage: "arrow.left.arrow.right")
                    }

                    Button {
                        showingSupport.toggle()
                    } label: {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                }
            }
            .sheet(isPresented: $showingTransferSheet) {
                TransferView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingSupport) {
                SupportView()
            }
        }
    }

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Accounts", actionTitle: "See all") {
                // Future navigation
            }
            ForEach(viewModel.accounts) { account in
                NavigationLink(destination: AccountDetailView(account: account)) {
                    AccountRow(account: account)
                }
            }
        }
    }

    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Cards", actionTitle: "Manage") {
                // Manage cards action
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.cards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            CardRow(card: card)
                        }
                    }
                }
            }
        }
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Budgets", actionTitle: "Adjust") {
                // Adjust budgets action
            }
            VStack(spacing: 12) {
                ForEach(viewModel.budgets) { budget in
                    BudgetProgressView(budget: budget)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.bold())
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(DashboardViewModel(service: MockBankService()))
    }
}
