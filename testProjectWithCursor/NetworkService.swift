import Foundation

// 백엔드 API 응답 모델
struct ApiResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
}

// 사용자 모델 예시
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

// 네트워크 서비스 클래스
class NetworkService: ObservableObject {
    private let baseURL = "https://your-backend-api.com/api"
    
    // GET 요청 예시
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let apiResponse = try JSONDecoder().decode(ApiResponse<[User]>.self, from: data)
        return apiResponse.data ?? []
    }
    
    // POST 요청 예시
    func createUser(name: String, email: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw NetworkError.invalidURL
        }
        
        let userData = ["name": name, "email": email]
        let jsonData = try JSONSerialization.data(withJSONObject: userData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw NetworkError.invalidResponse
        }
        
        let apiResponse = try JSONDecoder().decode(ApiResponse<User>.self, from: data)
        return apiResponse.data ?? User(id: 0, name: "", email: "")
    }
}

// 네트워크 에러 정의
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
} 