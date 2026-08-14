import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(TipStore.self) private var store

    var body: some View {
        @Bindable var store = store

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
                    if store.products.isEmpty {
                        if store.loadFailed {
                            Text("Tips are unavailable right now. Please try again later.")
                                .foregroundStyle(.secondary)
                        } else {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        ForEach(store.products) { product in
                            Button {
                                Task {
                                    await store.purchase(product)
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
            }
            .scrollContentBackground(.hidden)
            .font(.custom("TimesNewRomanPSMT", size: 20))
        }
        .navigationTitle("Tip Jar")
        .task {
            await store.loadProducts()
        }
        .alert("Thank You!", isPresented: $store.showThanks) {
            Button("You're Welcome") {}
        } message: {
            Text("Your tip helps keep Blanks going.")
        }
    }
}
