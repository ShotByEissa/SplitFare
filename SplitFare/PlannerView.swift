import SwiftUI
import SwiftData

struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var members: [Member]
    @Query private var budgetedExpenses: [BudgetedExpense]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Group Members")) {
                    ForEach(members) { member in
                        Text(member.name)
                    }
                    // Placeholder for add member
                }
                
                Section(header: Text("Budgeted Expenses")) {
                    ForEach(budgetedExpenses) { expense in
                        HStack {
                            Text(expense.category)
                            Spacer()
                            Text("$\(expense.amount, specifier: "%.2f")")
                            Text(" (Paid by \(expense.payer.name))")
                        }
                    }
                    // Placeholder for add expense
                }
            }
            .navigationTitle("Planner")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // TODO: Add member or expense form
                        let haptic = UIImpactFeedbackGenerator(style: .medium)
                        haptic.impactOccurred()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fontDesign(.rounded) // Adaptive, readable typography
        .background(Color(UIColor.systemBackground)) // Supports dark mode
    }
}

#Preview {
    PlannerView()
        .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self], inMemory: true)
}