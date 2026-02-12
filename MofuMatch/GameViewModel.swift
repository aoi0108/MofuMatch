import SwiftUI

class GameViewModel: ObservableObject {

    @Published var cards: [Card] = []
    @Published var isGameOver = false
    @Published var turnCount = 0


    private var firstFlippedCardID: UUID?
    init() {
        startNewGame()
    }

    var uniquePetImages: [UIImage] {
        var seen = Set<String>()
        return cards.compactMap { card in
            guard seen.insert(card.matchId).inserted else { return nil }
            return card.content
        }
    }

    func startNewGame(with images: [UIImage]? = nil) {
        var newCards: [Card] = []

        if let userImages = images, !userImages.isEmpty {
            for image in userImages {
                let pairId = UUID().uuidString
                let card1 = Card(matchId: pairId, content: image)
                let card2 = Card(matchId: pairId, content: image)

                newCards.append(card1)
                newCards.append(card2)
            }
        }
        else {
            let emojis = ["🐱", "🐱", "🐶", "🐶", "🐰", "🐰"]
            for emoji in emojis {
                let image = UIImage(systemName: "heart.fill") ?? UIImage()
                let card = Card(matchId: emoji, content: image)
                newCards.append(card)
            }
        }

        cards = newCards.shuffled()
        firstFlippedCardID = nil
        isGameOver = false
        turnCount = 0
    }

    func choose(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isFaceUp || cards[index].isMatched { return }

        if let firstID = firstFlippedCardID,
           let firstIndex = cards.firstIndex(where: { $0.id == firstID }) {

            cards[index].isFaceUp = true
            firstFlippedCardID = nil
            turnCount += 1

            if cards[index].matchId == cards[firstIndex].matchId {
                cards[index].isMatched = true
                cards[firstIndex].isMatched = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.cards[index].isFaceUp = false
                    self.cards[firstIndex].isFaceUp = false
                }
            }

        } else {
            for i in cards.indices {
                if !cards[i].isMatched {
                    cards[i].isFaceUp = false
                }
            }

            cards[index].isFaceUp = true
            firstFlippedCardID = card.id
        }

        if cards.allSatisfy({ $0.isMatched == true}){
            isGameOver = true
        }
    }
}
