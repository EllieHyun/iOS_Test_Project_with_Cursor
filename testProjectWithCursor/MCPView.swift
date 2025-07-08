import SwiftUI

struct MCPView: View {
    @StateObject private var viewModel = MCPViewModel()
    @State private var searchQuery = ""
    @State private var selectedTool: MCPTool = .searchItems
    @State private var showingToolDetails = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 헤더
                headerView
                
                // 도구 선택
                toolSelectionView
                
                // 검색 영역
                searchView
                
                // 결과 영역
                resultsView
                
                // 컨텍스트 히스토리
                contextHistoryView
            }
            .navigationTitle("Apple MCP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("컨텍스트 클리어") {
                        viewModel.clearContextHistory()
                    }
                    .font(.caption)
                }
            }
        }
        .onAppear {
            viewModel.updateContextHistory()
        }
    }
    
    // 헤더 뷰
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple MCP")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Model Context Protocol")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 상태 표시
                HStack(spacing: 8) {
                    Circle()
                        .fill(viewModel.isLoading ? .orange : .green)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.isLoading ? "실행 중" : "준비")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // 도구 선택 뷰
    private var toolSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MCP 도구 선택")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MCPTool.allCases, id: \.self) { tool in
                        toolButton(tool)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    
    // 도구 버튼
    private func toolButton(_ tool: MCPTool) -> some View {
        Button(action: {
            selectedTool = tool
            showingToolDetails = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: iconForTool(tool))
                    .font(.title2)
                    .foregroundColor(selectedTool == tool ? .white : .blue)
                
                Text(toolNameForTool(tool))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedTool == tool ? .white : .primary)
            }
            .frame(width: 80, height: 60)
            .background(selectedTool == tool ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // 검색 뷰
    private var searchView: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("검색어를 입력하세요", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    Task {
                        await viewModel.performSearch(query: searchQuery)
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(searchQuery.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, 20)
            
            if !searchQuery.isEmpty {
                HStack {
                    Text("선택된 도구: \(toolNameForTool(selectedTool))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("도구 정보") {
                        showingToolDetails = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    
    // 결과 뷰
    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("실행 결과")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 20)
            
            if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if !viewModel.searchResults.isEmpty {
                resultView
            } else {
                emptyResultView
            }
        }
        .padding(.vertical, 16)
    }
    
    // 에러 뷰
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            
            Text("오류 발생")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    // 결과 뷰
    private var resultView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.searchResults)
                    .font(.body)
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: 200)
    }
    
    // 빈 결과 뷰
    private var emptyResultView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("검색 결과가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("위의 검색창에서 쿼리를 입력하고 실행해보세요")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    // 컨텍스트 히스토리 뷰
    private var contextHistoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("컨텍스트 히스토리")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(viewModel.contextHistory.count)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            if viewModel.contextHistory.isEmpty {
                Text("컨텍스트 히스토리가 없습니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.contextHistory, id: \.self) { context in
                            Text(context)
                                .font(.caption)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 100)
            }
        }
        .padding(.vertical, 16)
    }
    
    // 도구별 아이콘
    private func iconForTool(_ tool: MCPTool) -> String {
        switch tool {
        case .getUserData:
            return "person.circle"
        case .updateUserProfile:
            return "person.crop.circle.badge.plus"
        case .searchItems:
            return "magnifyingglass"
        case .analyzeData:
            return "chart.bar"
        case .generateReport:
            return "doc.text"
        }
    }
    
    // 도구별 이름
    private func toolNameForTool(_ tool: MCPTool) -> String {
        switch tool {
        case .getUserData:
            return "사용자 데이터"
        case .updateUserProfile:
            return "프로필 업데이트"
        case .searchItems:
            return "아이템 검색"
        case .analyzeData:
            return "데이터 분석"
        case .generateReport:
            return "리포트 생성"
        }
    }
}

// 도구 상세 정보 시트
struct ToolDetailSheet: View {
    let tool: MCPTool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 도구 정보
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: iconForTool(tool))
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(toolNameForTool(tool))
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(tool.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Divider()
                
                // 도구 설명
                VStack(alignment: .leading, spacing: 8) {
                    Text("설명")
                        .font(.headline)
                    
                    Text(descriptionForTool(tool))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // 사용 예시
                VStack(alignment: .leading, spacing: 8) {
                    Text("사용 예시")
                        .font(.headline)
                    
                    Text(exampleForTool(tool))
                        .font(.caption)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("도구 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func iconForTool(_ tool: MCPTool) -> String {
        switch tool {
        case .getUserData:
            return "person.circle"
        case .updateUserProfile:
            return "person.crop.circle.badge.plus"
        case .searchItems:
            return "magnifyingglass"
        case .analyzeData:
            return "chart.bar"
        case .generateReport:
            return "doc.text"
        }
    }
    
    private func toolNameForTool(_ tool: MCPTool) -> String {
        switch tool {
        case .getUserData:
            return "사용자 데이터"
        case .updateUserProfile:
            return "프로필 업데이트"
        case .searchItems:
            return "아이템 검색"
        case .analyzeData:
            return "데이터 분석"
        case .generateReport:
            return "리포트 생성"
        }
    }
    
    private func descriptionForTool(_ tool: MCPTool) -> String {
        switch tool {
        case .getUserData:
            return "사용자의 프로필 정보와 설정을 가져옵니다."
        case .updateUserProfile:
            return "사용자의 프로필 정보를 업데이트합니다."
        case .searchItems:
            return "데이터베이스에서 아이템을 검색합니다."
        case .analyzeData:
            return "제공된 데이터를 분석하고 인사이트를 제공합니다."
        case .generateReport:
            return "지정된 형식으로 리포트를 생성합니다."
        }
    }
    
    private func exampleForTool(_ tool: MCPTool) -> String {
        switch tool {
        case .getUserData:
            return "사용자 ID를 입력하여 해당 사용자의 정보를 조회합니다."
        case .updateUserProfile:
            return "사용자 ID와 새로운 프로필 정보를 입력하여 업데이트합니다."
        case .searchItems:
            return "검색어를 입력하여 관련 아이템들을 찾습니다."
        case .analyzeData:
            return "데이터와 분석 유형을 지정하여 분석을 수행합니다."
        case .generateReport:
            return "리포트 유형과 매개변수를 지정하여 리포트를 생성합니다."
        }
    }
}

#Preview {
    MCPView()
} 