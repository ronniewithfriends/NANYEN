import NANYENCore
import SwiftUI

struct NANYENShareCardView: View {
    let card: ShareCard

    var body: some View {
        ZStack {
            cardBackground

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    MetalLogoText(text: card.appName, size: 31)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Spacer(minLength: 10)

                    Text(card.periodLabel)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .metalText()
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 12) {
                    Text(card.headline)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .metalText()
                        .lineLimit(3)
                        .minimumScaleFactor(0.52)

                    if let mainLine = card.mainLine {
                        Text(mainLine)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(accentColor)
                            .lineLimit(2)
                            .minimumScaleFactor(0.48)
                    } else {
                        Text("だいたいで、ちゃんと進んでる")
                            .font(.system(size: 31, weight: .black, design: .rounded))
                            .foregroundStyle(accentColor)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }

                    Text(card.caption)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .metalText()
                        .lineLimit(3)
                        .minimumScaleFactor(0.72)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.42))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Spacer(minLength: 0)

                Text(card.hashtags.joined(separator: " "))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .metalText()
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }
            .padding(22)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 12)
    }

    private var cardBackground: some View {
        ZStack {
            RetroCardBackground(accent: accentColor)

            Rectangle()
                .fill(accentColor)
                .frame(height: 10)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var accentColor: Color {
        switch card.accent {
        case .green:
            return AppPalette.green
        case .coral:
            return AppPalette.coral
        case .purple:
            return AppPalette.purple
        }
    }
}

enum AppPalette {
    static let pageBackground = Color(red: 1.0, green: 0.9, blue: 0.98)
    static let cardBase = Color(red: 1.0, green: 0.98, blue: 0.9)
    static let fieldBackground = Color(red: 1.0, green: 0.97, blue: 0.9)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.11)
    static let muted = Color(red: 0.43, green: 0.42, blue: 0.38)
    static let green = Color(red: 0.07, green: 0.58, blue: 0.34)
    static let coral = Color(red: 0.92, green: 0.31, blue: 0.28)
    static let purple = Color(red: 0.49, green: 0.26, blue: 0.78)
    static let gold = Color(red: 0.95, green: 0.7, blue: 0.24)
    static let neonCyan = Color(red: 0.14, green: 0.95, blue: 1.0)
    static let neonPink = Color(red: 1.0, green: 0.16, blue: 0.58)
}
