
import SwiftUI
import PhotosUI

// MARK: - Neumorphism Design System

struct Neu {
    static let bg = Color(red: 0.95, green: 0.92, blue: 0.88)
    static let darkShadow = Color(red: 0.80, green: 0.76, blue: 0.70)
    static let lightShadow = Color(red: 1.0, green: 0.98, blue: 0.95)
    static let accent = Color(red: 0.70, green: 0.50, blue: 0.38)
    static let matched = Color(red: 0.58, green: 0.72, blue: 0.52)
    static let textPrimary = Color(red: 0.38, green: 0.30, blue: 0.24)
    static let textSecondary = Color(red: 0.60, green: 0.54, blue: 0.48)
}

// MARK: - Neumorphic Modifiers

struct NeuRaised: ViewModifier {
    var radius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(Neu.bg)
                    .shadow(color: Neu.darkShadow.opacity(0.45), radius: 8, x: 6, y: 6)
                    .shadow(color: Neu.lightShadow.opacity(0.9), radius: 8, x: -6, y: -6)
            )
    }
}

struct NeuInset: ViewModifier {
    var radius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(Neu.bg)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(Neu.bg, lineWidth: 4)
                            .shadow(color: Neu.darkShadow.opacity(0.4), radius: 4, x: 4, y: 4)
                            .clipShape(RoundedRectangle(cornerRadius: radius))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(Neu.bg, lineWidth: 4)
                            .shadow(color: Neu.lightShadow.opacity(0.8), radius: 4, x: -4, y: -4)
                            .clipShape(RoundedRectangle(cornerRadius: radius))
                    )
            )
    }
}

extension View {
    func neuRaised(radius: CGFloat = 16) -> some View {
        modifier(NeuRaised(radius: radius))
    }
    func neuInset(radius: CGFloat = 16) -> some View {
        modifier(NeuInset(radius: radius))
    }
}

// MARK: - Content View

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    @State private var selectedItems: [PhotosPickerItem] = []

    private var columns: [GridItem] {
        let count = viewModel.cards.count
        let colCount: Int
        if count <= 4 {
            colCount = 2
        } else if count <= 6 {
            colCount = 3
        } else {
            colCount = 4
        }
        return Array(repeating: GridItem(.flexible(), spacing: 14), count: colCount)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            controlSection
            cardGridSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Neu.bg.ignoresSafeArea())
        .onChange(of: selectedItems) { _, newItems in
            Task {
                var loadedImages: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        loadedImages.append(uiImage)
                    }
                }
                viewModel.startNewGame(with: loadedImages)
            }
        }
        .overlay {
            if viewModel.isGameOver {
                CelebrationOverlay(petImages: viewModel.uniquePetImages, turnCount: viewModel.turnCount, pairCount: viewModel.cards.count / 2) {
                    viewModel.startNewGame()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("MofuMatch")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Neu.textPrimary)

            Text("Memory Game")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Neu.textSecondary)
                .tracking(2)
                .textCase(.uppercase)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Controls

    private var controlSection: some View {
        HStack(spacing: 24) {
            // Restart Button
            Button {
                viewModel.startNewGame()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Neu.accent)
                    .frame(width: 48, height: 48)
            }
            .neuRaised(radius: 14)

            // Photo Picker
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 8,
                matching: .images
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Select Photos")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Neu.accent)
                .padding(.horizontal, 20)
                .frame(height: 48)
            }
            .neuRaised(radius: 14)

            // Turn Counter
            VStack(spacing: 2) {
                Text("\(viewModel.turnCount)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Neu.accent)
                Text("turns")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Neu.textSecondary)
            }
            .frame(width: 48, height: 48)
            .neuInset(radius: 14)

            // Match Counter
            VStack(spacing: 2) {
                Text("\(viewModel.cards.filter { $0.isMatched }.count / 2)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Neu.accent)
                Text("/ \(viewModel.cards.count / 2)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Neu.textSecondary)
            }
            .frame(width: 48, height: 48)
            .neuInset(radius: 14)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Card Grid

    private var cardGridSection: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.cards) { card in
                    CardView(card: card)
                        .aspectRatio(0.75, contentMode: .fit)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.choose(card)
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Card View

struct CardView: View {
    let card: Card


    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                faceUpCard
            } else {
                faceDownCard
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
    }

    private var faceUpCard: some View {
        GeometryReader { geo in
            let photoHeight = geo.size.height * 0.82
            let marginHeight = geo.size.height * 0.18

            ZStack {
                // Card base
                RoundedRectangle(cornerRadius: 16)
                    .fill(Neu.bg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Neu.bg, lineWidth: 4)
                            .shadow(color: Neu.darkShadow.opacity(0.35), radius: 4, x: 4, y: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Neu.bg, lineWidth: 4)
                            .shadow(color: Neu.lightShadow.opacity(0.7), radius: 4, x: -4, y: -4)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    )

                // Polaroid layout
                VStack(spacing: 0) {
                    // Photo area
                    Image(uiImage: card.content)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width - 16, height: photoHeight - 12)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.92, green: 0.89, blue: 0.85), lineWidth: 1.5)
                        )

                    // Polaroid bottom margin
                    Spacer()
                        .frame(height: marginHeight - 4)
                }
                .padding(.top, 8)
                .padding(.horizontal, 8)

                // Match overlay
                if card.isMatched {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Neu.matched.opacity(0.15))

                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Neu.matched.opacity(0.5), lineWidth: 2.5)

                    // Paw stamp scatter
                    pawStamps(in: geo.size)
                }
            }
        }
    }

    private func pawStamps(in size: CGSize) -> some View {
        let positions: [(CGFloat, CGFloat, Double, CGFloat)] = [
            (0.25, 0.30, -15, 20),
            (0.70, 0.25, 22, 18),
            (0.45, 0.55, -8, 22),
            (0.20, 0.72, 30, 16),
            (0.75, 0.70, -20, 19),
        ]

        return ZStack {
            ForEach(0..<positions.count, id: \.self) { i in
                let (xRatio, yRatio, angle, fontSize) = positions[i]
                Image(systemName: "pawprint.fill")
                    .font(.system(size: fontSize))
                    .foregroundColor(Neu.matched.opacity(0.55))
                    .rotationEffect(.degrees(angle))
                    .position(x: size.width * xRatio, y: size.height * yRatio)
            }
        }
    }

    private var faceDownCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Neu.bg)
                .shadow(color: Neu.darkShadow.opacity(0.45), radius: 8, x: 6, y: 6)
                .shadow(color: Neu.lightShadow.opacity(0.9), radius: 8, x: -6, y: -6)

            // Subtle pattern on card back
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Neu.accent.opacity(0.06),
                            Neu.accent.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(10)

            Image(systemName: "pawprint.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(Neu.accent.opacity(0.2))
        }
    }
}

// MARK: - Celebration Overlay

struct CelebrationOverlay: View {
    let petImages: [UIImage]
    let turnCount: Int
    let pairCount: Int
    let onTryAgain: () -> Void

    private var starCount: Int {
        if turnCount <= pairCount { return 3 }
        if turnCount <= pairCount * 2 { return 2 }
        return 1
    }

    @State private var showModal = false
    @State private var trophyBounce = false
    @State private var confettiActive = false

    var body: some View {
        ZStack {
            // Dimmed background
            Neu.bg.opacity(0.75)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        confettiActive = true
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                        showModal = true
                    }
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.5)) {
                        trophyBounce = true
                    }
                }

            // Confetti
            ConfettiView(isActive: confettiActive)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Modal
            if showModal {
                celebrationModal
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
        }
    }

    private var celebrationModal: some View {
        VStack(spacing: 20) {
            // Trophy
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Text("🏆")
                    .font(.system(size: 56))
                    .offset(y: trophyBounce ? -6 : 6)
            }

            // Photo collage
            if !petImages.isEmpty {
                photoCollage
            }

            // Title
            Text("Clear!")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(Neu.textPrimary)

            Text("You've matched all the cards!")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Neu.textSecondary)

            Text("\(turnCount) turns")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Neu.accent)

            // Stars
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    StarView(filled: i < starCount, delay: Double(i) * 0.15)
                }
            }
            .padding(.top, 4)

            // Try Again Button
            Button {
                onTryAgain()
            } label: {
                Text("Try Again")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Neu.accent)
                            .shadow(color: Neu.accent.opacity(0.4), radius: 8, y: 4)
                    )
            }
            .padding(.top, 8)
        }
        .padding(32)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Neu.bg)
                .shadow(color: Neu.darkShadow.opacity(0.5), radius: 20, x: 10, y: 10)
                .shadow(color: Neu.lightShadow, radius: 20, x: -10, y: -10)
        )
    }

    private var photoCollage: some View {
        let angles: [Double] = [-12, 8, -5, 15, -18, 10, -8, 14]
        let offsets: [(CGFloat, CGFloat)] = [
            (-20, -8), (22, -12), (-10, 10), (18, 6),
            (-25, -4), (15, 8), (-8, -10), (20, 4)
        ]

        return ZStack {
            ForEach(0..<min(petImages.count, 8), id: \.self) { i in
                Image(uiImage: petImages[i])
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white, lineWidth: 2.5)
                    )
                    .shadow(color: Neu.darkShadow.opacity(0.3), radius: 3, x: 2, y: 2)
                    .rotationEffect(.degrees(angles[i % angles.count]))
                    .offset(
                        x: offsets[i % offsets.count].0,
                        y: offsets[i % offsets.count].1
                    )
            }
        }
        .frame(height: 80)
    }
}

// MARK: - Star Animation

struct StarView: View {
    let filled: Bool
    let delay: Double
    @State private var appeared = false

    var body: some View {
        Image(systemName: filled ? "star.fill" : "star")
            .font(.system(size: 22))
            .foregroundStyle(
                filled
                ? LinearGradient(
                    colors: [Color.yellow, Color.orange],
                    startPoint: .top,
                    endPoint: .bottom
                )
                : LinearGradient(
                    colors: [Neu.darkShadow.opacity(0.4), Neu.darkShadow.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: filled ? .yellow.opacity(0.4) : .clear, radius: 4)
            .scaleEffect(appeared ? 1.0 : 0.0)
            .rotationEffect(.degrees(appeared ? 0 : -45))
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.6 + delay)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    let isActive: Bool
    let count = 50

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    ConfettiPiece(
                        screenWidth: geo.size.width,
                        screenHeight: geo.size.height,
                        index: i,
                        isActive: isActive
                    )
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let index: Int
    let isActive: Bool

    @State private var yOffset: CGFloat = 0
    @State private var xDrift: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    private let colors: [Color] = [
        Color(red: 0.70, green: 0.50, blue: 0.38),
        Color(red: 0.58, green: 0.72, blue: 0.52),
        Color.yellow,
        Color.orange,
        Color(red: 0.80, green: 0.58, blue: 0.48),
        Color(red: 0.65, green: 0.55, blue: 0.42),
    ]

    // Deterministic hash: returns 0.0 ..< 1.0
    private func hash(_ seed: Int) -> Double {
        let x = sin(Double(seed) * 78.233 + 12.9898) * 43758.5453
        return x - floor(x)
    }

    private var startX: CGFloat { hash(index * 7 + 3) * screenWidth }
    private var size: CGFloat { 8 + hash(index * 13 + 1) * 6 }
    private var color: Color { colors[index % colors.count] }
    private var delay: Double { hash(index * 11 + 5) * 0.8 }
    private var duration: Double { 2.5 + hash(index * 17 + 9) * 1.5 }
    private var drift: CGFloat { -60 + hash(index * 23 + 7) * 120 }
    private var spin: Double { 360 + hash(index * 29 + 2) * 360 }

    var body: some View {
        Image(systemName: "pawprint.fill")
            .font(.system(size: size))
            .foregroundColor(color)
            .opacity(opacity)
            .position(x: startX + xDrift, y: -20 + yOffset)
            .rotationEffect(.degrees(rotation))
            .onChange(of: isActive) { _, active in
                guard active else { return }
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    yOffset = screenHeight + 60
                    xDrift = drift
                }
                withAnimation(.linear(duration: duration).delay(delay)) {
                    rotation = spin
                }
                withAnimation(.easeIn(duration: 0.8).delay(delay + duration - 0.8)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    ContentView()
}
