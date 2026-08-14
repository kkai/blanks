import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(TipStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private static let bodyFont = Font.custom("IowanOldStyle-Roman", size: 17, relativeTo: .body)

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            ZStack {
                Image(decorative: "optionback")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                List {
                    Section {
                        Text("If you love the game, you can leave a tip to cover development costs! Any tip at all helps a lot!")
                            .font(Self.bodyFont)
                            .foregroundStyle(.secondary)
                    }

                    Section("Tips") {
                        if store.products.isEmpty {
                            if store.loadFailed {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tips are unavailable right now.")
                                        .foregroundStyle(.secondary)
                                    Button("Try Again") {
                                        Task {
                                            await store.loadProducts()
                                        }
                                    }
                                }
                                .font(Self.bodyFont)
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
                                    .font(Self.bodyFont)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Tip Jar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            await store.loadProducts()
        }
        .alert("Thank You!", isPresented: $store.showThanks) {
            Button("You're Welcome") {}
        } message: {
            Text("Your tip helps keep Blanks going.")
        }
        .alert("Purchase Failed", isPresented: $store.purchaseFailed) {
            Button("OK") {}
        } message: {
            Text("The purchase could not be completed. You were not charged.")
        }
    }
}
