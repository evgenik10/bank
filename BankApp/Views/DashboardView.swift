import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var sessionManager: SessionManager

    @State private var showingTransferSheet = false
    @State private var showingSupport = false

    private var isRepresentative: Bool { viewModel.user.role == .representative }
    private var deliveryStats: (pending: Int, delivered: Int) {
        let delivered = viewModel.deliveryAssignments.filter { $0.status == .delivered }.count
        let pending = viewModel.deliveryAssignments.count - delivered
        return (max(pending, 0), delivered)
    }
    private var nextDelivery: CardDeliveryAssignment? {
        viewModel.deliveryAssignments
            .filter { $0.status != .delivered }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.tBankBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection

                        if let message = viewModel.errorMessage {
                            errorBanner(message)
                        }

                        if isRepresentative {
                            representativeHero
                            deliveriesSection
                        } else {
                            if let primaryAccount = viewModel.accounts.first {
                                heroCard(for: primaryAccount)
                            }

                            if !viewModel.accounts.isEmpty {
                                accountsSection
                            }

                            if !viewModel.cards.isEmpty {
                                cardsSection
                            }

                            if !viewModel.budgets.isEmpty {
                                budgetsSection
                            }
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await viewModel.loadData()
                }
            }
            .navigationTitle("T•Bank")
            .toolbarBackground(Color.tBankBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.user.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(viewModel.user.role.displayName)
                            .font(.caption)
                            .foregroundColor(.tBankSecondaryText)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.user.role != .representative {
                        ToolbarActionButton(title: "Transfer", systemImage: "arrow.left.arrow.right") {
                            showingTransferSheet.toggle()
                        }
                        .disabled(viewModel.accounts.count < 2)
                    }

                    ToolbarActionButton(title: "Support", systemImage: "message") {
                        showingSupport.toggle()
                    }

                    ToolbarActionButton(title: "Logout", systemImage: "rectangle.portrait.and.arrow.right") {
                        sessionManager.logout()
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

    private var headerSection: some View {
        HStack(alignment: .center) {
            Text("Welcome back")
                .font(.system(.title2, design: .rounded).weight(.semibold))
                .foregroundColor(.tBankSecondaryText)

            Spacer()

            if viewModel.user.role == .representative {
                Label("Representative", systemImage: "person.2")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.tBankSurfaceHighlight)
                    .clipShape(Capsule())
                    .foregroundColor(.tBankSecondaryText)
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.footnote.weight(.semibold))
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func heroCard(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Balance")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.tBankSecondaryText)

                Text(account.formattedBalance)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Divider()
                .overlay(Color.tBankSurfaceHighlight)

            HStack(spacing: 16) {
                QuickActionButton(title: "Transfer", icon: "arrow.left.arrow.right", background: .tBankYellow, foreground: .black) {
                    showingTransferSheet.toggle()
                }

                QuickActionButton(title: "Pay", icon: "creditcard", background: Color.tBankSurfaceHighlight, foreground: .tBankSecondaryText) {}

                QuickActionButton(title: "Top up", icon: "plus", background: Color.tBankSurfaceHighlight, foreground: .tBankSecondaryText) {}
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [.tBankSurfaceHighlight, .tBankSurface], startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .fill(Color.tBankYellow.opacity(0.35))
                    .frame(width: 160, height: 160)
                    .offset(x: 30, y: -80)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 22, x: 0, y: 14)
    }

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Accounts", actionTitle: "See all") {}

            VStack(spacing: 16) {
                ForEach(viewModel.accounts) { account in
                    NavigationLink(destination: AccountDetailView(account: account)) {
                        AccountRow(account: account)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Cards", actionTitle: "Manage") {}
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.cards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            CardRow(card: card)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Budgets", actionTitle: "Adjust") {}
            VStack(spacing: 12) {
                ForEach(viewModel.budgets) { budget in
                    BudgetProgressView(budget: budget)
                }
            }
        }
    }

    private var representativeHero: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text("Delivery overview")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Spacer()
                if deliveryStats.pending > 0 {
                    Text("\(deliveryStats.pending) pending")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tBankYellow)
                        .clipShape(Capsule())
                }
            }

            if let nextDelivery {
                VStack(alignment: .leading, spacing: 8) {
                    Label(nextDelivery.clientName, systemImage: "location")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(nextDelivery.address)
                        .font(.subheadline)
                        .foregroundColor(.tBankSecondaryText)
                    Text("Next stop • \(nextDelivery.formattedDate)")
                        .font(.caption)
                        .foregroundColor(.tBankSecondaryText)
                }
            } else {
                Text("You're all caught up. No deliveries remaining today.")
                    .font(.callout)
                    .foregroundColor(.tBankSecondaryText)
            }

            Divider().overlay(Color.tBankSurfaceHighlight)

            HStack(spacing: 24) {
                MetricPill(title: "Pending", value: deliveryStats.pending, tint: .tBankYellow)
                MetricPill(title: "Completed", value: deliveryStats.delivered, tint: .green)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.tBankSurface, .tBankSurfaceHighlight.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private var deliveriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Delivery queue", actionTitle: nil)

            if viewModel.deliveryAssignments.isEmpty {
                Text("No deliveries assigned yet. Check back soon.")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.tBankSecondaryText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.tBankSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.deliveryAssignments) { assignment in
                        DeliveryAssignmentRow(assignment: assignment)
                    }
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
        HStack(alignment: .center) {
            Text(title)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundColor(.white)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.tBankYellow)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let icon: String
    var background: Color
    var foreground: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

private struct ToolbarActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.tBankYellow)
                .padding(10)
                .background(Color.tBankSurface)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.tBankYellow.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel(title)
    }
}

private struct DeliveryAssignmentRow: View {
    var assignment: CardDeliveryAssignment

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(assignment.clientName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(assignment.address)
                        .font(.caption)
                        .foregroundColor(.tBankSecondaryText)
                }

                Spacer()

                StatusBadge(status: assignment.status)
            }

            Divider().overlay(Color.tBankSurfaceHighlight)

            HStack {
                Label(assignment.cardNickname, systemImage: "creditcard")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.tBankSecondaryText)
                Spacer()
                Text(assignment.formattedDate)
                    .font(.caption)
                    .foregroundColor(.tBankSecondaryText)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tBankSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct MetricPill: View {
    var title: String
    var value: Int
    var tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.title2.bold())
                .foregroundColor(tint)
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.tBankSecondaryText)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct StatusBadge: View {
    var status: CardDeliveryAssignment.Status

    private var configuration: (label: String, color: Color, icon: String) {
        switch status {
        case .scheduled:
            return ("Scheduled", .tBankYellow, "clock")
        case .enRoute:
            return ("En route", .blue, "figure.walk")
        case .delivered:
            return ("Delivered", .green, "checkmark")
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: configuration.icon)
            Text(configuration.label)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(.black)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(configuration.color)
        .clipShape(Capsule())
    }
}
