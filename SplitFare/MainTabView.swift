import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "pencil.and.list.clipboard")
                }
            
            TripCostsView()
                .tabItem {
                    Label("Trip Costs", systemImage: "plus.circle")
                }
            
            TheSplitView()
                .tabItem {
                    Label("The Split", systemImage: "dollarsign.arrow.circlepath")
                }
        }
        .tint(.blue) // Calming blue accent for travel vibe
        .onAppear {
            // Subtle haptic on app launch for fluid feel
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Member.self, BudgetedExpense.self, AddedExpense.self], inMemory: true)
}
