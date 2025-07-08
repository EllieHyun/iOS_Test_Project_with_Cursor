import SwiftUI

struct VoiceCommandView: View {
    @StateObject private var processor = NaturalLanguageProcessor()
    @State private var commandText = ""
    @State private var parsedCommand: ParsedCommand?
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var showingPreview = false
    
    // 예시 명령들
    private let exampleCommands = [
        "8월 8일에 우리 가족과 만나는 일정을 캘린더에 추가해줘",
        "내일 오후 2시에 친구와 만나기",
        "다음주 월요일에 팀 미팅",
        "오늘 저녁 7시에 가족과 저녁 식사",
        "토요일 오후에 영화 보기"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 헤더
                headerView
                
                // 명령 입력 영역
                commandInputView
                
                // 예시 명령들
                exampleCommandsView
                
                // 파싱 결과 미리보기
                if let parsedCommand = parsedCommand {
                    previewView(parsedCommand)
                }
                
                // 결과 영역
                resultView
                
                Spacer()
            }
            .navigationTitle("자연어 명령")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPreview) {
                if let parsedCommand = parsedCommand {
                    CommandPreviewSheet(parsedCommand: parsedCommand)
                }
            }
        }
    }
    
    // 헤더 뷰
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("자연어 명령")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("말하듯이 일정을 추가하세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // 명령 입력 뷰
    private var commandInputView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("일정 명령 입력")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    TextField("예: 8월 8일에 우리 가족과 만나기", text: $commandText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: parseCommand) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(commandText.isEmpty)
                }
            }
            
            if !commandText.isEmpty {
                HStack {
                    Button("미리보기") {
                        parseCommand()
                        showingPreview = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("캘린더에 추가") {
                        addToCalendar()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .disabled(parsedCommand == nil || isLoading)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // 예시 명령들 뷰
    private var exampleCommandsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("예시 명령")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(exampleCommands, id: \.self) { command in
                        Button(action: {
                            commandText = command
                            parseCommand()
                        }) {
                            Text(command)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    
    // 미리보기 뷰
    private func previewView(_ command: ParsedCommand) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("파싱 결과")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button("상세 보기") {
                    showingPreview = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                previewRow("제목", command.title)
                if let date = command.date {
                    previewRow("날짜", formatDate(date))
                }
                if !command.attendees.isEmpty {
                    previewRow("참석자", command.attendees.joined(separator: ", "))
                }
                if let location = command.location {
                    previewRow("장소", location)
                }
                if let duration = command.duration {
                    previewRow("지속시간", formatDuration(duration))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    // 미리보기 행
    private func previewRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
    
    // 결과 뷰
    private var resultView: some View {
        VStack(spacing: 12) {
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("캘린더에 추가 중...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if showSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("캘린더에 성공적으로 추가되었습니다!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // 명령 파싱
    private func parseCommand() {
        guard !commandText.isEmpty else { return }
        
        parsedCommand = processor.parseCommand(commandText)
        errorMessage = nil
        showSuccess = false
    }
    
    // 캘린더에 추가
    private func addToCalendar() {
        guard let command = parsedCommand else { return }
        
        isLoading = true
        errorMessage = nil
        showSuccess = false
        
        Task {
            do {
                let success = try await processor.addEventToCalendar(parsedCommand: command)
                await MainActor.run {
                    isLoading = false
                    if success {
                        showSuccess = true
                        commandText = ""
                        parsedCommand = nil
                    } else {
                        errorMessage = "캘린더에 추가하는데 실패했습니다."
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 날짜 포맷팅
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // 지속시간 포맷팅
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        if hours >= 24 {
            return "\(hours / 24)일"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(Int(duration) / 60)분"
        }
    }
}

// 명령 미리보기 시트
struct CommandPreviewSheet: View {
    let parsedCommand: ParsedCommand
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 이벤트 정보
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("일정 미리보기")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("캘린더에 추가될 내용")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Divider()
                
                // 상세 정보
                VStack(alignment: .leading, spacing: 12) {
                    detailRow("제목", parsedCommand.title)
                    
                    if let date = parsedCommand.date {
                        detailRow("날짜", formatDate(date))
                    }
                    
                    if !parsedCommand.attendees.isEmpty {
                        detailRow("참석자", parsedCommand.attendees.joined(separator: ", "))
                    }
                    
                    if let location = parsedCommand.location {
                        detailRow("장소", location)
                    }
                    
                    if let duration = parsedCommand.duration {
                        detailRow("지속시간", formatDuration(duration))
                    }
                    
                    if let description = parsedCommand.description {
                        detailRow("설명", description)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("일정 미리보기")
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
    
    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        if hours >= 24 {
            return "\(hours / 24)일"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(Int(duration) / 60)분"
        }
    }
}

#Preview {
    VoiceCommandView()
} 
