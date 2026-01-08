import Foundation
import SwiftData

@Model
class Member {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}