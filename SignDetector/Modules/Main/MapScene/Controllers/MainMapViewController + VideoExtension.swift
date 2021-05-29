//
//  MainMapViewController + VideoExtension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 29.05.2021.
//

import Foundation
import UIKit
import AVFoundation


extension MainMapViewController {
    internal func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: 1280,
                                     kCVPixelBufferHeightKey as String: 720,
                                     ]
        settings.previewPhotoFormat = previewFormat as [String : Any]
        print(view.frame.width)
        self.output.capturePhoto(with: settings, delegate: self)
      }
}
//MARK: - VideoModelViewDelegate
extension MainMapViewController: VideoModelViewDelegate {
    func modeDidChange(isOn: Bool) {
        print("Video mode isOn: \(isOn)")
        guard session != nil else { return }
        if isOn {
            session.startRunning()
            createTimer()
        } else {
            session.stopRunning()
            cancelTimer()
        }
        dragableView.isHidden = !isOn
    }
}

//MARK: - AVCapturePhotoCaptureDelegate
extension MainMapViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("IMAGE CAPTURED")
        guard socket != nil, let photoData = photo.fileDataRepresentation(),
              let latitude = locationManager.location?.coordinate.latitude,
              let longitude = locationManager.location?.coordinate.longitude else {
            print("DIDN T SEND WITH SOCKET")
            return
            
        }
        print("HERE")
        if isConnectedToInternet() {
            socket.sendImage(image: photoData, lat: latitude, long: longitude, direction: locationManager.heading?.magneticHeading ?? 0) { result in
                print("IMAGE SEND WITH SOCKET")
                print(self.locationManager.heading?.magneticHeading)
            }
        } else {
            print("add sign model")
            CoreDataManager.shared.addSignModel(fileData: photoData,
                                                latitude: latitude,
                                                longitude: longitude,
                                                direction: locationManager.heading?.magneticHeading ?? 0)
        }
    }
}

