import Foundation
import SwiftData

@Model
class BudgetedExpense {
    var category: String
    var amount: Double
    @Relationship var payer: Member
    
    init(category: String, amount: Double, payer: Member) {
        self.category = category
        self.amount = amount
        self.payer = payer
    }
}