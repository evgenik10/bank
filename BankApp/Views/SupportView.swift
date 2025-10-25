import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTopic: SupportTopic = .cards
    @State private var message: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic")) {
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(SupportTopic.allCases) { topic in
                            Text(topic.rawValue).tag(topic)
                        }
                    }
                }

                Section(header: Text("Message")) {
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                }

                Section {
                    Button("Start Chat") {}
                    Button("Call Support") {}
                }
            }
            .navigationTitle("Support")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
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
