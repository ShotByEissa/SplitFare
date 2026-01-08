import SwiftUI
import SwiftData

@main
struct SplitFareApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self])
        }
    }
}
