import SwiftUI
import SwiftData

struct AddedCostsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var members: [Member]
    @Query private var addedExpenses: [AddedExpense]
    
    @State private var showingAddAddedExpenseSheet = false
    
    @State private var newCategory = ""
    @State private var newAmount = ""
    @State private var selectedPayer: Member?
    @State private var selectedParticipants: Set<Member> = []
    
    let suggestedCategories = ["Gas", "Food", "Tickets", "Misc"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(addedExpenses) { expense in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(expense.category)
                            Spacer()
                            Text("$\(String(format: "%.2f", expense.amount))")
                        }
                        Text("Paid by \(expense.payer.name)")
                            .font(.subheadline)
                        let sortedNames = expense.participants.sorted { $0.name < $1.name }.map { $0.name }.joined(separator: ", ")
                        Text("Split among: \(sortedNames)")
                            .font(.subheadline)
                    }
                }
                .onDelete(perform: deleteAddedExpenses)
                
                if !members.isEmpty {
                    Button("Add Added Expense") {
                        selectedParticipants = Set(members) // Default to all
                        newCategory = ""
                        newAmount = ""
                        selectedPayer = nil
                        showingAddAddedExpenseSheet = true
                    }
                } else {
                    Text("Add members in Planner first.")
                }
                
                let totalAdded = addedExpenses.reduce(0) { $0 + $1.amount }
                Section(header: Text("Total Added Costs")) {
                    Text("$\(String(format: "%.2f", totalAdded))")
                }
            }
            .navigationTitle("Added Costs")
        }
        .fontDesign(.rounded)
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingAddAddedExpenseSheet) {
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
                
                Section(header: Text("Split Among (exclude if needed)")) {
                    ForEach(members.sorted { $0.name < $1.name }) { member in
                        Toggle(member.name, isOn: Binding(
                            get: { selectedParticipants.contains(member) },
                            set: { isOn in
                                if isOn {
                                    selectedParticipants.insert(member)
                                } else {
                                    selectedParticipants.remove(member)
                                }
                            }
                        ))
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button("Save") {
                        if let amount = Double(newAmount), let payer = selectedPayer, !newCategory.isEmpty, !selectedParticipants.isEmpty {
                            let sortedParticipants = selectedParticipants.sorted { $0.name < $1.name }
                            let expense = AddedExpense(category: newCategory, amount: amount, payer: payer, participants: Array(sortedParticipants))
                            modelContext.insert(expense)
                            newCategory = ""
                            newAmount = ""
                            selectedPayer = nil
                            selectedParticipants = []
                            showingAddAddedExpenseSheet = false
                            let haptic = UIImpactFeedbackGenerator(style: .medium)
                            haptic.impactOccurred()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .frame(maxWidth: .infinity)
                    
                    Button("Cancel") {
                        showingAddAddedExpenseSheet = false
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(.thinMaterial)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(28)
        }
    }
    
    private func deleteAddedExpenses(at offsets: IndexSet) {
        for offset in offsets {
            let expense = addedExpenses[offset]
            modelContext.delete(expense)
        }
    }
}

#Preview {
    AddedCostsView()
        .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self], inMemory: true)
}
