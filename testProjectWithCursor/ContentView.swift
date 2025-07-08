//
//  ContentView.swift
//  testProjectWithCursor
//
//  Created by 현예림 on 7/6/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        TabView(selection: $selectedTab) {
            // 로컬 데이터 화면
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("로컬 데이터")
            }
            .tag(0)
            
            // 백엔드 API 연동 화면
            UserListView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("사용자 목록")
                }
                .tag(1)
            
            // Figma 디자인 화면
            FigmaDesignView()
                .tabItem {
                    Image(systemName: "paintbrush")
                    Text("Figma 디자인")
                }
                .tag(2)
            
            // Apple MCP 화면
            MCPView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Apple MCP")
                }
                .tag(3)
            
            // 자연어 명령 화면
            VoiceCommandView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("자연어 명령")
                }
                .tag(4)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
