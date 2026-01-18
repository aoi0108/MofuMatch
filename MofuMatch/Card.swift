import Foundation
import SwiftUI

struct Card : Identifiable {
    let id = UUID()
    var content: String
    var isFaceUp = false
    var isMatched = false
}
