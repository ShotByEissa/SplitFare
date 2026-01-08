import SwiftUI
import SwiftData

struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var members: [Member]
    @Query private var budgetedExpenses: [BudgetedExpense]
    
    @State private var showingAddMemberSheet = false
    @State private var showingAddBudgetedExpenseSheet = false
    @State private var showingResetConfirmation = false
    
    @State private var newMemberName = ""
    
    @State private var newCategory = ""
    @State private var newAmount = ""
    @State private var selectedPayer: Member?
    
    let suggestedCategories = ["Flights", "Hotel", "Car", "Gas", "Food", "Tickets", "Misc"]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Group Members")) {
                    ForEach(members) { member in
                        Text(member.name)
                    }
                    .onDelete(perform: deleteMembers)
                    
                    Button("Add Member") {
                        showingAddMemberSheet = true
                    }
                }
                
                Section(header: Text("Budgeted Expenses")) {
                    ForEach(budgetedExpenses) { expense in
                        HStack {
                            Text(expense.category)
                            Spacer()
                            Text("$\(String(format: "%.2f", expense.amount))")
                            Text(" (Paid by \(expense.payer.name))")
                        }
                    }
                    .onDelete(perform: deleteBudgetedExpenses)
                    
                    Button("Add Budgeted Expense") {
                        newCategory = ""
                        newAmount = ""
                        selectedPayer = nil
                        showingAddBudgetedExpenseSheet = true
                    }
                }
                
                if !members.isEmpty {
                    let totalBudget = budgetedExpenses.reduce(0) { $0 + $1.amount }
                    let perPerson = totalBudget / Double(members.count)
                    
                    Section(header: Text("Budget Summary")) {
                        Text("Total Budget: $\(String(format: "%.2f", totalBudget))")
                        Text("Per Person Estimate: $\(String(format: "%.2f", perPerson))")
                    }
                }
                
                Section {
                    Button("Reset All Data") {
                        showingResetConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Planner")
        }
        .fontDesign(.rounded) // Adaptive, readable typography
        .background(Color(UIColor.systemBackground)) // Supports dark mode
        .sheet(isPresented: $showingAddMemberSheet) {
            Form {
                Section {
                    TextField("Name", text: $newMemberName)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button("Save") {
                        if !newMemberName.isEmpty && !members.contains(where: { $0.name == newMemberName }) {
                            let newMember = Member(name: newMemberName)
                            modelContext.insert(newMember)
                            newMemberName = ""
                            showingAddMemberSheet = false
                            let haptic = UIImpactFeedbackGenerator(style: .medium)
                            haptic.impactOccurred()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .frame(maxWidth: .infinity)
                    
                    Button("Cancel") {
                        showingAddMemberSheet = false
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(.thinMaterial)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingAddBudgetedExpenseSheet) {
            if members.isEmpty {
                Text("Add members first to assign a payer.")
                    .padding()
            } else {
                Form {
                    Section {
                        Picker("Who", selection: $selectedPayer) {
                            Text("Select Payer").tag(Member?.none)
                            ForEach(members) { member in
                                Text(member.name).tag(member as Member?)
                            }
                        }
                    }
                    
                    Section {
                        Picker("What", selection: $newCategory) {
                            Text("Select Category").tag("")
                            ForEach(suggestedCategories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        if newCategory.isEmpty || suggestedCategories.contains(newCategory) {
                            TextField("Custom Category (optional)", text: $newCategory)
                        } else {
                            TextField("Custom Category", text: $newCategory)
                        }
                    }
                    
                    Section {
                        TextField("How Much", text: $newAmount)
                            .keyboardType(.decimalPad)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 12) {
                        Button("Save") {
                            if let amount = Double(newAmount), let payer = selectedPayer, !newCategory.isEmpty {
                                let expense = BudgetedExpense(category: newCategory, amount: amount, payer: payer)
                                modelContext.insert(expense)
                                newCategory = ""
                                newAmount = ""
                                selectedPayer = nil
                                showingAddBudgetedExpenseSheet = false
                                let haptic = UIImpactFeedbackGenerator(style: .medium)
                                haptic.impactOccurred()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .frame(maxWidth: .infinity)
                        
                        Button("Cancel") {
                            showingAddBudgetedExpenseSheet = false
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(.thinMaterial)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(28)
            }
        }
        .alert("Reset All Data?", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                for member in members {
                    modelContext.delete(member)
                }
                let haptic = UIImpactFeedbackGenerator(style: .heavy)
                haptic.impactOccurred()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all members and expenses.")
        }
    }
    
    private func deleteMembers(at offsets: IndexSet) {
        for offset in offsets {
            let member = members[offset]
            modelContext.delete(member)
        }
    }
    
    private func deleteBudgetedExpenses(at offsets: IndexSet) {
        for offset in offsets {
            let expense = budgetedExpenses[offset]
            modelContext.delete(expense)
        }
    }
}

#Preview {
    PlannerView()
        .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self], inMemory: true)
}
