import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTopic: SupportTopic = .cards
    @State private var message: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: sectionHeader("Topic")) {
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(SupportTopic.allCases) { topic in
                            Text(topic.rawValue).tag(topic)
                        }
                    }
                }

                Section(header: sectionHeader("Message")) {
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }

                Section(header: sectionHeader("Contact")) {
                    Button(action: {}) {
                        SupportActionLabel(title: "Start Chat", icon: "message")
                    }
                    .buttonStyle(.plain)
                    Button(action: {}) {
                        SupportActionLabel(title: "Call Support", icon: "phone")
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Support")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.tBankBlack)
            .tint(.tBankYellow)
            .toolbarBackground(Color.tBankBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundColor(.tBankSecondaryText)
    }
}

private struct SupportActionLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(.tBankYellow)
                .frame(width: 24)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.tBankSecondaryText)
                .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 6)
    }
}

enum SupportTopic: String, CaseIterable, Identifiable {
    case cards = "Cards"
    case accounts = "Accounts"
    case fraud = "Fraud"
    case technical = "Technical"

    var id: String { rawValue }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
