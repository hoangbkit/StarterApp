#if DEBUG
import AppFoundation
import SwiftUI

@MainActor
struct StarterPromoVideoStudioView: View {
    var body: some View {
        PromoVideoStudio(project: StarterPromoVideoProject.make()) { context in
            Section("Selected Scene") {
                LabeledContent("Scene", value: context.selectedSceneTitle)
                LabeledContent(
                    "Position",
                    value: "\(context.selectedSceneIndex + 1) of \(context.sceneCount)"
                )
            }
        } videoConfigurationControls: { context in
            Section("Project") {
                LabeledContent("Format", value: context.preset.title)
                LabeledContent("Scenes", value: "3 registered")
                LabeledContent("Frame rate", value: "60 fps")
            }
        }
    }
}

@MainActor
private enum StarterPromoVideoProject {
    static func make() -> PromoVideoProject {
        PromoVideoProject(
            name: "StarterApp Launch Story",
            presets: [.verticalFullHD, .socialPortrait, .square],
            defaultPresetID: PromoVideoOutputPreset.verticalFullHD.id,
            defaultFrameRate: .fps60,
            defaultMotionIntensity: .balanced
        ) {
            PromoVideoSceneDefinition(
                id: "foundation",
                title: "Foundation",
                duration: 3.2,
                transition: .crossfade
            ) { context in
                HeroIntroPromoVideoScene(context: context) {
                    StarterPromoBackground()
                } brand: {
                    StarterPromoBrand()
                } message: {
                    StarterPromoMessage(
                        eyebrow: "PRODUCTION STARTER",
                        title: "Start with the hard parts handled.",
                        subtitle: "Commerce, themes, settings, onboarding, and developer studios are already wired."
                    )
                } visual: {
                    StarterPromoDashboard()
                }
            }

            PromoVideoSceneDefinition(
                id: "systems",
                title: "Systems",
                duration: 3.4,
                transition: .slide
            ) { context in
                LayeredScreensPromoVideoScene(context: context) {
                    StarterPromoBackground()
                } brand: {
                    StarterPromoBrand()
                } message: {
                    StarterPromoMessage(
                        eyebrow: "APPFOUNDATION 0.1.11",
                        title: "Build once. Reuse everywhere.",
                        subtitle: "Keep every app focused on its unique feature instead of rebuilding infrastructure."
                    )
                } primary: {
                    StarterPromoFeatureCard(
                        title: "StoreKit",
                        value: "Claude Paywall",
                        systemImage: "crown.fill",
                        accent: .cyan
                    )
                } secondary: {
                    StarterPromoFeatureCard(
                        title: "Appearance",
                        value: "Themes + Icons",
                        systemImage: "paintpalette.fill",
                        accent: .purple
                    )
                } tertiary: {
                    StarterPromoFeatureCard(
                        title: "Studios",
                        value: "PNG + MP4",
                        systemImage: "film.stack.fill",
                        accent: .mint
                    )
                }
            }

            PromoVideoSceneDefinition(
                id: "ship",
                title: "Ship",
                duration: 3.0,
                transition: .zoom
            ) { context in
                HeroIntroPromoVideoScene(context: context) {
                    StarterPromoBackground()
                } brand: {
                    StarterPromoBrand()
                } message: {
                    StarterPromoMessage(
                        eyebrow: "READY TO CUSTOMIZE",
                        title: "Replace the identity. Build the core. Ship.",
                        subtitle: "StarterApp gives the next project a polished and repeatable starting point."
                    )
                } visual: {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 132, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 280, height: 280)
                        .background(
                            LinearGradient(
                                colors: [.purple, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 76, style: .continuous)
                        )
                        .shadow(color: .cyan.opacity(0.35), radius: 36, y: 18)
                }
            }
        }
    }
}

private struct StarterPromoBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.04, blue: 0.12),
                    Color(red: 0.16, green: 0.09, blue: 0.39),
                    Color(red: 0.05, green: 0.45, blue: 0.62),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.purple.opacity(0.34))
                .frame(width: 720, height: 720)
                .blur(radius: 100)
                .offset(x: -330, y: -520)

            Circle()
                .fill(.cyan.opacity(0.24))
                .frame(width: 760, height: 760)
                .blur(radius: 110)
                .offset(x: 360, y: 560)
        }
    }
}

private struct StarterPromoBrand: View {
    var body: some View {
        Label(AppConfiguration.displayName, systemImage: "shippingbox.fill")
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(.white)
    }
}

private struct StarterPromoMessage: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(eyebrow)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.cyan)

            Text(title)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct StarterPromoDashboard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label("Production foundation", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                Image(systemName: "swift")
                    .font(.title.bold())
                    .foregroundStyle(.cyan)
            }

            HStack(spacing: 12) {
                StarterPromoMetric(value: "0.1.11", label: "AppFoundation")
                StarterPromoMetric(value: "iOS 26", label: "Deployment")
            }

            HStack(spacing: 12) {
                StarterPromoMetric(value: "Swift 6", label: "Language")
                StarterPromoMetric(value: "XcodeGen", label: "Project")
            }
        }
        .foregroundStyle(.white)
        .padding(26)
        .background(.black.opacity(0.38), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
    }
}

private struct StarterPromoMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.headline.bold())
            Text(label).font(.caption).foregroundStyle(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct StarterPromoFeatureCard: View {
    let title: String
    let value: String
    let systemImage: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(accent)
            Spacer()
            Text(title)
                .font(.headline.bold())
            Text(value)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.66))
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
    }
}
#endif
