import NANYENCore
import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct NANYENMVPView: View {
    @State private var monthlyIncomeText = "260000"
    @State private var fixedCostText = "150000"
    @State private var amountText = "1200"
    @State private var selectedDate = Date()
    @State private var showCalendar = false
    @State private var activeScreen: ActiveScreen?
    @State private var shareImageItem: PNGShareItem?
    @State private var selectedShareRange: ShareRange = .day
    @State private var selectedGenre: EntryGenre = .dailyGoods
    @State private var monthlyPlans: [String: MonthlyPlan] = [
        NANYENMVPView.monthKey(for: Date()): MonthlyPlan(incomeYen: 260_000, fixedCostYen: 150_000)
    ]
    @State private var entries: [MoneyEntry] = [
        MoneyEntry(date: Calendar.current.startOfDay(for: Date()), genre: .food, amountYen: -1_200),
        MoneyEntry(date: Calendar.current.startOfDay(for: Date()), genre: .dailyGoods, amountYen: -800)
    ]

    private var monthlyIncome: Int {
        planForSelectedMonth.incomeYen
    }

    private var fixedCost: Int {
        planForSelectedMonth.fixedCostYen
    }

    private var planForSelectedMonth: MonthlyPlan {
        monthlyPlans[Self.monthKey(for: selectedDate)] ?? MonthlyPlan(incomeYen: 260_000, fixedCostYen: 150_000)
    }

    private var monthlyIncomeBinding: Binding<String> {
        Binding(
            get: { monthlyIncomeText },
            set: {
                monthlyIncomeText = $0
                saveVisiblePlan()
            }
        )
    }

    private var fixedCostBinding: Binding<String> {
        Binding(
            get: { fixedCostText },
            set: {
                fixedCostText = $0
                saveVisiblePlan()
            }
        )
    }

    private var freeMonthly: Int {
        monthlyIncome - fixedCost
    }

    private var dailyPace: Double {
        Double(max(0, freeMonthly)) / Double(Self.daysInMonth(for: selectedDate))
    }

    private var weeklyPace: Double {
        dailyPace * 7
    }

    private var selectedDaySpend: Int {
        spend(for: entries(on: selectedDate))
    }

    private var selectedWeekSpend: Int {
        spend(for: entries(inWeekOf: selectedDate))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                switch activeScreen {
                case .settings:
                    settingsScreen
                case .share:
                    shareScreen
                case nil:
                    mainScreen
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
        }
        .background(RetroBackground().ignoresSafeArea())
    }

    private var mainScreen: some View {
        VStack(alignment: .leading, spacing: 14) {
            topBar

            if showCalendar {
                calendarPanel
            }

            entryPanel

            Button {
                withAnimation(.snappy) {
                    activeScreen = .share
                }
            } label: {
                Label("結果をシェア！", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(NANYENPrimaryButtonStyle())

            entriesPanel
        }
    }

    private var settingsScreen: some View {
        VStack(alignment: .leading, spacing: 14) {
            fullScreenHeader(title: "設定")
            monthlyPlanPanel
        }
    }

    private var shareScreen: some View {
        VStack(alignment: .leading, spacing: 14) {
            fullScreenHeader(title: "結果をシェア")
            sharePanel
        }
    }

    private func fullScreenHeader(title: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                MetalLogoText(text: "NANYEN", size: 30)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .metalText()
            }

            Spacer()

            Button {
                withAnimation(.snappy) {
                    activeScreen = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(NANYENIconButtonStyle())
            .accessibilityLabel("\(title)を閉じる")
        }
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    activeScreen = .settings
                    loadPlanTexts(for: selectedDate)
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(NANYENIconButtonStyle())
            .accessibilityLabel("設定を開く")

            VStack(alignment: .leading, spacing: 4) {
                MetalLogoText(text: "NANYEN", size: 42)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(Self.longDate(selectedDate))
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .metalText()
            }

            Spacer(minLength: 10)

            Button {
                withAnimation(.snappy) {
                    showCalendar.toggle()
                }
            } label: {
                Image(systemName: "calendar")
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(NANYENIconButtonStyle())
            .accessibilityLabel("カレンダーを開く")
        }
    }

    private var monthlyPlanPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("月のだいたい設定")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                Text("この月の設定")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .metalText()
            }

            HStack(spacing: 10) {
                MoneyField(title: "月の収入", text: monthlyIncomeBinding, symbol: "arrow.down.circle.fill")
                MoneyField(title: "月の固定費", text: fixedCostBinding, symbol: "house.fill")
            }

            HStack(spacing: 8) {
                MetricView(title: "自由に使える", value: Self.yen(freeMonthly))
                MetricView(title: "1日ペース", value: Self.yen(Int(dailyPace.rounded())))
                MetricView(title: "1週間ペース", value: Self.yen(Int(weeklyPace.rounded())))
            }
        }
        .panelStyle()
    }

    private var entryPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日の入力")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                Text(Self.longDate(selectedDate))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .metalText()
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("金額", systemImage: "yensign.circle.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .metalText()

                HStack(spacing: 4) {
                    Text("¥")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    TextField("0", text: $amountText)
                        .moneyKeyboard()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                .padding(.horizontal, 12)
                .frame(height: 78)
                .background(AppPalette.fieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(EntryGenre.allCases) { genre in
                    Button {
                        selectedGenre = genre
                    } label: {
                        Text(genre.title)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(GenreButtonStyle(isSelected: selectedGenre == genre, isIncome: genre == .income))
                }
            }

            Button {
                recordEntry()
            } label: {
                Text("記録する")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(NANYENPrimaryButtonStyle())
        }
        .panelStyle()
    }

    private var sharePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ビジュアルカード作成")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                Text(selectedShareRange.periodLabel(for: selectedDate))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .metalText()
            }

            HStack(spacing: 8) {
                ForEach(ShareRange.allCases) { range in
                    Button {
                        withAnimation(.snappy) {
                            selectedShareRange = range
                        }
                    } label: {
                        Text(range.buttonTitle)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                    }
                    .buttonStyle(ShareRangeButtonStyle(isSelected: selectedShareRange == range))
                }
            }

            PaceReportCard(
                title: selectedShareRange.cardTitle,
                period: selectedShareRange.periodLabel(for: selectedDate),
                spend: selectedShareSpend,
                pace: selectedSharePace
            )

            if let shareImageItem {
                ShareLink(
                    item: shareImageItem,
                    subject: Text("NANYEN"),
                    message: Text(shareText),
                    preview: SharePreview("NANYEN", image: Image(systemName: "square.fill"))
                ) {
                    Label("画像で共有する", systemImage: "photo.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(NANYENSecondaryButtonStyle())
            } else {
                Button {
                    renderShareImage()
                } label: {
                    Label("画像を作成", systemImage: "photo.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(NANYENSecondaryButtonStyle())
            }
        }
        .panelStyle()
        .onAppear(perform: renderShareImage)
        .onChange(of: selectedShareRange) { _, _ in renderShareImage() }
        .onChange(of: selectedDate) { _, _ in renderShareImage() }
        .onChange(of: entries.count) { _, _ in renderShareImage() }
        .onChange(of: monthlyIncomeText) { _, _ in renderShareImage() }
        .onChange(of: fixedCostText) { _, _ in renderShareImage() }
    }

    private var calendarPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("日付を選ぶ")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                Text("過去の日付にも記録できます")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .metalText()
            }

            HStack(spacing: 8) {
                Button {
                    moveSelectedMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 42, height: 38)
                }
                .buttonStyle(NANYENIconButtonStyle())

                Text(Self.monthLabel(for: selectedDate))
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)

                Button {
                    moveSelectedMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 42, height: 38)
                }
                .buttonStyle(NANYENIconButtonStyle())
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .metalText()
                        .frame(height: 20)
                }

                ForEach(0..<Self.firstWeekdayOffset(for: selectedDate), id: \.self) { _ in
                    Color.clear.frame(height: 38)
                }

                ForEach(1...Self.daysInMonth(for: selectedDate), id: \.self) { day in
                    let date = Self.date(inSameMonthAs: selectedDate, day: day)
                    Button {
                        selectDate(date)
                        withAnimation(.snappy) {
                            showCalendar = false
                        }
                    } label: {
                        Text("\(day)")
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                    }
                    .buttonStyle(CalendarDayButtonStyle(isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate), hasEntry: !entries(on: date).isEmpty))
                }
            }
        }
        .panelStyle()
    }

    private var entriesPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("選んだ日の記録")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                Text("\(entries(on: selectedDate).count)件")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .metalText()
            }

            let dayEntries = entries(on: selectedDate)
            if dayEntries.isEmpty {
                EntryRow(title: "まだ記録なし", amount: nil, onDelete: nil)
            } else {
                ForEach(dayEntries) { entry in
                    EntryRow(title: entry.genre.title, amount: entry.amountYen) {
                        deleteEntry(entry)
                    }
                }
            }
        }
        .panelStyle()
    }

    private var selectedShareSpend: Int {
        switch selectedShareRange {
        case .day:
            return selectedDaySpend
        case .week:
            return selectedWeekSpend
        }
    }

    private var selectedSharePace: Double {
        switch selectedShareRange {
        case .day:
            return dailyPace
        case .week:
            return weeklyPace
        }
    }

    private var shareText: String {
        let period = selectedShareRange.periodLabel(for: selectedDate)
        let result = Self.paceResult(
            spend: selectedShareSpend,
            pace: selectedSharePace,
            seed: "\(period)-\(selectedShareRange.cardTitle)"
        )
        return """
        NANYEN \(period)
        \(result.sticker)
        \(result.title)
        \(result.number)
        \(result.copy)
        \(Self.shareHashtags)
        """
    }

    private func recordEntry() {
        let amount = Int(amountText.filter(\.isNumber)) ?? 0
        guard amount > 0 else { return }
        let signedAmount = selectedGenre == .income ? amount : -amount
        entries.append(MoneyEntry(date: Calendar.current.startOfDay(for: selectedDate), genre: selectedGenre, amountYen: signedAmount))
        amountText = ""
    }

    private func deleteEntry(_ entry: MoneyEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    @MainActor
    private func renderShareImage() {
        let card = PaceReportCard(
            title: selectedShareRange.cardTitle,
            period: selectedShareRange.periodLabel(for: selectedDate),
            spend: selectedShareSpend,
            pace: selectedSharePace
        )
        .frame(width: 1080, height: 1080)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 1

        #if os(iOS)
        guard let data = renderer.uiImage?.pngData() else { return }
        #elseif os(macOS)
        guard
            let tiff = renderer.nsImage?.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let data = bitmap.representation(using: .png, properties: [:])
        else { return }
        #else
        return
        #endif

        shareImageItem = PNGShareItem(
            data: data,
            filename: "NANYEN-\(selectedShareRange.rawValue)-\(Self.monthKey(for: selectedDate)).png"
        )
    }

    private func selectDate(_ date: Date) {
        selectedDate = date
        loadPlanTexts(for: date)
    }

    private func moveSelectedMonth(by value: Int) {
        let calendar = Calendar.current
        let moved = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
        selectDate(moved)
    }

    private func loadPlanTexts(for date: Date) {
        let plan = monthlyPlans[Self.monthKey(for: date)] ?? MonthlyPlan(incomeYen: 260_000, fixedCostYen: 150_000)
        monthlyIncomeText = String(plan.incomeYen)
        fixedCostText = String(plan.fixedCostYen)
    }

    private func saveVisiblePlan() {
        monthlyPlans[Self.monthKey(for: selectedDate)] = MonthlyPlan(
            incomeYen: Int(monthlyIncomeText.filter(\.isNumber)) ?? 0,
            fixedCostYen: Int(fixedCostText.filter(\.isNumber)) ?? 0
        )
    }

    private func entries(on date: Date) -> [MoneyEntry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private func entries(inWeekOf date: Date) -> [MoneyEntry] {
        let week = Self.weekDates(for: date)
        return entries.filter { entry in
            week.contains { Calendar.current.isDate($0, inSameDayAs: entry.date) }
        }
    }

    private func spend(for entries: [MoneyEntry]) -> Int {
        max(0, -entries.reduce(0) { $0 + $1.amountYen })
    }

    fileprivate static func yen(_ value: Int) -> String {
        let sign = value > 0 ? "+" : value < 0 ? "-" : ""
        return "\(sign)¥\(abs(value).formatted())"
    }

    fileprivate static func yen(_ value: Double) -> String {
        yen(Int(value.rounded()))
    }

    fileprivate static func paceResult(spend: Int, pace: Double, seed: String = "") -> PaceResult {
        let diff = Int(pace.rounded()) - spend
        if diff >= 0 {
            let line = underPaceLines[variantIndex(spend: spend, pace: pace, seed: seed, count: underPaceLines.count)]
            return PaceResult(
                accent: AppPalette.green,
                title: line.title,
                quote: line.quote,
                number: "\(yen(diff)) 余裕",
                copy: line.copy,
                sticker: line.sticker,
                comicMark: line.comicMark,
                spark: line.spark
            )
        }
        let line = overPaceLines[variantIndex(spend: spend, pace: pace, seed: seed, count: overPaceLines.count)]
        return PaceResult(
            accent: AppPalette.coral,
            title: line.title,
            quote: line.quote,
            number: "\(yen(abs(diff))) 多め",
            copy: line.copy,
            sticker: line.sticker,
            comicMark: line.comicMark,
            spark: line.spark
        )
    }

    private static func variantIndex(spend: Int, pace: Double, seed: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let seedValue = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let raw = abs(spend * 31 + Int(pace.rounded()) * 17 + seedValue)
        return raw % count
    }

    private static let underPaceLines: [PaceLine] = [
        PaceLine(title: "ペースより軽め", quote: "財布、今日だけ羽生えてる", copy: "この余裕、ちょっと映画の主人公っぽい。", sticker: "✦ 軽やか判定 ✦", comicMark: "♡", spark: "キラ"),
        PaceLine(title: "いい感じに低空飛行", quote: "お金の減り方、上品", copy: "派手じゃないけど強い。こういう日があとで効く。", sticker: "余裕あり", comicMark: "♪", spark: "nice"),
        PaceLine(title: "予算と仲良し", quote: "今日は財布と握手できる", copy: "ちゃんと残ってる。財布もたぶん拍手してる。", sticker: "平和", comicMark: "◎", spark: "ぱち"),
        PaceLine(title: "だいたい勝ち", quote: "出費、ちゃんと小走り", copy: "暴走してない。えらいというより、地味に強い。", sticker: "小走り支出", comicMark: "☆", spark: "ok"),
        PaceLine(title: "かなり穏やか", quote: "財布が深呼吸してる", copy: "今日の支出、温度でいうとぬるめ。かなり助かる。", sticker: "すやすや財布", comicMark: "〜", spark: "ほっ"),
        PaceLine(title: "ペース守れてる", quote: "未来の自分が少し笑った", copy: "あとで効くやつ。地味だけど、こういうの好き。", sticker: "未来加点", comicMark: "＋", spark: "ふふ"),
        PaceLine(title: "余白あり", quote: "財布にまだ余白がある", copy: "余白って大事。予定外のアイスも理論上いける。", sticker: "余白発見", comicMark: "□", spark: "余"),
        PaceLine(title: "今日は堅実", quote: "支出がちゃんと整列してる", copy: "並び方がきれい。家計の体育委員みたいな日。", sticker: "整列中", comicMark: "!!", spark: "ピシ"),
        PaceLine(title: "いい守備", quote: "財布の守備範囲、広め", copy: "攻めすぎず守れてる。今日は守備職人。", sticker: "守備成功", comicMark: "◇", spark: "守"),
        PaceLine(title: "レア勝ち", quote: "財布、今日だけドヤ顔", copy: "これは10回に1回のてへぺろ勝ち。調子のってOK。", sticker: "✦ てへぺろ勝ち ✦", comicMark: "♡", spark: "てへ")
    ]

    private static let overPaceLines: [PaceLine] = [
        PaceLine(title: "ペースより多め", quote: "財布、ちょっと叫んでた", copy: "でも記録した。そこが今日のちゃんとした部分。", sticker: "まあヨシ案件", comicMark: "?!", spark: "わっ"),
        PaceLine(title: "勢いあり", quote: "支出、今日は前のめり", copy: "前のめりな日もある。問題は気づけたこと。", sticker: "前のめり", comicMark: "!!", spark: "どん"),
        PaceLine(title: "ちょい派手", quote: "財布にスポットライト当たった", copy: "目立つ日だった。次の一手でちゃんと戻せる。", sticker: "派手め", comicMark: "★", spark: "ギラ"),
        PaceLine(title: "予算より元気", quote: "支出のテンション高め", copy: "今日はお金がライブ会場にいた。記録はできた。", sticker: "テンション高", comicMark: "♪", spark: "wow"),
        PaceLine(title: "すこし暴れた", quote: "財布が一瞬だけ遠い目", copy: "遠い目の日もある。見なかったことにはしてない。", sticker: "遠い目", comicMark: "...", spark: "しー"),
        PaceLine(title: "多めの日", quote: "レシートが急に主張してきた", copy: "主張強め。でも記録したから、ちゃんと回収済み。", sticker: "回収済み", comicMark: "↗", spark: "回収"),
        PaceLine(title: "今日は攻めた", quote: "財布、攻めの姿勢", copy: "攻めた日は守りに戻れる。まずは現状把握。", sticker: "攻めの日", comicMark: "▲", spark: "攻"),
        PaceLine(title: "ちょいオーバー", quote: "お金、少し早歩き", copy: "走ってはいない。早歩き。まだ会話できる。", sticker: "早歩き支出", comicMark: "≡", spark: "速"),
        PaceLine(title: "にぎやか会計", quote: "財布の中で祭り開催", copy: "祭りの後に記録できる人、だいぶ強い。", sticker: "祭り後", comicMark: "＊", spark: "祭"),
        PaceLine(title: "レア自虐", quote: "財布、今日は照れてる", copy: "10回に1回のてへぺろ回。笑って次いこ。", sticker: "てへぺろ回", comicMark: "?!", spark: "てへ")
    ]

    private static func longDate(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 2026)年\(components.month ?? 1)月\(components.day ?? 1)日"
    }

    private static func monthLabel(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return "\(components.year ?? 2026)年\(components.month ?? 1)月"
    }

    fileprivate static func monthKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", components.year ?? 2026, components.month ?? 1)
    }

    fileprivate static func shortDate(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.month, .day], from: date)
        return "\(components.month ?? 1)/\(components.day ?? 1)"
    }

    fileprivate static func weekLabel(for date: Date) -> String {
        let week = weekDates(for: date)
        guard let first = week.first, let last = week.last else { return shortDate(date) }
        return "\(shortDate(first))-\(shortDate(last))"
    }

    private static func weekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfMonth, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private static func daysInMonth(for date: Date) -> Int {
        Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    private static func firstWeekdayOffset(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let first = calendar.date(from: components) ?? date
        return calendar.component(.weekday, from: first) - 1
    }

    private static func date(inSameMonthAs date: Date, day: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = day
        return calendar.startOfDay(for: calendar.date(from: components) ?? date)
    }

    fileprivate static let shareHashtags = "#NANYEN #今日の何円 #今週の何円"
}

private enum ActiveScreen {
    case settings
    case share
}

private enum ShareRange: String, CaseIterable, Identifiable {
    case day
    case week

    var id: String { rawValue }

    var buttonTitle: String {
        switch self {
        case .day:
            return "1日"
        case .week:
            return "1週間"
        }
    }

    var cardTitle: String {
        switch self {
        case .day:
            return "今日のカード"
        case .week:
            return "今週のカード"
        }
    }

    @MainActor
    func periodLabel(for date: Date) -> String {
        switch self {
        case .day:
            return NANYENMVPView.shortDate(date)
        case .week:
            return NANYENMVPView.weekLabel(for: date)
        }
    }
}

private struct PNGShareItem: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { item in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(item.filename)
            try item.data.write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}

private struct RetroBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.93, blue: 0.99),
                    Color(red: 0.76, green: 0.95, blue: 1.0),
                    Color(red: 1.0, green: 0.58, blue: 0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [AppPalette.neonCyan.opacity(0.26), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 300
            )

            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                Path { path in
                    let horizon = height * 0.57
                    for index in 0...9 {
                        let y = horizon + CGFloat(index * index) * 5
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    for index in -6...6 {
                        let startX = width / 2 + CGFloat(index) * 24
                        path.move(to: CGPoint(x: startX, y: horizon))
                        path.addLine(to: CGPoint(x: width / 2 + CGFloat(index) * width * 0.18, y: height))
                    }
                }
                .stroke(Color(red: 0.0, green: 0.66, blue: 0.95).opacity(0.34), lineWidth: 1.1)
            }
        }
    }
}

struct MetalLogoText: View {
    let text: String
    let size: CGFloat

    var body: some View {
        ZStack {
            logoLayer
                .foregroundStyle(Color(red: 0.14, green: 0.05, blue: 0.24))
                .offset(x: 3.4, y: 3.6)

            logoLayer
                .foregroundStyle(AppPalette.neonPink.opacity(0.92))
                .offset(x: 2.0, y: 2.1)

            logoLayer
                .foregroundStyle(Color(red: 0.46, green: 0.53, blue: 0.64))
                .offset(x: 1.0, y: 1.2)

            logoLayer
                .foregroundStyle(.white.opacity(0.92))
                .offset(x: -1.2, y: -1.4)

            logoLayer
                .foregroundStyle(AppPalette.neonCyan.opacity(0.7))
                .offset(x: 1.4, y: -1.2)

            logoLayer
                .foregroundStyle(AppPalette.neonPink.opacity(0.36))
                .offset(x: -1.5, y: 1.4)

            logoLayer
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            Color(red: 0.93, green: 0.96, blue: 1.0),
                            Color(red: 0.72, green: 0.78, blue: 0.86),
                            Color(red: 0.34, green: 0.42, blue: 0.54),
                            .white,
                            Color(red: 0.76, green: 0.81, blue: 0.88)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .white.opacity(0.7), radius: 1, x: 0, y: -1)
                .shadow(color: AppPalette.neonCyan.opacity(0.38), radius: 9, x: 0, y: 4)

            logoLayer
                .foregroundStyle(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.92), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask {
                    Rectangle()
                        .frame(height: max(2, size * 0.18))
                        .rotationEffect(.degrees(-12))
                        .offset(y: -size * 0.16)
                }
        }
        .rotationEffect(.degrees(-1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(text))
    }

    private var logoLayer: some View {
        Text(text)
            .font(.system(size: size, weight: .heavy, design: .default))
            .fontWidth(.expanded)
            .tracking(max(1.4, size * 0.045))
    }
}

struct RetroCardBackground: View {
    let accent: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.88),
                    Color(red: 0.86, green: 0.97, blue: 1.0),
                    Color(red: 1.0, green: 0.74, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [accent.opacity(0.28), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 210
            )

            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height
                Path { path in
                    let horizon = height * 0.58
                    for index in 0...7 {
                        let y = horizon + CGFloat(index * index) * 4.8
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    for index in -5...5 {
                        let startX = width / 2 + CGFloat(index) * 18
                        path.move(to: CGPoint(x: startX, y: horizon))
                        path.addLine(to: CGPoint(x: width / 2 + CGFloat(index) * width * 0.18, y: height))
                    }
                }
                .stroke(AppPalette.neonCyan.opacity(0.22), lineWidth: 1)
            }

            VStack {
                Spacer()
                LinearGradient(
                    colors: [AppPalette.neonPink.opacity(0.2), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 130)
            }
        }
    }
}

private enum EntryGenre: String, CaseIterable, Identifiable {
    case dailyGoods
    case food
    case fun
    case work
    case income

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dailyGoods:
            return "日用品"
        case .food:
            return "食事"
        case .fun:
            return "娯楽"
        case .work:
            return "仕事"
        case .income:
            return "収入"
        }
    }
}

private struct MoneyEntry: Identifiable {
    let id = UUID()
    let date: Date
    let genre: EntryGenre
    let amountYen: Int
}

private struct MonthlyPlan {
    let incomeYen: Int
    let fixedCostYen: Int
}

private struct MetricView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .metalText()
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .metalText()
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.black.opacity(0.07), lineWidth: 1)
        )
    }
}

private struct PaceReportCard: View {
    let title: String
    let period: String
    let spend: Int
    let pace: Double

    private var result: PaceResult {
        NANYENMVPView.paceResult(spend: spend, pace: pace, seed: "\(period)-\(title)")
    }

    var body: some View {
        ZStack {
            RetroCardBackground(accent: result.accent)
            Rectangle()
                .fill(result.accent)
                .frame(height: 9)
                .frame(maxHeight: .infinity, alignment: .top)

            Text(result.comicMark)
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(result.accent.opacity(0.24))
                .rotationEffect(.degrees(-12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 46)
                .padding(.trailing, 20)

            Text("✧")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(AppPalette.neonPink.opacity(0.28))
                .rotationEffect(.degrees(14))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 24)
                .padding(.bottom, 48)

            Text(result.spark)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(AppPalette.neonCyan.opacity(0.42))
                .rotationEffect(.degrees(8))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 30)
                .padding(.bottom, 92)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    MetalLogoText(text: "NANYEN", size: 17)
                    Spacer()
                    Text(period)
                }
                .font(.system(size: 12, weight: .black, design: .rounded))
                .metalText()

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 9) {
                    Text(result.sticker)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(result.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.72))
                        .clipShape(Capsule())

                    Text(result.quote)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .metalText()
                        .lineLimit(2)
                        .minimumScaleFactor(0.58)

                    Text(result.title)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .metalText()
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(result.number)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(result.accent)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)

                    Text(result.copy)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .metalText()
                        .lineLimit(3)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 0)

                Text(NANYENMVPView.shareHashtags)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .metalText()
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }
            .padding(18)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: AppPalette.neonPink.opacity(0.22), radius: 14, x: 0, y: 9)
    }
}

private struct PaceResult {
    let accent: Color
    let title: String
    let quote: String
    let number: String
    let copy: String
    let sticker: String
    let comicMark: String
    let spark: String
}

private struct PaceLine {
    let title: String
    let quote: String
    let copy: String
    let sticker: String
    let comicMark: String
    let spark: String
}

private struct EntryRow: View {
    let title: String
    let amount: Int?
    let onDelete: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let amount {
                Text(NANYENMVPView.yen(amount))
                    .foregroundStyle(amount >= 0 ? AppPalette.green : AppPalette.coral)
                if let onDelete {
                    Button("取消") {
                        onDelete()
                    }
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppPalette.coral)
                    .padding(.horizontal, 8)
                    .frame(height: 28)
                    .background(AppPalette.coral.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
            } else {
                Text("ぼちぼちでOK")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .metalText()
            }
        }
        .font(.system(size: 13, weight: .black, design: .rounded))
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MoneyField: View {
    let title: String
    let text: Binding<String>
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .metalText()

            HStack(spacing: 4) {
                Text("¥")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .metalText()
                TextField("0", text: text)
                    .moneyKeyboard()
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .metalText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.horizontal, 12)
            .frame(height: 50)
            .background(AppPalette.fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

private struct NANYENPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .black, design: .rounded))
            .metalText()
            .frame(height: 48)
            .background(
                LinearGradient(
                    colors: configuration.isPressed
                        ? [Color.white.opacity(0.82), AppPalette.neonCyan.opacity(0.42)]
                        : [Color.white, Color(red: 1.0, green: 0.83, blue: 0.94), AppPalette.neonCyan.opacity(0.62)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.86), lineWidth: 1)
            )
            .shadow(color: AppPalette.neonPink.opacity(configuration.isPressed ? 0.12 : 0.28), radius: 12, x: 0, y: 6)
    }
}

private struct NANYENSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .black, design: .rounded))
            .metalText()
            .frame(height: 46)
            .background(configuration.isPressed ? Color.white.opacity(0.72) : Color.white.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppPalette.neonCyan.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: AppPalette.neonCyan.opacity(0.14), radius: 10, x: 0, y: 5)
    }
}

private struct NANYENIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .black))
            .metalText()
            .background(configuration.isPressed ? .white.opacity(0.6) : .white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.black.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct ShareRangeButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .black, design: .rounded))
            .metalText()
            .background(
                configuration.isPressed
                    ? AppPalette.neonCyan.opacity(0.28)
                    : (isSelected ? AppPalette.neonCyan.opacity(0.34) : Color.white.opacity(0.94))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? AppPalette.neonPink.opacity(0.56) : AppPalette.neonCyan.opacity(0.18), lineWidth: 1)
            )
    }
}

private struct GenreButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isIncome: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .metalText()
            .background(
                configuration.isPressed
                    ? Color.white.opacity(0.68)
                    : (isSelected ? (isIncome ? AppPalette.green.opacity(0.16) : AppPalette.neonPink.opacity(0.13)) : Color.white.opacity(0.92))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? (isIncome ? AppPalette.green.opacity(0.72) : AppPalette.neonPink.opacity(0.58)) : AppPalette.neonCyan.opacity(0.18), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? AppPalette.neonPink.opacity(0.12) : .clear, radius: 8, x: 0, y: 4)
    }
}

private struct CalendarDayButtonStyle: ButtonStyle {
    let isSelected: Bool
    let hasEntry: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .black, design: .rounded))
            .metalText()
            .background(isSelected ? AppPalette.neonCyan.opacity(0.34) : Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(alignment: .bottom) {
                if hasEntry && !isSelected {
                    Rectangle()
                        .fill(AppPalette.gold)
                        .frame(height: 4)
                }
            }
    }
}

extension View {
    func metalText() -> some View {
        self
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        .white,
                        Color(red: 0.94, green: 0.97, blue: 1.0),
                        Color(red: 0.62, green: 0.69, blue: 0.78),
                        .white,
                        Color(red: 0.77, green: 0.84, blue: 0.93)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color(red: 0.18, green: 0.1, blue: 0.28).opacity(0.54), radius: 0, x: 0.9, y: 0.9)
            .shadow(color: AppPalette.neonPink.opacity(0.36), radius: 0, x: -0.7, y: 0.8)
            .shadow(color: AppPalette.neonCyan.opacity(0.42), radius: 0, x: 0.7, y: -0.7)
            .shadow(color: .white.opacity(0.5), radius: 0.5, x: 0, y: -0.5)
            .shadow(color: Color(red: 0.18, green: 0.1, blue: 0.28).opacity(0.22), radius: 4, x: 0, y: 2)
    }

    func panelStyle() -> some View {
        self
            .padding(14)
            .background(.white.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppPalette.neonCyan.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: AppPalette.neonPink.opacity(0.18), radius: 18, x: 0, y: 8)
    }

    @ViewBuilder
    func moneyKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.numberPad)
        #else
        self
        #endif
    }
}
