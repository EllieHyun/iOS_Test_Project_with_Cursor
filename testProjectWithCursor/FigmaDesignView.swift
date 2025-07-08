import SwiftUI

// Figma에서 추출한 색상 정의
struct FigmaColors {
    static let primary = Color(red: 0.2, green: 0.6, blue: 1.0) // 예시 색상
    static let secondary = Color(red: 0.9, green: 0.9, blue: 0.9)
    static let text = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let background = Color.white
}

// Figma에서 추출한 폰트 정의
struct FigmaFonts {
    static let title = Font.system(size: 24, weight: .bold)
    static let headline = Font.system(size: 18, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
}

// Figma 디자인을 기반으로 한 뷰
struct FigmaDesignView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Figma 스타일의 헤더
                headerView
                
                // Figma 스타일의 검색바
                searchBarView
                
                // Figma 스타일의 탭뷰
                TabView(selection: $selectedTab) {
                    // 첫 번째 탭 - 카드 형태의 목록
                    cardListView
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("홈")
                        }
                        .tag(0)
                    
                    // 두 번째 탭 - 그리드 형태
                    gridView
                        .tabItem {
                            Image(systemName: "square.grid.2x2")
                            Text("카테고리")
                        }
                        .tag(1)
                    
                    // 세 번째 탭 - 프로필
                    profileView
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("프로필")
                        }
                        .tag(2)
                }
                .accentColor(FigmaColors.primary)
            }
            .background(FigmaColors.background)
        }
    }
    
    // Figma 스타일 헤더
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("안녕하세요!")
                    .font(FigmaFonts.caption)
                    .foregroundColor(.secondary)
                Text("오늘도 좋은 하루 되세요")
                    .font(FigmaFonts.title)
                    .foregroundColor(FigmaColors.text)
            }
            
            Spacer()
            
            // 알림 버튼
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(FigmaColors.secondary)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bell")
                        .foregroundColor(FigmaColors.text)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    // Figma 스타일 검색바
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("검색어를 입력하세요", text: $searchText)
                .font(FigmaFonts.body)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(FigmaColors.secondary)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // Figma 스타일 카드 리스트
    private var cardListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<10, id: \.self) { index in
                    cardItem(index: index)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // 개별 카드 아이템
    private func cardItem(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 카드 이미지 (더미)
            Rectangle()
                .fill(FigmaColors.secondary)
                .frame(height: 120)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("카드 제목 \(index + 1)")
                    .font(FigmaFonts.headline)
                    .foregroundColor(FigmaColors.text)
                
                Text("이것은 카드의 설명 텍스트입니다. Figma에서 디자인한 스타일을 SwiftUI로 구현했습니다.")
                    .font(FigmaFonts.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("₩15,000")
                        .font(FigmaFonts.headline)
                        .foregroundColor(FigmaColors.primary)
                    
                    Spacer()
                    
                    Button("자세히 보기") {
                        // 액션
                    }
                    .font(FigmaFonts.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(FigmaColors.primary)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // Figma 스타일 그리드 뷰
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(0..<8, id: \.self) { index in
                    gridItem(index: index)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // 그리드 아이템
    private func gridItem(index: Int) -> some View {
        VStack(spacing: 12) {
            Circle()
                .fill(FigmaColors.primary.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "star.fill")
                        .foregroundColor(FigmaColors.primary)
                )
            
            Text("카테고리 \(index + 1)")
                .font(FigmaFonts.body)
                .foregroundColor(FigmaColors.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Figma 스타일 프로필 뷰
    private var profileView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 헤더
                VStack(spacing: 16) {
                    Circle()
                        .fill(FigmaColors.primary)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text("사용자 이름")
                            .font(FigmaFonts.title)
                            .foregroundColor(FigmaColors.text)
                        
                        Text("user@example.com")
                            .font(FigmaFonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // 메뉴 리스트
                VStack(spacing: 0) {
                    ForEach(menuItems, id: \.title) { item in
                        menuRow(item: item)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 20)
            }
        }
    }
    
    // 메뉴 아이템
    private func menuRow(item: MenuItem) -> some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(FigmaColors.primary)
                .frame(width: 24)
            
            Text(item.title)
                .font(FigmaFonts.body)
                .foregroundColor(FigmaColors.text)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .onTapGesture {
            // 메뉴 액션
        }
    }
    
    // 메뉴 아이템 데이터
    private var menuItems: [MenuItem] {
        [
            MenuItem(title: "내 정보", icon: "person"),
            MenuItem(title: "주문 내역", icon: "list.bullet"),
            MenuItem(title: "즐겨찾기", icon: "heart"),
            MenuItem(title: "설정", icon: "gear"),
            MenuItem(title: "고객센터", icon: "questionmark.circle"),
            MenuItem(title: "로그아웃", icon: "rectangle.portrait.and.arrow.right")
        ]
    }
}

// 메뉴 아이템 모델
struct MenuItem {
    let title: String
    let icon: String
}

#Preview {
    FigmaDesignView()
} 