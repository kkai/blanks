import SwiftUI
import StoreKit

struct SwiftUIView: View {
    
    private let productIds = ["coffee", "bento", "pizza"]
    //@EnvironmentObject private var subscriptionManager: IAPManager
    private let subscriptionManager = IAPManager()
    @State var products: [Product] = []
    
    var dismiss: () -> Void = {}
    
    var body: some View {
        ZStack {
            Image("optionback")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack{
                VStack {
                    Text("Tip Jar")
                        .font(Font.custom("TimesNewRomanPSMT", size:20))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("If you love the game, you can leave a tip to cover development cost! Any tip at all helps a lot!")
                            .font(Font.custom("TimesNewRomanPSMT", size:20))
                            .fontWeight(.light)
                    }
                    .padding()
                    
                }
                VStack(spacing: 20) {
                    ForEach(products) { product in
                        Button {
                            Task {
                                do {
                                    try await self.purchase(product)
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Text("\(product.displayPrice) - \(product.displayName)")
                                .font(Font.custom("TimesNewRomanPSMT", size:20))
                        }
                    }
                }
            }
        }.task {
            do {
                try await self.loadProducts()
                print(products)
            } catch {
                print(error)
            }
        }
    }
    
    private func loadProducts() async throws {
        self.products = try await Product.products(for: productIds)
    }
    
    private func purchase(_ product: Product) async throws {
        do {
            let result = try await product.purchase()
            print(result)
        } catch {
            print(error)
        }
    }
}



struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}

