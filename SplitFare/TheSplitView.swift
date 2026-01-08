import SwiftUI
import SwiftData

struct TheSplitView: View {
    @Query private var members: [Member]
    @Query private var budgetedExpenses: [BudgetedExpense]
    @Query private var addedExpenses: [AddedExpense]
    
    var body: some View {
        NavigationStack {
            List {
                if members.isEmpty {
                    Text("Add members and expenses to see the split.")
                } else {
                    let totalExpenses = calculateTotalExpenses()
                    
                    Section(header: Text("Summary")) {
                        Text("Total Expenses: $\(String(format: "%.2f", totalExpenses))")
                    }
                    
                    Section(header: Text("Balances")) {
                        ForEach(members) { member in
                            let paid = calculateAmountPaid(by: member)
                            let owedShare = calculateOwedShare(for: member)
                            let balance = paid - owedShare // Positive: overpaid (owed money), Negative: underpaid (owes money)
                            HStack {
                                Text(member.name)
                                Spacer()
                                if balance > 0 {
                                    Text("Owed $\(String(format: "%.2f", balance))")
                                        .foregroundColor(.green)
                                } else if balance < 0 {
                                    Text("Owes $\(String(format: "%.2f", -balance))")
                                        .foregroundColor(.red)
                                } else {
                                    Text("Settled")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Settlements")) {
                        ForEach(calculateSettlements(), id: \.self) { settlement in
                            Text(settlement)
                        }
                    }
                }
            }
            .navigationTitle("The Split")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share") {
                        // TODO: Implement export as PDF/text (future iteration)
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                    }
                }
            }
        }
        .fontDesign(.rounded)
        .background(Color(UIColor.systemBackground))
    }
    
    private func calculateTotalExpenses() -> Double {
        let budgetedTotal = budgetedExpenses.reduce(0) { $0 + $1.amount }
        let addedTotal = addedExpenses.reduce(0) { $0 + $1.amount }
        return budgetedTotal + addedTotal
    }
    
    private func calculateAmountPaid(by member: Member) -> Double {
        let memberName = member.name
        let budgetedPaid = budgetedExpenses.filter { $0.payer.name == memberName }.reduce(0) { $0 + $1.amount }
        let addedPaid = addedExpenses.filter { $0.payer.name == memberName }.reduce(0) { $0 + $1.amount }
        return budgetedPaid + addedPaid
    }
    
    private func calculateOwedShare(for member: Member) -> Double {
        let memberName = member.name
        let budgetedShare = budgetedExpenses.reduce(0) { sum, expense in
            return sum + (expense.amount / Double(members.count))
        }
        let addedShare = addedExpenses.reduce(0) { sum, expense in
            if expense.participants.contains(where: { $0.name == memberName }) {
                return sum + (expense.amount / Double(expense.participants.count))
            }
            return sum
        }
        return budgetedShare + addedShare
    }
    
    private func calculateSettlements() -> [String] {
        var balances: [String: Double] = [:]
        
        for member in members {
            let paid = calculateAmountPaid(by: member)
            let owed = calculateOwedShare(for: member)
            balances[member.name] = paid - owed // Positive: creditor (overpaid), Negative: debtor (underpaid)
        }
        
        var settlements: [String] = []
        
        // Sort by balance ascending (debtors first, most negative to most positive)
        let sortedBalances = balances.sorted { $0.value < $1.value }
        var i = 0 // Debtor index (negative)
        var j = sortedBalances.count - 1 // Creditor index (positive)
        
        while i < j {
            let debtorEntry = sortedBalances[i]
            let creditorEntry = sortedBalances[j]
            
            let debtor = debtorEntry.key
            let creditor = creditorEntry.key
            var debtorBalance = debtorEntry.value
            var creditorBalance = creditorEntry.value
            
            if debtorBalance >= 0 {
                i += 1
                continue
            }
            if creditorBalance <= 0 {
                j -= 1
                continue
            }
            
            let amount = min(-debtorBalance, creditorBalance)
            settlements.append("\(debtor) pays \(creditor) $\(String(format: "%.2f", amount))")
            
            balances[debtor]! += amount // Reduce debt
            balances[creditor]! -= amount // Reduce credit
            
            debtorBalance += amount
            creditorBalance -= amount
            
            if debtorBalance >= 0 { i += 1 }
            if creditorBalance <= 0 { j -= 1 }
        }
        
        if settlements.isEmpty {
            settlements.append("Everyone is settled up!")
        }
        
        return settlements
    }
}

#Preview {
    TheSplitView()
        .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self], inMemory: true)
}
