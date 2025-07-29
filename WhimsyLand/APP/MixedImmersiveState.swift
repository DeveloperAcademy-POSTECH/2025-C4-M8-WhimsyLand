//
//  AppState.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/10/25.
//
//  앱이 몰입형 AR 환경에서 어떤 상태에 있고 사용자가 어떤 Toy를 사용할 수 있으며,
//  센서/권한/에러 상태가 어떤지 이 모든 걸 조율해주는 클래스

import Foundation
import ARKit
import RealityKit

enum MixedImmersiveMode {
    case editing
    case viewing
}

@Observable
class MixedImmersiveState {
    var mixedImmersiveSpaceOpened: Bool { placementManager != nil }
    var mixedImmersiveMode: MixedImmersiveMode = .viewing
    private(set) weak var placementManager: PlacementManager? = nil
    
    // MARK: mixedImmersive 환경 오픈, 종료 함수
    func mixedImmersiveSpaceOpened(with manager: PlacementManager) {
        placementManager = manager
    }

    func didLeaveMixedImmersiveSpace() {
        if let placementManager {
            placementManager.saveWorldAnchorsToysMapToDisk()
            arkitSession.stop()
        }
        placementManager = nil
    }

    // Vision센서 기능 컨트롤(권한 요청 및 상태 확인, provider 실행/중단 감지, mixed immersive space 진입 준비 상태 관리)
    var arkitSession = ARKitSession()
    
    //에러 없음으로 초기화
    var providersStoppedWithError = false
    
    // world sensing(세계 인식 기능) 권한 상태를 나타냄
    // .notDetermined : 아직 권한 요청 안함
    // .allowed : 권한 있음
    // .denied : 권한 없음
    var worldSensingAuthorizationStatus = ARKitSession.AuthorizationStatus.notDetermined
    
    // world sensing 권한이 있는지 확인
    var allRequiredAuthorizationsAreGranted: Bool {
        worldSensingAuthorizationStatus == .allowed
    }
    
    // 이 기기에서 world tracking과 plane detection을 지원하는지 확인
    var allRequiredProvidersAreSupported: Bool {
        WorldTrackingProvider.isSupported && PlaneDetectionProvider.isSupported
    }
    
    // 위의 두 조건을 만족하는 경우에 true 반환
    // 두 조건을 모두 만족하는 경우에만 mixed immersiveSpace로 진입 허용
    // 이 값은 Enter 버튼 활성 여부에 활용
    var canEnterMixedImmersiveSpace: Bool {
        allRequiredAuthorizationsAreGranted && allRequiredProvidersAreSupported
    }
    
    // world sensing 관련한 권한 요청
    // world sensing 권한을 위에서 선언한 변수에 저장
    func requestWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.requestAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }
    
    // 현재 권한 상태 조회
    func queryWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.queryAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }
    
    //ARKit 상태 실시간 모니터링
    func monitorSessionEvents() async {
        for await event in arkitSession.events {
            switch event {
            //센터 상태가 변경 되었을 때
            case .dataProviderStateChanged(_, let newState, let error):
                switch newState {
                case .initialized:
                    break
                case .running:
                    break
                case .paused:
                    break
                case .stopped:
                    if let error {
                        print("An error occured: \(error)")
                        providersStoppedWithError = true
                    }
                @unknown default:
                    break
                }
            // 센서 권한이 변경 되었을 때
            case .authorizationChanged(let type, let status):
                print("Authorization type \(type) changed to \(status)")
                if type == .worldSensing {
                    worldSensingAuthorizationStatus = status
                }
            // 그 외 이벤트
            default :
                print("An unknown event occured \(event)")
            }
        }
        print("⛔️ 모니터링 중지됨")
    }
}
