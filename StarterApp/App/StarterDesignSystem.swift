import AppFoundation
import SwiftUI

enum StarterSurfaceEmphasis: Equatable {
    case quiet
    case standard
    case prominent

    var highlightOpacity: Double {
        switch self {
        case .quiet: 0.025
        case .standard: 0.045
        case .prominent: 0.075
        }
    }

    var shadowScale: Double {
        switch self {
        case .quiet: 0.45
        case .standard: 0.7
        case .prominent: 1
        }
    }
}

struct StarterThemeBackground: View {
    let theme: AppTheme

    var body: some View {
        ZStack {
            theme.backgroundColor

            RadialGradient(
                colors: [theme.accentColor.opacity(0.32), .clear],
                center: .topTrailing,
                startRadius: 8,
                endRadius: 540
            )

            theme.gradient
                .opacity(0.16)
                .blur(radius: 30)
                .scaleEffect(1.22)

            RadialGradient(
                colors: [theme.appearance.gradientEnd.color.opacity(0.18), .clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 500
            )

            LinearGradient(
                colors: [
                    theme.primaryForegroundColor.opacity(0.025),
                    .clear,
                    theme.appearance.shadow.color.opacity(0.14),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Image(systemName: "sparkles")
                .font(.system(size: 210, weight: .black))
                .foregroundStyle(theme.primaryForegroundColor.opacity(0.025))
                .rotationEffect(.degrees(14))
                .offset(x: 68, y: -52)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottomLeading) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 142, weight: .black))
                .foregroundStyle(theme.accentColor.opacity(0.04))
                .rotationEffect(.degrees(-18))
                .offset(x: -38, y: 46)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }
}

struct StarterThemeCard<Content: View>: View {
    let theme: AppTheme
    let emphasis: StarterSurfaceEmphasis
    let padding: CGFloat
    let cornerRadius: CGFloat
    private let content: Content

    init(
        theme: AppTheme,
        emphasis: StarterSurfaceEmphasis = .standard,
        padding: CGFloat = 18,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.emphasis = emphasis
        self.padding = padding
        self.cornerRadius = cornerRadius ?? CGFloat(theme.appearance.cardCornerRadius)
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            emphasis == .prominent
                                ? theme.elevatedSurfaceColor
                                : theme.surfaceColor
                        )

                    LinearGradient(
                        colors: [
                            theme.primaryForegroundColor.opacity(emphasis.highlightOpacity),
                            theme.accentColor.opacity(emphasis == .prominent ? 0.07 : 0.025),
                            .clear,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(theme.borderColor, lineWidth: 1)
            }
            .shadow(
                color: theme.appearance.shadow.color.opacity(emphasis.shadowScale),
                radius: emphasis == .prominent ? 26 : 16,
                y: emphasis == .prominent ? 14 : 9
            )
    }
}

struct StarterEyebrow: View {
    let title: String
    var systemImage: String?
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 7) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title.uppercased())
                .tracking(1.45)
        }
        .font(.caption.weight(.black))
        .foregroundStyle(theme.secondaryForegroundColor)
    }
}

struct StarterSymbolBadge: View {
    let systemImage: String
    let theme: AppTheme
    var size: CGFloat = 46

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(theme.accentColor)
            .frame(width: size, height: size)
            .background(
                theme.accentColor.opacity(0.12),
                in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .stroke(theme.accentColor.opacity(0.18), lineWidth: 1)
            }
    }
}

struct StarterPrimaryButtonStyle: ButtonStyle {
    let theme: AppTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(theme.primaryForegroundColor)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.gradient)
                    .opacity(configuration.isPressed ? 0.78 : 1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(theme.borderColor, lineWidth: 1)
            }
            .shadow(color: theme.accentColor.opacity(0.22), radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct StarterSecondaryButtonStyle: ButtonStyle {
    let theme: AppTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(theme.primaryForegroundColor.opacity(configuration.isPressed ? 0.62 : 0.9))
            .padding(.horizontal, 15)
            .padding(.vertical, 11)
            .background(
                theme.elevatedSurfaceColor.opacity(configuration.isPressed ? 0.72 : 0.95),
                in: Capsule()
            )
            .overlay {
                Capsule().stroke(theme.borderColor, lineWidth: 1)
            }
    }
}
