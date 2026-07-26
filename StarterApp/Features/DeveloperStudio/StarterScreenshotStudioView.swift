#if DEBUG
import AppFoundation
import SwiftUI

@MainActor
struct StarterScreenshotStudioView: View {
    @State private var screenshotPurchases = PurchaseManager.screenshotPreview(
        configuration: AppConfiguration.purchaseConfiguration,
        products: AppConfiguration.simulatedProducts
    )

    var body: some View {
        ScreenshotStudio(catalog: makeCatalog()) { context in
            Section("Selected Screenshot") {
                LabeledContent("Scene", value: context.selectedScreenshotTitle)
                LabeledContent("Rendering", value: "Direct SwiftUI")
            }
        } appConfigurationControls: { context in
            Section("Campaign") {
                LabeledContent("Preset", value: context.preset.title)
                LabeledContent("Screenshots", value: "3 registered")
                LabeledContent("Locale", value: "English")
            }
        }
    }

    private func makeCatalog() -> ScreenshotCatalog {
        ScreenshotCatalog(
            appName: AppConfiguration.displayName,
            presets: [.iPhone69Portrait, .iPhone65Portrait],
            locales: [.english],
            defaultPresetID: ScreenshotDevicePreset.iPhone69Portrait.id,
            defaultLocaleID: ScreenshotStudioLocale.english.id,
            defaultScreenshotID: "hero"
        ) {
            ScreenshotDefinition(
                id: "hero",
                title: "Hero",
                filename: "01 Start with the hard parts handled"
            ) {
                StarterHeroScreenshot()
            }

            ScreenshotDefinition(
                id: "systems",
                title: "Shared Systems",
                filename: "02 Production systems already included"
            ) {
                StarterSystemsScreenshot()
            }

            ScreenshotDefinition(
                id: "pro",
                title: "Claude Paywall",
                filename: "03 Upgrade with a focused Pro plan"
            ) {
                ClaudePaywallScreenshotTemplate(
                    purchases: screenshotPurchases,
                    configuration: AppConfiguration.claudePaywallConfiguration
                )
            }
        }
    }
}

@MainActor
private struct StarterHeroScreenshot: View {
    var body: some View {
        HeroScreenshotTemplate {
            StarterStudioBackground()
        } brand: {
            StarterStudioBrand()
        } message: {
            ScreenshotTemplateMessage(
                title: "Build the app.\nSkip the boilerplate.",
                subtitle: "A production SwiftUI foundation with commerce, themes, settings, and studios ready to customize.",
                foreground: .white,
                secondaryForeground: .white.opacity(0.72)
            )
        } visual: {
            StarterStudioVisual()
        } footer: {
            ScreenshotTemplateFooter(
                "iOS 26 · Swift 6 · XcodeGen",
                systemImage: "checkmark.seal.fill",
                tint: .cyan,
                foreground: .white
            )
        }
    }
}

@MainActor
private struct StarterSystemsScreenshot: View {
    var body: some View {
        LayeredCardsScreenshotTemplate {
            StarterStudioBackground()
        } brand: {
            StarterStudioBrand()
        } message: {
            ScreenshotTemplateMessage(
                title: "Start once.\nReuse everywhere.",
                subtitle: "Replace the app identity and core feature while the production foundation stays consistent.",
                foreground: .white,
                secondaryForeground: .white.opacity(0.72)
            )
        } primary: {
            StarterStudioSystemCard(
                title: "Commerce",
                subtitle: "StoreKit 2",
                systemImage: "creditcard.fill",
                accent: .cyan
            )
        } secondary: {
            StarterStudioSystemCard(
                title: "Themes",
                subtitle: "Free + Pro",
                systemImage: "paintpalette.fill",
                accent: .purple
            )
        } tertiary: {
            StarterStudioSystemCard(
                title: "Studios",
                subtitle: "Image + video",
                systemImage: "photo.stack.fill",
                accent: .mint
            )
        } footer: {
            ScreenshotTemplateFooter(
                "Powered by AppFoundation",
                systemImage: "shippingbox.fill",
                tint: .cyan,
                foreground: .white
            )
        }
    }
}

private struct StarterStudioBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.05, blue: 0.14),
                    Color(red: 0.18, green: 0.11, blue: 0.42),
                    Color(red: 0.11, green: 0.55, blue: 0.75),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.purple.opacity(0.35))
                .frame(width: 620, height: 620)
                .blur(radius: 80)
                .offset(x: -260, y: -430)

            Circle()
                .fill(.cyan.opacity(0.28))
                .frame(width: 700, height: 700)
                .blur(radius: 100)
                .offset(x: 280, y: 520)
        }
    }
}

private struct StarterStudioBrand: View {
    var body: some View {
        Label(AppConfiguration.displayName, systemImage: "shippingbox.fill")
            .font(.system(size: 22, weight: .black, design: .rounded))
            .foregroundStyle(.white)
    }
}

private struct StarterStudioVisual: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label("Production foundation", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                Image(systemName: "swift")
                    .font(.title2.bold())
                    .foregroundStyle(.cyan)
            }

            Text("The hard parts are already handled.")
                .font(.system(size: 30, weight: .black, design: .rounded))

            HStack(spacing: 12) {
                StarterStudioMetric(value: "0.1.11", label: "AppFoundation")
                StarterStudioMetric(value: "Swift 6", label: "Strict concurrency")
            }
        }
        .foregroundStyle(.white)
        .padding(28)
        .background(.black.opacity(0.36), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
    }
}

private struct StarterStudioMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.headline.bold())
            Text(label).font(.caption).foregroundStyle(.white.opacity(0.66))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct StarterStudioSystemCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(accent)
            Spacer()
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.66))
        }
        .foregroundStyle(.white)
        .padding(24)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
    }
}
#endif
