import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @State private var card: Card

    init(card: Card) {
        _card = State(initialValue: card)
    }

    var body: some View {
        List {
            Section(header: sectionHeader("Card Information")) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.nickname)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(card.maskedNumber)
                        .font(.title3.monospaced())
                        .foregroundColor(.tBankYellow)
                    Text("Expiration: \(card.expiration)")
                        .font(.subheadline)
                        .foregroundColor(.tBankSecondaryText)
                }
                Toggle(isOn: Binding(get: { !card.isFrozen }, set: { newValue in
                    card.isFrozen = !newValue
                    viewModel.toggleFreeze(card: card)
                })) {
                    Text(card.isFrozen ? "Frozen" : "Active")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                }
            }

            Section(header: sectionHeader("Controls")) {
                Button(action: {
                    viewModel.toggleFreeze(card: card)
                    card.isFrozen.toggle()
                }) {
                    ControlLabel(title: card.isFrozen ? "Unfreeze Card" : "Freeze Card", icon: card.isFrozen ? "sun.max" : "snow")
                }
                .buttonStyle(.plain)
                Button(action: {}) {
                    ControlLabel(title: "Set Travel Notice", icon: "airplane")
                }
                .buttonStyle(.plain)
                Button(action: {}) {
                    ControlLabel(title: "Replace Card", icon: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.plain)
            }

            Section(header: sectionHeader("Spending")) {
                HStack {
                    Text("Limit")
                        .foregroundColor(.tBankSecondaryText)
                    Spacer()
                    Text(card.formattedLimit)
                        .foregroundColor(.tBankYellow)
                }
                Button(action: {}) {
                    ControlLabel(title: "Adjust Limit", icon: "slider.horizontal.3")
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(card.nickname)
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

private struct ControlLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(.tBankYellow)
                .frame(width: 24, height: 24)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.tBankSecondaryText)
                .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 4)
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
