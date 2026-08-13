import StoreKit

@Observable
@MainActor
final class TipStore {
    private static let productIds = ["coffee", "bento", "pizza"]

    private(set) var products: [Product] = []
    private(set) var loadFailed = false
    var showThanks = false

    private var updatesTask: Task<Void, Never>?

    init() {
        // Finish transactions delivered outside the purchase flow (e.g. an
        // unfinished consumable redelivered on launch, or Ask to Buy approval).
        updatesTask = Task {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
            }
        }
    }

    func loadProducts() async {
        guard products.isEmpty else { return }
        do {
            let loaded = try await Product.products(for: Self.productIds)
            products = loaded.sorted { $0.price < $1.price }
            loadFailed = loaded.isEmpty
        } catch {
            loadFailed = true
        }
    }

    func purchase(_ product: Product) async {
        guard let result = try? await product.purchase() else { return }
        switch result {
        case .success(.verified(let transaction)):
            await transaction.finish()
            showThanks = true
        case .success(.unverified(let transaction, _)):
            // Finish even unverified transactions so StoreKit stops redelivering.
            await transaction.finish()
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
    }
}
