# ILikePhoto
마음에 드는 사진을 찾고, 사진에 대한 정보를 제공하는 서비스

![토픽](https://github.com/user-attachments/assets/0d590353-5deb-4731-8c20-24586ef8874f) | ![2](https://github.com/user-attachments/assets/715b9bd6-8b85-43d4-afe7-d3bc00af7aff) | ![4](https://github.com/user-attachments/assets/ec493b8c-bb90-47a7-bc47-b6760e5b9faf) | ![6](https://github.com/user-attachments/assets/5601cef4-d36f-466c-aba2-79f474a81ddf)
---|---| ---| ---|

## 프로젝트 환경

- 개발 인원: iOS 1
- 개발 기간: 24.07.22 ~ 24.08.13 (3주)
- 최소 버전: iOS 15.0

## 기술 스택

- 🎨 View Drawing - `UIKit`  
- 🏛️ Architecture - `MVVM`  
- ♻️ Asynchronous - `RxSwift`  
- 📡 Network - `Alamofire`  
- 🏞️ Image Loader - `Kingfisher`  
- 📦 DB: `RealmSwift`  
- 🎸 기타 - `SnapKit` `Then` `Toast` `DGCharts`  

## 주요 기능
- 토픽 사진 및 랜덤 사진 추천  
- 사진 검색 및 색감 필터링  
- 마음에 드는 사진 저장  
- 사진 조회 수와 다운로드 수 차트 시각화

## 주요 기술

### 랜덤 토픽 사진 추천  
- 토픽 화면에서 랜덤으로 3개의 토픽을 골라 API 통신  
- 3개의 통신을 DispatchGroup의 enter와 leave를 통해 뷰 갱신 횟수 최소화  
- UIRefreshControl을 통해 당겨서 새로고침 기능 구현  
- API 과호출 방지를 위해 DispatchTime의 변수를 통해 60초간 통신 X  
- 3개의 통신 모두 완료 시 DispatchTime을 .now()로 초기화 시켜 핸들링

### PinterestLayout  
- UICollectionViewLayout을 서브 클래싱하여 PinterestLayout 구현  
- Delegate를 통해 이미지의 Height 값을 전달  
- prepare() 메서드에서 레이아웃을 계산  
- 이미 계산한 레이아웃을 [UICollectionViewLayoutAttributes] 타입의 cache에 담아 성능 개선
