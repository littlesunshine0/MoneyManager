//
//  LegacyIcon.swift
//  PiggyBank
//
//  Created by garyrobertellis on 10/22/25.
//



public struct LegacyIcon: View {
    let name: String
    let context: LegacyIconContext
    let color: Color?
    public init(_ name: String, context: LegacyIconContext = .inline, color: Color? = nil) {
        self.name = name
        self.context = context
        self.color = color
    }
    public var body: some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: iconSize, height: iconSize)
            .accessibilityHidden(true)
    }
    private var iconSize: CGFloat {
        switch context {
        case .inline: return 24
        case .status: return 20
        case .toolbar: return 22
        }
    }
}
