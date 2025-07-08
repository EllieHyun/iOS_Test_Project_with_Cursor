import Foundation
import EventKit

// 자연어 명령 파싱 결과
struct ParsedCommand {
    let action: String
    let date: Date?
    let title: String
    let description: String?
    let attendees: [String]
    let location: String?
    let duration: TimeInterval?
}

// 자연어 처리 서비스
class NaturalLanguageProcessor: ObservableObject {
    private let eventStore = EKEventStore()
    
    // 자연어 명령을 파싱
    func parseCommand(_ command: String) -> ParsedCommand {
        let lowercasedCommand = command.lowercased()
        
        // 기본값
        var action = "add"
        var date: Date? = nil
        var title = ""
        var description: String? = nil
        var attendees: [String] = []
        var location: String? = nil
        var duration: TimeInterval? = 3600 // 기본 1시간
        
        // 날짜 파싱
        date = parseDate(from: lowercasedCommand)
        
        // 제목 추출
        title = extractTitle(from: command, date: date)
        
        // 참석자 추출
        attendees = extractAttendees(from: lowercasedCommand)
        
        // 장소 추출
        location = extractLocation(from: lowercasedCommand)
        
        // 지속 시간 추출
        duration = extractDuration(from: lowercasedCommand)
        
        return ParsedCommand(
            action: action,
            date: date,
            title: title,
            description: description,
            attendees: attendees,
            location: location,
            duration: duration
        )
    }
    
    // 날짜 파싱
    private func parseDate(from command: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        // "8월 8일" 패턴
        if let range = command.range(of: #"(\d+)월\s*(\d+)일"#, options: .regularExpression) {
            let match = String(command[range])
            let components = match.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }
                .filter { $0 > 0 }
            
            if components.count >= 2 {
                let month = components[0]
                let day = components[1]
                
                var dateComponents = DateComponents()
                dateComponents.year = calendar.component(.year, from: now)
                dateComponents.month = month
                dateComponents.day = day
                dateComponents.hour = 10 // 기본 오전 10시
                dateComponents.minute = 0
                
                return calendar.date(from: dateComponents)
            }
        }
        
        // "오늘", "내일", "다음주" 패턴
        if command.contains("오늘") {
            return calendar.startOfDay(for: now)
        } else if command.contains("내일") {
            return calendar.date(byAdding: .day, value: 1, to: now)
        } else if command.contains("다음주") {
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        }
        
        // "월요일", "화요일" 등 요일 패턴
        let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
        for (index, weekday) in weekdays.enumerated() {
            if command.contains(weekday) {
                let weekdaySymbol = calendar.weekdaySymbols[index]
                let weekdayComponent = index + 1
                
                var dateComponents = DateComponents()
                dateComponents.weekday = weekdayComponent
                dateComponents.hour = 10
                dateComponents.minute = 0
                
                return calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime)
            }
        }
        
        return nil
    }
    
    // 제목 추출
    private func extractTitle(from command: String, date: Date?) -> String {
        var title = command
        
        // 날짜 관련 텍스트 제거
        let datePatterns = [
            #"(\d+)월\s*(\d+)일"#,
            "오늘",
            "내일", 
            "다음주",
            "월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"
        ]
        
        for pattern in datePatterns {
            title = title.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // 액션 관련 텍스트 제거
        let actionWords = ["추가해줘", "등록해줘", "일정", "캘린더에", "에"]
        for word in actionWords {
            title = title.replacingOccurrences(of: word, with: "")
        }
        
        // 참석자 관련 텍스트 제거
        let attendeeWords = ["우리 가족", "가족", "친구", "동료", "팀"]
        for word in attendeeWords {
            title = title.replacingOccurrences(of: word, with: "")
        }
        
        // 공백 정리
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return title.isEmpty ? "새로운 일정" : title
    }
    
    // 참석자 추출
    private func extractAttendees(from command: String) -> [String] {
        var attendees: [String] = []
        
        if command.contains("우리 가족") || command.contains("가족") {
            attendees.append("가족")
        }
        
        if command.contains("친구") {
            attendees.append("친구")
        }
        
        if command.contains("동료") || command.contains("팀") {
            attendees.append("동료")
        }
        
        return attendees
    }
    
    // 장소 추출
    private func extractLocation(from command: String) -> String? {
        let locationPatterns = [
            #"([가-힣]+)에서"#,
            #"([가-힣]+)에"#,
            #"([가-힣]+)로"#
        ]
        
        for pattern in locationPatterns {
            if let range = command.range(of: pattern, options: .regularExpression) {
                let match = String(command[range])
                return match.replacingOccurrences(of: "에서", with: "")
                    .replacingOccurrences(of: "에", with: "")
                    .replacingOccurrences(of: "로", with: "")
            }
        }
        
        return nil
    }
    
    // 지속 시간 추출
    private func extractDuration(from command: String) -> TimeInterval? {
        if command.contains("하루") || command.contains("종일") {
            return 24 * 3600 // 24시간
        }
        
        if command.contains("반나절") {
            return 4 * 3600 // 4시간
        }
        
        if command.contains("2시간") {
            return 2 * 3600
        } else if command.contains("3시간") {
            return 3 * 3600
        } else if command.contains("4시간") {
            return 4 * 3600
        }
        
        return 3600 // 기본 1시간
    }
    
    // 캘린더 권한 요청
    func requestCalendarAccess() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    continuation.resume(returning: granted)
                }
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // 캘린더에 이벤트 추가
    func addEventToCalendar(parsedCommand: ParsedCommand) async throws -> Bool {
        guard await requestCalendarAccess() else {
            throw CalendarError.accessDenied
        }
        
        guard let date = parsedCommand.date else {
            throw CalendarError.invalidDate
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = parsedCommand.title
        event.notes = parsedCommand.description
        event.location = parsedCommand.location
        event.startDate = date
        event.endDate = date.addingTimeInterval(parsedCommand.duration ?? 3600)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // 참석자 정보를 메모에 추가
        if !parsedCommand.attendees.isEmpty {
            let attendeesText = "참석자: " + parsedCommand.attendees.joined(separator: ", ")
            event.notes = (event.notes ?? "") + "\n" + attendeesText
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            throw CalendarError.saveFailed(error.localizedDescription)
        }
    }
}

// 캘린더 에러
enum CalendarError: Error, LocalizedError {
    case accessDenied
    case invalidDate
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "캘린더 접근 권한이 거부되었습니다."
        case .invalidDate:
            return "유효하지 않은 날짜입니다."
        case .saveFailed(let message):
            return "일정 저장에 실패했습니다: \(message)"
        }
    }
} 