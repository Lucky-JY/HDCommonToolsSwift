//
//  HDCommonToolsSwift+permission.swift
//  HDCommonToolsSwift
//
//  Created by Damon on 2020/7/3.
//  Copyright © 2020 Damon. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UserNotifications
import AppTrackingTransparency
import AdSupport

public enum HDPermissionType {
    case audio          //麦克风权限
    case video          //相机权限
    case photoLibrary   //相册权限
    case GPS            //定位权限
    case notification   //通知权限
    case idfa           //idfa权限获取
}

public enum HDPermissionStatus {
    case authorized     //用户允许
    case restricted     //被限制修改不了状态,比如家长控制选项等
    case denied         //用户拒绝
    case notDetermined  //用户尚未选择
    case limited        //部分允许，iOS14之后增加的特性
}

public extension HDCommonToolsSwift {
    ///请求权限
    func requestPermission(type: HDPermissionType, complete: @escaping ((HDPermissionStatus) -> Void)) -> Void {
        switch type {
        case .audio:
            AVCaptureDevice.requestAccess(for: .audio) { (granted) in
                if granted {
                    complete(.authorized)
                } else {
                    complete(.denied)
                }
            }
        case .video:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    complete(.authorized)
                } else {
                    complete(.denied)
                }
            }
        case .photoLibrary:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .notDetermined:
                    complete(.notDetermined)
                case .restricted:
                    complete(.restricted)
                case .denied:
                    complete(.denied)
                case .authorized:
                    complete(.authorized)
                case .limited:
                    complete(.limited)
                default:
                    complete(.authorized)
                }
            }
        case .GPS:
            mLocationManager = CLLocationManager()
            mLocationManager?.delegate = self
            mLocationManager?.requestWhenInUseAuthorization()
            mLocationManager?.requestAlwaysAuthorization()
            locationComplete = complete
        case .notification:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if granted {
                    complete(.authorized)
                } else {
                    complete(.denied)
                }
            }
        case .idfa:
            if #available(iOS 14.0, *) {
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    switch status {
                    case .notDetermined:
                        complete(.notDetermined)
                    case .restricted:
                        complete(.restricted)
                    case .denied:
                        complete(.denied)
                    case .authorized:
                        complete(.authorized)
                    default:
                        complete(.authorized)
                    }
                }
            } else {
                if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                    complete(.authorized)
                } else {
                    complete(.denied)
                }
            }
        }
    }
    
    ///检测权限
    func checkPermission(type: HDPermissionType, complete: @escaping ((HDPermissionStatus) -> Void)) -> Void {
        switch type {
        case .audio:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            switch status {
            case .notDetermined:
                complete(.notDetermined)
            case .restricted:
                complete(.restricted)
            case .denied:
                complete(.denied)
            case .authorized:
                complete(.authorized)
            default:
                complete(.authorized)
            }
        case .video:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .notDetermined:
                complete(.notDetermined)
            case .restricted:
                complete(.restricted)
            case .denied:
                complete(.denied)
            case .authorized:
                complete(.authorized)
            default:
                complete(.authorized)
            }
        case .photoLibrary:
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                complete(.notDetermined)
            case .restricted:
                complete(.restricted)
            case .denied:
                complete(.denied)
            case .authorized:
                complete(.authorized)
            case .limited:
                complete(.limited)
            default:
                complete(.authorized)
            }
        case .GPS:
            if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                complete(.authorized)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                complete(.notDetermined)
            } else if CLLocationManager.authorizationStatus() == .restricted {
                complete(.restricted)
            } else if CLLocationManager.authorizationStatus() == .denied {
                complete(.denied)
            }
        case .notification:
            UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                    complete(.notDetermined)
                case .denied:
                    complete(.denied)
                case .authorized:
                    complete(.authorized)
                case .provisional:
                    complete (.authorized)
                default:
                    complete(.authorized)
                }
            }
        case .idfa:
            if #available(iOS 14.0, *) {
                let status = ATTrackingManager.trackingAuthorizationStatus
                switch status {
                case .notDetermined:
                    complete(.notDetermined)
                case .restricted:
                    complete(.restricted)
                case .denied:
                    complete(.denied)
                case .authorized:
                    complete(.authorized)
                default:
                    complete(.authorized)
                }
            } else {
                if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                    complete(.authorized)
                } else {
                    complete(.denied)
                }
            }
        }
    }
}

extension HDCommonToolsSwift: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let locationComplete = locationComplete  else { return }
        switch status {
            case .notDetermined:
                locationComplete(.notDetermined)
            case .restricted:
                locationComplete(.restricted)
            case .denied:
                locationComplete(.denied)
            case .authorizedAlways:
                locationComplete(.authorized)
            case .authorizedWhenInUse:
                locationComplete(.authorized)
            default:
                locationComplete(.authorized)
        }
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let locationComplete = locationComplete  else { return }
        switch manager.authorizationStatus {
            case .notDetermined:
                locationComplete(.notDetermined)
            case .restricted:
                locationComplete(.restricted)
            case .denied:
                locationComplete(.denied)
            case .authorizedAlways:
                locationComplete(.authorized)
            case .authorizedWhenInUse:
                locationComplete(.authorized)
            default:
                locationComplete(.authorized)
        }
    }
}

private var mLocationManager: CLLocationManager?   //标记是否循环震动
private var locationComplete: ((HDPermissionStatus) -> Void)?
