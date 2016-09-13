    //
//  CameraController.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 9/12/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import AVFoundation
import AVKit

let CameraControllerDidStartSession = "CameraControllerDidStartSession"
let CameraControllerDidStopSession = "CameraControllerDidStopSession"

//protocol CameraControllerDelegate: class {
//    func cameraController(cameraController:CameraController, didDetectFaces faces:Array<(id:Int, frame:CGRect)>)
//}

class CameraController : NSObject{
    
//    weak var delegate:CameraControllerDelegate?
    
    private var currentCameraDevice:AVCaptureDevice?
    
    private var sessionQueue:dispatch_queue_t = dispatch_queue_create("com.thinkst.secretkeeper.session_access_queue", DISPATCH_QUEUE_SERIAL)
    
    private var session:AVCaptureSession!
    private var frontCameraDevice:AVCaptureDevice?
    private var stillCameraOutput:AVCaptureStillImageOutput!
    
    required override init(){
//        self.delegate = delegate
        super.init()
        initializeSession()
    }
    
    func initializeSession(){
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {(granted:Bool) -> Void in
                if granted{
                    self.configureSession()
                }else{
                    self.showAccessDeniedMessage()
                }
            })
        case .Authorized:
            configureSession()
        case .Denied, .Restricted:
            showAccessDeniedMessage()
        }
    }
    
    func startRunning() {
        performConfiguration { () -> Void in
            self.session.startRunning()
            NSNotificationCenter.defaultCenter().postNotificationName(CameraControllerDidStartSession, object: self)
        }
    }
    
    func stopRunning() {
        performConfiguration { () -> Void in
            self.session.stopRunning()
        }
    }
    
    func captureStillImage(completionHandler handler:((image:UIImage, metadata:NSDictionary) -> Void)) {
        captureSingleStillImage(completionHandler:handler)
    }
    
    func captureSingleStillImage(completionHandler handler: ((image:UIImage, metadata:NSDictionary) -> Void)) {
        dispatch_async(sessionQueue) { () -> Void in
            
            let connection = self.stillCameraOutput.connectionWithMediaType(AVMediaTypeVideo)
            
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
            
            self.stillCameraOutput.captureStillImageAsynchronouslyFromConnection(connection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if error == nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    let metadata:NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))!
                    
                    if let image = UIImage(data: imageData) {
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            handler(image: image, metadata:metadata)
                        }
                    }
                }
                else {
                    NSLog("error while capturing still image: \(error)")
                }
            }
        }
    }
}

private extension CameraController {
    
    func performConfiguration(block: (() -> Void)) {
        dispatch_async(sessionQueue) { () -> Void in
            block()
        }
    }
    
    
    func performConfigurationOnCurrentCameraDevice(block: ((currentDevice:AVCaptureDevice) -> Void)) {
        if let currentDevice = self.currentCameraDevice {
            performConfiguration { () -> Void in
                do{
                    try currentDevice.lockForConfiguration()
                    block(currentDevice: currentDevice)
                    currentDevice.unlockForConfiguration()
                    
                }
                catch{
                    print("An error occurred during Configuration on Current Device Method")
                }
            }
        }
    }
    
    
    func configureSession() {
        configureDeviceInput()
        configureStillImageCameraOutput()
    }
    
    
    func configureDeviceInput() {
        performConfiguration { () -> Void in
            do{
                let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                for device in availableCameraDevices as! [AVCaptureDevice] {
                    if device.position == .Front {
                        self.frontCameraDevice = device
                    }
                }
                
                self.currentCameraDevice = self.frontCameraDevice
                let possibleCameraInput: AnyObject? = try AVCaptureDeviceInput.init(device: self.currentCameraDevice)
                if let backCameraInput = possibleCameraInput as? AVCaptureDeviceInput {
                    if self.session.canAddInput(backCameraInput) {
                        self.session.addInput(backCameraInput)
                    }
                }
            }catch{
                print("An error occurred whilst configuring devive input")
            }
        }
    }
    
    
    func configureStillImageCameraOutput() {
        performConfiguration { () -> Void in
            self.stillCameraOutput = AVCaptureStillImageOutput()
            self.stillCameraOutput.outputSettings = [
                AVVideoCodecKey  : AVVideoCodecJPEG,
                AVVideoQualityKey: 0.9
            ]
            
            if self.session.canAddOutput(self.stillCameraOutput) {
                self.session.addOutput(self.stillCameraOutput)
            }
        }
    }
    
    func showAccessDeniedMessage(){
        print("User has denied access to camera. No camera being used.")
    }
    
}
