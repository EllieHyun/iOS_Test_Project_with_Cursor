//
//  testProjectWithCursorApp.swift
//  testProjectWithCursor
//
//  Created by 현예림 on 7/6/25.
//

import SwiftUI

@main
struct testProjectWithCursorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
