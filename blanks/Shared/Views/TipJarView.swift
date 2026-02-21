import SwiftUI
import StoreKit

struct TipJarView: View {
    private let productIds = ["coffee", "bento", "pizza"]
    @State private var products: [Product] = []

    var body: some View {
        ZStack {
            Image("optionback")
                .resizable()
                .ignoresSafeArea()

            List {
                Section {
                    Text("If you love the game, you can leave a tip to cover development costs! Any tip at all helps a lot!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Tips") {
                    ForEach(products) { product in
                        Button {
                            Task {
                                try? await purchase(product)
                            }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Tip Jar")
        .task {
            products = (try? await Product.products(for: productIds)) ?? []
        }
    }

    private func purchase(_ product: Product) async throws {
        let _ = try await product.purchase()
    }
}
