import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @State private var card: Card

    init(card: Card) {
        _card = State(initialValue: card)
    }

    var body: some View {
        Form {
            Section(header: Text("Card Information")) {
                Text(card.nickname)
                Text(card.number).font(.title3.monospaced())
                Text("Expiration: \(card.expiration)")
                Toggle(isOn: Binding(get: { !card.isFrozen }, set: { newValue in
                    card.isFrozen = !newValue
                    viewModel.toggleFreeze(card: card)
                })) {
                    Text(card.isFrozen ? "Frozen" : "Active")
                }
            }

            Section(header: Text("Controls")) {
                Button(card.isFrozen ? "Unfreeze Card" : "Freeze Card") {
                    viewModel.toggleFreeze(card: card)
                    card.isFrozen.toggle()
                }
                Button("Set Travel Notice") {}
                Button("Replace Card") {}
            }

            Section(header: Text("Spending")) {
                HStack {
                    Text("Limit")
                    Spacer()
                    Text(card.formattedLimit)
                }
                Button("Adjust Limit") {}
            }
        }
        .navigationTitle(card.nickname)
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardDetailView(card: Card.sampleCards.first!)
                .environmentObject(DashboardViewModel(service: MockBankService()))
        }
    }
}
