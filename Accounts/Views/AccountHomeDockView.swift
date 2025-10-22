import SwiftUI

// MARK: - Reusable Dock View (supports non-scrollable or scrollable content + selection highlight)
struct AccountHomeDockView: View {
    var items: [DockItem]
    var iconSize: CGFloat = 22
    var horizontalPadding: CGFloat = 18
    var verticalPadding: CGFloat = 12
    var itemSpacing: CGFloat = 18
    var scrollable: Bool = false        // prevent expansion when false
    var showsEdgeFades: Bool = true

    // Selection
    var selectedIndex: Int?
    var onSelect: (Int) -> Void

    @Environment(\.colorScheme) private var scheme
    @Namespace private var selectionNamespace

    var body: some View {
        let row = Group {
            if scrollable {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: itemSpacing) {
                        dockButtons
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                }
            } else {
                HStack(spacing: itemSpacing) {
                    dockButtons
                }
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .fixedSize(horizontal: true, vertical: false)
            }
        }

        return ZStack {
            row
                .background(.thinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(scheme == .dark ? 0.18 : 0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(scheme == .dark ? 0.24 : 0.18), radius: 10, x: 0, y: 6)
                .overlay {
                    if scrollable && showsEdgeFades {
                        HStack {
                            LinearGradient(
                                colors: [
                                    (scheme == .dark ? Color.black : Color.white).opacity(0.25),
                                    .clear
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .frame(width: 18)
                            Spacer(minLength: 0)
                            LinearGradient(
                                colors: [
                                    .clear,
                                    (scheme == .dark ? Color.black : Color.white).opacity(0.25)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .frame(width: 18)
                        }
                        .allowsHitTesting(false)
                        .clipShape(Capsule())
                    }
                }
        }
    }

    // Gradient used to highlight the selected dock item
    private var selectionGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.cyan.opacity(0.55),
                Color.blue.opacity(0.52),
                Color.indigo.opacity(0.50)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    private var dockButtons: some View {
        ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
            Button {
                onSelect(index)
                item.action()
            } label: {
                ZStack {
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selectionGradient)
                            .matchedGeometryEffect(id: "dockSelection", in: selectionNamespace)
                            .frame(width: max(iconSize + 10, 32) + 16, height: max(iconSize + 10, 32) + 8)
                            .shadow(color: Color.cyan.opacity(0.22), radius: 10, x: 0, y: 4)
                            .transition(.opacity.combined(with: .scale))
                    }

                    Image(systemName: item.systemName)
                        .font(.system(size: iconSize, weight: .semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(selectedIndex == index ? .white : .primary)
                        .frame(width: max(iconSize + 10, 32), height: max(iconSize + 10, 32))
                }
                .contentShape(Rectangle())
                .animation(.spring(response: 0.32, dampingFraction: 0.85), value: selectedIndex)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.accessibilityLabel ?? item.systemName)
        }
    }
}

// MARK: - Floating Search Button (circular, trailing)
struct AccountHomeFloatingSearchButton: View {
    var size: CGFloat = 56
    var action: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.28),
                                        Color.white.opacity(0.16)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(scheme == .dark ? 0.30 : 0.25), radius: 14, x: 0, y: 10)
                    .shadow(color: Color.cyan.opacity(0.16), radius: 18, x: 0, y: 8)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Search")
        .accessibilityHint("Open search")
    }
}

// MARK: - Main Content View
struct DockExampleView: View {
    @State private var searchText = ""
    @State private var selectedDockIndex: Int? = 0

    // Exactly 5 dock items as requested
    private var dockItems: [DockItem] {
        [
            DockItem(systemName: "house.fill", accessibilityLabel: "Home") { print("Home tapped") },
            DockItem(systemName: "wallet.pass.fill", accessibilityLabel: "Accounts") { print("Accounts tapped") },
            DockItem(systemName: "chart.pie.fill", accessibilityLabel: "Analytics") { print("Analytics tapped") },
            DockItem(systemName: "plus.app.fill", accessibilityLabel: "Add") { print("Add tapped") },
            DockItem(systemName: "person.fill", accessibilityLabel: "Profile") { print("Profile tapped") }
        ]
    }

    var body: some View {
        ZStack {
            // Your main app content goes here
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 1. A VStack to arrange content with the dock at the bottom.
            VStack(spacing: 15) {
                // 2. Spacer pushes the content below it to the bottom.
                Spacer()

                // 3. Bottom bar: left dock (content-sized) + trailing floating search button
                HStack(alignment: .center) {
                    DockView(
                        items: dockItems,
                        iconSize: 22,
                        horizontalPadding: 18,
                        verticalPadding: 12,
                        itemSpacing: 18,
                        scrollable: false,
                        showsEdgeFades: false,
                        selectedIndex: selectedDockIndex,
                        onSelect: { idx in
                            selectedDockIndex = idx
                        }
                    )
                    .padding(.leading, 8)

                    Spacer(minLength: 12)

                    FloatingSearchButton {
                        // TODO: present search UI or toggle a search overlay
                        print("Search button tapped")
                    }
                    .padding(.trailing, 8)
                    .zIndex(2) // ensure it stays above any dock visuals
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct DockExampleView_iPad_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewDisplayName("iPad")
    }
}
struct DockExampleView_Mac_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1024, height: 768)
            .previewDisplayName("Mac")
    }
}
struct DockExampleView_TV_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("Apple TV 4K (3rd generation)")
            .previewDisplayName("Apple TV")
    }
}
