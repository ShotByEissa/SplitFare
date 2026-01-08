import Foundation
import SwiftData

@Model
class Member {
    var name: String
    
    @Relationship(deleteRule: .nullify, inverse: \BudgetedExpense.payer) var paidBudgetedExpenses: [BudgetedExpense] = []
    @Relationship(deleteRule: .nullify, inverse: \AddedExpense.payer) var paidAddedExpenses: [AddedExpense] = []
    @Relationship(deleteRule: .nullify, inverse: \AddedExpense.participants) var participatedAddedExpenses: [AddedExpense] = []
    
    init(name: String) {
        self.name = name
    }
}
