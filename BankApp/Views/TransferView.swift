import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var amount: String = ""
    @State private var sourceAccount: Account?
    @State private var destinationAccount: Account?

    var body: some View {
        NavigationView {
            Form {
                Section(header: sectionHeader("Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                }

                Section(header: sectionHeader("From")) {
                    Picker("Source", selection: $sourceAccount) {
                        ForEach(viewModel.accounts) { account in
                            Text(account.name).tag(Optional(account))
                        }
                    }
                }

                Section(header: sectionHeader("To")) {
                    Picker("Destination", selection: $destinationAccount) {
                        ForEach(viewModel.accounts) { account in
                            Text(account.name).tag(Optional(account))
                        }
                    }
                }
            }
            .navigationTitle("Transfer")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send", action: submit)
                        .font(.subheadline.weight(.bold))
                        .disabled(viewModel.accounts.count < 2)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(item: Binding(get: {
                viewModel.transferStatus.map(AlertItem.init)
            }, set: { item in
                if item == nil {
                    viewModel.transferStatus = nil
                }
            })) { item in
                Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")) {
                    if item.success { dismiss() }
                })
            }
            .scrollContentBackground(.hidden)
            .background(Color.tBankBlack)
            .tint(.tBankYellow)
            .toolbarBackground(Color.tBankBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func submit() {
        guard let amountValue = Decimal(string: amount),
              let sourceAccount,
              let destinationAccount else {
            viewModel.transferStatus = TransferResult(success: false, message: "Please complete all fields")
            return
        }

        viewModel.performTransfer(amount: amountValue, from: sourceAccount, to: destinationAccount)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundColor(.tBankSecondaryText)
    }
}

private struct AlertItem: Identifiable, Equatable {
    let id = UUID()
    let success: Bool
    let title: String
    let message: String

    init(result: TransferResult) {
        success = result.success
        title = result.success ? "Success" : "Error"
        message = result.message
    }

    init?(result: TransferResult?) {
        guard let result else { return nil }
        self.init(result: result)
    }
}

extension AlertItem {
    init(_ result: TransferResult) {
        self.init(result: result)
    }
}
