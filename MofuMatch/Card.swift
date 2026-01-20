import Foundation
import SwiftUI

struct Card : Identifiable {
    let id = UUID()
    var matchId: String
    var content: UIImage
    var isFaceUp = false
    var isMatched = false
}
