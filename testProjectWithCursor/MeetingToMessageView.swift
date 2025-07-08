import SwiftUI
import MessageUI

struct MeetingToMessageView: View {
    @State private var meetingNote = ""
    @State private var messageDraft = ""
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("회의록을 입력하세요")
                    .font(.headline)
                
                TextEditor(text: $meetingNote)
                    .frame(height: 180)
                    .border(Color.gray.opacity(0.3))
                    .padding(.bottom, 8)
                
                Button(action: {
                    messageDraft = generateMessageDraft(from: meetingNote)
                    showShareSheet = true
                }) {
                    Text("iMessage 초안 만들기 및 공유")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(meetingNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                if !messageDraft.isEmpty {
                    Text("초안 미리보기")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ScrollView {
                        Text(messageDraft)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(8)
                    }
                    .frame(minHeight: 80, maxHeight: 180)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("회의록 → 메시지")
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [messageDraft])
            }
        }
    }
    
    func generateMessageDraft(from note: String) -> String {
        // 간단한 요약/포맷팅 예시
        let lines = note.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        var dateLine = ""
        var attendeesLine = ""
        var todoLines: [String] = []
        var summaryLines: [String] = []
        
        for line in lines {
            if line.contains("일시") || line.contains("날짜") {
                dateLine = line
            } else if line.contains("참석자") {
                attendeesLine = line
            } else if line.contains("할 일") || line.contains("TODO") {
                todoLines.append(line)
            } else {
                summaryLines.append(line)
            }
        }
        
        var draft = "[회의 요약]\n"
        if !dateLine.isEmpty { draft += "- \(dateLine)\n" }
        if !attendeesLine.isEmpty { draft += "- \(attendeesLine)\n" }
        if !summaryLines.isEmpty {
            draft += "- 주요 내용: \n  " + summaryLines.joined(separator: "\n  ") + "\n"
        }
        if !todoLines.isEmpty {
            draft += "- 할 일: \n  " + todoLines.joined(separator: "\n  ") + "\n"
        }
        draft += "\n(이 메시지는 회의록을 바탕으로 자동 생성되었습니다.)"
        return draft
    }
}

// iOS에서 공유 시트(메시지 포함) 띄우기
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// SwiftUI에서 사용 예시
struct TestMessageSendView: View {
    @State private var showMessage = false
    var body: some View {
        Button("메시지 보내기 테스트") {
            showMessage = true
        }
        .sheet(isPresented: $showMessage) {
            MessageComposeView(recipients: ["01012345678"], bodyText: "이것은 테스트 메시지입니다.")
        }
    }
}

struct MessageComposeView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    var recipients: [String] = []
    var bodyText: String

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView
        init(_ parent: MessageComposeView) { self.parent = parent }
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.recipients = recipients
        vc.body = bodyText
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}

#Preview {
    MeetingToMessageView()
} 