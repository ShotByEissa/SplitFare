import SwiftUI
import SwiftData

struct TheSplitView: View {
    @Query private var members: [Member]
    @Query private var budgetedExpenses: [BudgetedExpense]
    @Query private var addedExpenses: [AddedExpense]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Summary")) {
                    Text("Total Budgeted: $0.00") // Placeholder
                    Text("Total Added: $0.00") // Placeholder
                    Text("Grand Total: $0.00") // Placeholder
                }
                
                Section(header: Text("Settlements")) {
                    Text("No settlements yet") // Placeholder for calculations
                }
            }
            .navigationTitle("The Split")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share") {
                        // TODO: Export as PDF/text
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                    }
                }
            }
        }
        .fontDesign(.rounded)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    TheSplitView()
        .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self], inMemory: true)
}