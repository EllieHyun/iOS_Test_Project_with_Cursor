import SwiftUI

struct UserListView: View {
    @StateObject private var networkService = NetworkService()
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAddUser = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("사용자 목록을 불러오는 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("오류 발생")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("다시 시도") {
                            loadUsers()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(users) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .refreshable {
                        await loadUsersAsync()
                    }
                }
            }
            .navigationTitle("사용자 목록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(networkService: networkService) {
                    Task {
                        await loadUsersAsync()
                    }
                }
            }
        }
        .onAppear {
            loadUsers()
        }
    }
    
    private func loadUsers() {
        Task {
            await loadUsersAsync()
        }
    }
    
    private func loadUsersAsync() async {
        isLoading = true
        errorMessage = nil
        
        do {
            users = try await networkService.fetchUsers()
        } catch {
            errorMessage = "사용자 목록을 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct AddUserView: View {
    @ObservedObject var networkService: NetworkService
    let onUserAdded: () -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("사용자 정보") {
                    TextField("이름", text: $name)
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: addUser) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("사용자 추가")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(name.isEmpty || email.isEmpty || isLoading)
                }
            }
            .navigationTitle("새 사용자")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addUser() {
        Task {
            isLoading = true
            
            do {
                _ = try await networkService.createUser(name: name, email: email)
                onUserAdded()
                dismiss()
            } catch {
                // 에러 처리 (실제 앱에서는 알림을 표시)
                print("사용자 추가 실패: \(error)")
            }
            
            isLoading = false
        }
    }
}

#Preview {
    UserListView()
} 