import Foundation
import Observation
import StoreKit

@Observable
@MainActor
final class ProStore {
    static let productID = "com.deitel.speedmath.pro.monthly"

    private(set) var product: Product?
    private(set) var isPro = false
    private(set) var isLoading = false
    private(set) var lastError: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        if CommandLine.arguments.contains("-forcePro") {
            isPro = true
        }
    }

    func startListening() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            lastError = error.localizedDescription
        }
        await refreshEntitlement()
    }

    func purchase() async {
        guard let product else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
        await refreshEntitlement()
    }

    private func refreshEntitlement() async {
        if CommandLine.arguments.contains("-forcePro") {
            isPro = true
            return
        }
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement, transaction.productID == Self.productID {
                isPro = transaction.revocationDate == nil
                return
            }
        }
        isPro = false
    }
}
