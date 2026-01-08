import Foundation
import SwiftData

@Model
class AddedExpense {
    var category: String
    var amount: Double
    @Relationship var payer: Member
    @Relationship var participants: [Member] // Who to split among (default all, exclude some)
    
    init(category: String, amount: Double, payer: Member, participants: [Member]) {
        self.category = category
        self.amount = amount
        self.payer = payer
        self.participants = participants
    }
}