
import SwiftUI

struct ContentView: View {
    
    let card = Card(content: "🐱", isFaceUp: true)
    
    
    var body: some View {
        VStack {
            Text("神経衰弱ゲーム")
                .font(.title)
                .padding()
            CardView(card: card)
                .frame(height: 120)
                .padding()
        }
        
    }
}
struct CardView : View {
    let card: Card
    
    var body: some View {
        ZStack {
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 3)
                Text(card.content)
                    .font(.largeTitle)
            
            }else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

#Preview {
    ContentView()
}
