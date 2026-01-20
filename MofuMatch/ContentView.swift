
import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    @State private var selectedItems: [PhotosPickerItem] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        VStack {
            Text("神経衰弱ゲーム")
                .font(.title)
                .padding()
            
            HStack(spacing: 20){
                Button(action: {
                    viewModel.startNewGame()
                }){
                    
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.largeTitle)
                    
                }
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 6,matching: .images){
                    HStack{
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Select Photo")
                    }
                    .font(.headline)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
            }
            .padding()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10){
                    ForEach(viewModel.cards){card in
                        CardView(card: card)
                            .frame(height: 120)
                            .onTapGesture {
                                viewModel.choose(card)
                                
                            }
                    }
                    .padding()
                }
            }
            
            .onChange( of: selectedItems) { _, newItems in
                Task {
                    var loadedImages: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data){
                            loadedImages.append(uiImage)
                        }
                    }
                    viewModel.startNewGame(with: loadedImages)
                }
                
            }
        }
    }
    
    
    struct CardView : View {
        let card: Card
        
        var body: some View {
            ZStack {
                if card.isFaceUp || card.isMatched{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                    Image(uiImage: card.content)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(10)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 3)
                        .foregroundColor(card.isMatched ? .green : .black)
                    
                }else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.cyan)
                }
            }
            
        }
    }
}
    #Preview {
        ContentView()
    }


