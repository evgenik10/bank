import SwiftUI

struct CardRow: View {
    let card: Card

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: [.tBankSurfaceHighlight, .tBankSurface], startPoint: .topLeading, endPoint: .bottomTrailing))

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.nickname)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                        Text(card.type.rawValue)
                            .font(.caption)
                            .foregroundColor(.tBankSecondaryText)
                    }
                    Spacer()
                    Image(systemName: card.type == .credit ? "creditcard" : "banknote")
                        .imageScale(.large)
                        .foregroundColor(.tBankYellow)
                        .padding(10)
                        .background(Color.tBankYellow.opacity(0.18))
                        .clipShape(Circle())
                }

                Text(card.maskedNumber)
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exp.")
                            .font(.caption2)
                            .foregroundColor(.tBankSecondaryText)
                        Text(card.expiration)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Limit")
                            .font(.caption2)
                            .foregroundColor(.tBankSecondaryText)
                        Text(card.formattedLimit)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.tBankYellow)
                    }
                }

                HStack {
                    Capsule()
                        .fill(card.isFrozen ? Color.red.opacity(0.2) : Color.tBankYellow.opacity(0.2))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: card.isFrozen ? "snow" : "wave.3.forward")
                                .foregroundColor(card.isFrozen ? .red : .tBankYellow)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.isFrozen ? "Card frozen" : "Ready to use")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        Text(card.isFrozen ? "Unfreeze to pay" : "Tap for controls")
                            .font(.caption)
                            .foregroundColor(.tBankSecondaryText)
                    }
                }
            }
            .padding(24)

            Circle()
                .fill(Color.tBankYellow.opacity(0.3))
                .frame(width: 120)
                .offset(x: 26, y: -30)
        }
        .frame(width: 280)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 14)
    }
}

struct CardRow_Previews: PreviewProvider {
    static var previews: some View {
        CardRow(card: Card.sampleCards.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
