import SwiftUI

struct CardRow: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(card.nickname)
                    .font(.headline)
                Spacer()
                Label(card.type.rawValue, systemImage: card.type == .credit ? "creditcard" : "banknote")
                    .labelStyle(.titleAndIcon)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(card.number)
                .font(.title2.monospaced())
            HStack {
                Text("Exp. \(card.expiration)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(card.formattedLimit)
                    .font(.headline)
            }
            Toggle(isOn: .constant(!card.isFrozen)) {
                Text(card.isFrozen ? "Card frozen" : "Active")
                    .font(.subheadline.bold())
            }
            .disabled(true)
        }
        .padding()
        .frame(width: 260)
        .background(LinearGradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}

struct CardRow_Previews: PreviewProvider {
    static var previews: some View {
        CardRow(card: Card.sampleCards.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
