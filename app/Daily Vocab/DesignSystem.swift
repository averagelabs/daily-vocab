import SwiftUI

// MARK: - Design System

public enum DS {
    // MARK: Color Tokens
    public enum ColorToken: String {
        case background = "DS.Background"
        case surface = "DS.Surface"
        case card = "DS.Card"
        case textPrimary = "DS.TextPrimary"
        case textSecondary = "DS.TextSecondary"
        case border = "DS.Border"
        case accent = "DS.Accent"
    }

    public enum Color {
        public static var background: SwiftUI.Color { SwiftUI.Color(ColorToken.background.rawValue) }
        public static var surface: SwiftUI.Color { SwiftUI.Color(ColorToken.surface.rawValue) }
        public static var card: SwiftUI.Color { SwiftUI.Color(ColorToken.card.rawValue) }
        public static var textPrimary: SwiftUI.Color { SwiftUI.Color(ColorToken.textPrimary.rawValue) }
        public static var textSecondary: SwiftUI.Color { SwiftUI.Color(ColorToken.textSecondary.rawValue) }
        public static var border: SwiftUI.Color { SwiftUI.Color(ColorToken.border.rawValue) }
        public static var accent: SwiftUI.Color { SwiftUI.Color(ColorToken.accent.rawValue) }
    }

    // MARK: Typography
    public enum FontToken {
        public static func heading(size: CGFloat = 32, weight: SwiftUI.Font.Weight = .bold) -> SwiftUI.Font {
                // Instrument Serif only comes in Regular — weight is ignored
                return .custom("InstrumentSerif-Regular", size: size, relativeTo: .title)
            }

        public static func body(size: CGFloat = 17, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            let name: String
            switch weight {
            case .semibold: name = "InstrumentSans-SemiBold"
            case .bold:     name = "InstrumentSans-Bold"
            case .medium:   name = "InstrumentSans-Medium"
            default:        name = "InstrumentSans-Regular"
            }
            return .custom(name, size: size, relativeTo: .body)
        }
    }

    // MARK: Spacing & Radius
    public enum Space {
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let s: CGFloat = 12
        public static let m: CGFloat = 16
        public static let l: CGFloat = 20
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    public enum Radius {
        public static let s: CGFloat = 10
        public static let m: CGFloat = 14
        public static let l: CGFloat = 20
    }

    // MARK: Icon helper
    public struct Icon: View {
        private let name: String
        private let size: CGFloat
        private let tint: SwiftUI.Color?

        public init(_ name: String, size: CGFloat = 20, tint: SwiftUI.Color? = nil) {
            self.name = name
            self.size = size
            self.tint = tint
        }

        public var body: some View {
            // Apply rendering mode on Image before converting to a generic View
            let baseImage: Image
            if tint != nil {
                baseImage = Image(name).renderingMode(Image.TemplateRenderingMode.template)
            } else {
                baseImage = Image(name).renderingMode(Image.TemplateRenderingMode.original)
            }

            let view = baseImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)

            // Apply tint if provided
            if let tint {
                return AnyView(view.foregroundStyle(tint))
            } else {
                return AnyView(view)
            }
        }
    }
}

// MARK: - View Modifiers for Typography
public struct DSHeadingModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(DS.FontToken.heading())
            .foregroundStyle(DS.Color.textPrimary)
    }
}

public struct DSBodyModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(DS.FontToken.body())
            .foregroundStyle(DS.Color.textPrimary)
    }
}

public extension View {
    func dsHeading() -> some View { modifier(DSHeadingModifier()) }
    func dsBody() -> some View { modifier(DSBodyModifier()) }
}

// MARK: - Components
public struct DSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.l)
        .background(DS.Color.card)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous)
                .stroke(DS.Color.border, lineWidth: 1)
        )
    }
}

public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.FontToken.body(weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, DS.Space.xl)
            .padding(.vertical, DS.Space.s)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous)
                    .fill(DS.Color.accent)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.FontToken.body(weight: .semibold))
            .foregroundStyle(DS.Color.accent)
            .padding(.horizontal, DS.Space.xl)
            .padding(.vertical, DS.Space.s)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous)
                    .stroke(DS.Color.accent, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - Empty State
public struct EmptyStateView: View {
    public struct Action {
        public let title: String
        public let handler: () -> Void
        public init(title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }
    }

    private let illustrationName: String
    private let title: String
    private let message: String
    private let action: Action?

    public init(illustrationName: String, title: String, message: String, action: Action? = nil) {
        self.illustrationName = illustrationName
        self.title = title
        self.message = message
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DS.Space.l) {
            Image(illustrationName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .accessibilityHidden(true)

            VStack(spacing: DS.Space.xs) {
                Text(title)
                    .font(DS.FontToken.heading())
                    .foregroundStyle(DS.Color.textPrimary)
                Text(message)
                    .font(DS.FontToken.body())
                    .foregroundStyle(DS.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DS.Space.xl)

            if let action {
                Button(action.title, action: action.handler)
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(DS.Space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Color.background)
    }
}

// MARK: - Local Preview
#Preview("Design System Preview") {
    ScrollView {
        VStack(alignment: .leading, spacing: DS.Space.xl) {
            Group {
                Text("Heading Style").dsHeading()
                Text("Body style text for normal content.").dsBody()
            }

            DSCard {
                Text("Card Title").dsHeading()
                Text("Card body text with secondary color.")
                    .font(DS.FontToken.body())
                    .foregroundStyle(DS.Color.textSecondary)
            }

            HStack(spacing: DS.Space.m) {
                Button("Primary") {}
                    .buttonStyle(PrimaryButtonStyle())
                Button("Secondary") {}
                    .buttonStyle(SecondaryButtonStyle())
            }

            HStack(spacing: DS.Space.m) {
                DS.Icon("DS.Icon.Home", size: 24, tint:
                    DS.Color.accent)
                DS.Icon("DS.Icon.Cards", size: 24, tint: DS.Color.accent)
                DS.Icon("DS.Icon.Bookmark", size: 24, tint: DS.Color.accent)
                DS.Icon("DS.Icon.Settings", size: 24, tint: DS.Color.accent)
            }

            VStack(spacing: DS.Space.xl) {
                EmptyStateView(
                    illustrationName: "DS.Illustration.EmptySaved",
                    title: "No Saved Words",
                    message: "Save words you want to revisit here.",
                    action: .init(title: "Browse Words") {}
                )
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))

                EmptyStateView(
                    illustrationName: "DS.Illustration.EmptyReview",
                    title: "Nothing to Review",
                    message: "You’re all caught up! Check back later.")
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
            }
        }
        .padding(DS.Space.xl)
    }
    .background(DS.Color.background)
//    .preferredColorScheme(.dark)
}
