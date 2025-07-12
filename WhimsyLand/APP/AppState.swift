//
//  AppState.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/10/25.
//
//  앱이 몰입형 AR 환경에서 어떤 상태에 있고 사용자가 어떤 오브젝트를 사용할 수 있으며,
//  센서/권한/에러 상태가 어떤지 이 모든 걸 조율해주는 클래스

import Foundation
import ARKit
import RealityKit

@Observable
class AppState {
    var immersiveSpaceOpened: Bool { placementManager != nil }
    private(set) weak var placementManager: PlacementManager? = nil

    // 배치 가능한 오브젝트 저장 및 오브젝트 파일명
    private(set) var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    private(set) var modelDescriptors: [ModelDescriptor] = []
    var selectedFileName: String?

    // MARK: immersive 환경 오픈, 종료 함수
    func immersiveSpaceOpened(with manager: PlacementManager) {
        placementManager = manager
    }

    func didLeaveImmersiveSpace() {
        // Remember which placed object is attached to which persistent world anchor when leaving the immersive space.
        if let placementManager {
            placementManager.saveWorldAnchorsObjectsMapToDisk()
            
            // ARKit의 World Sensing 기능 종료
            // 더 이상 AR 정보를 실시간으로 받아올 필요 없음
            // 리소스를 아끼고 오류를 최소회하기 위해
            arkitSession.stop()
        }
        placementManager = nil
    }

    func setPlaceableObjects(_ objects: [PlaceableObject]) {
        placeableObjectsByFileName = objects.reduce(into: [:]) { map, placeableObject in
            map[placeableObject.descriptor.fileName] = placeableObject
        }

        // Sort descriptors alphabetically.
        modelDescriptors = objects.map { $0.descriptor }.sorted { lhs, rhs in
            lhs.displayName < rhs.displayName
        }
   }

    // Vision센서 기능 컨트롤(권한 요청 및 상태 확인, provider 실행/중단 감지, immersive space 진입 준비 상태 관리)
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
    // 두 조건을 모두 만족하는 경우에만 immersiveSpace로 진입 허용
    // 이 값은 Enter 버튼 활성 여부에 활용
    var canEnterImmersiveSpace: Bool {
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
    }
    
    // MARK: - Xcode Previews

    fileprivate var previewPlacementManager: PlacementManager? = nil

    /// An initial app state for previews in Xcode.
    @MainActor
    static func previewAppState(immersiveSpaceOpened: Bool = false, selectedIndex: Int? = nil) -> AppState {
        let state = AppState()

        state.setPlaceableObjects([previewObject(named: "White sphere"),
                                   previewObject(named: "Red cube"),
                                   previewObject(named: "Blue cylinder")])

        if let selectedIndex, selectedIndex < state.modelDescriptors.count {
            state.selectedFileName = state.modelDescriptors[selectedIndex].fileName
        }

        if immersiveSpaceOpened {
            state.previewPlacementManager = PlacementManager()
            state.placementManager = state.previewPlacementManager
        }

        return state
    }
    
    @MainActor
    private static func previewObject(named fileName: String) -> PlaceableObject {
        return PlaceableObject(descriptor: ModelDescriptor(fileName: fileName),
                               renderContent: ModelEntity(),
                               previewEntity: ModelEntity())
    }
}
