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
        
        fileprivate var currentCameraDevice:AVCaptureDevice?
        
        fileprivate var sessionQueue:DispatchQueue = DispatchQueue(label: "com.thinkst.secretkeeper.session_access_queue", attributes: [])
        
        fileprivate var session:AVCaptureSession!
        fileprivate var frontCameraDevice:AVCaptureDevice?
        fileprivate var stillCameraOutput:AVCaptureStillImageOutput!
        
        required override init(){
            //        self.delegate = delegate
            super.init()
            initializeSession()
        }
        
        func initializeSession(){
            session = AVCaptureSession()
            session.sessionPreset = AVCaptureSessionPresetPhoto
            

            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            switch authStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(granted:Bool) -> Void in
                    if granted{
                        self.configureSession()
                    }else{
                        self.showAccessDeniedMessage()
                    }
                })
            case .authorized:
                configureSession()
            case .denied, .restricted:
                showAccessDeniedMessage()
            }
        }
        
        func startRunning() {
            performConfiguration { () -> Void in
                self.session.startRunning()
                NotificationCenter.default.post(name: Notification.Name(rawValue: CameraControllerDidStartSession), object: self)
            }
        }
        
        func stopRunning() {
            performConfiguration { () -> Void in
                self.session.stopRunning()
            }
        }
        
        func captureStillImage(completionHandler handler:@escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
            captureSingleStillImage(completionHandler:handler)
        }
        
        func captureSingleStillImage(completionHandler handler: @escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
            sessionQueue.async { () -> Void in
                
                let connection = self.stillCameraOutput.connection(withMediaType: AVMediaTypeVideo)
                connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
                self.stillCameraOutput.captureStillImageAsynchronously(from: connection) {
                    (imageDataSampleBuffer, error) -> Void in
                    
                    if error == nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let metadata:NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer!, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))!
                        
                        if let image = UIImage(data: imageData!) {
                            let compressed = self.compressImage(image)
                            let compressedImage = UIImage(data:compressed)
                            DispatchQueue.main.async { () -> Void in
                                handler(compressedImage!, metadata)
                            }
                        }
                    }
                    else {
                        NSLog("error while capturing still image: \(error)")
                    }
                }
            }
        }
        
        func compressImage(_ image:UIImage) -> Data {
            // Reducing file size to a 10th
            
            var actualHeight : CGFloat = image.size.height
            var actualWidth : CGFloat = image.size.width
            let maxHeight : CGFloat = 1200.0
            let maxWidth : CGFloat = 300.0
            var imgRatio : CGFloat = actualWidth/actualHeight
            let maxRatio : CGFloat = maxWidth/maxHeight
            var compressionQuality : CGFloat = 0.5
            
            if (actualHeight > maxHeight || actualWidth > maxWidth){
                if(imgRatio < maxRatio){
                    //adjust width according to maxHeight
                    imgRatio = maxHeight / actualHeight;
                    actualWidth = imgRatio * actualWidth;
                    actualHeight = maxHeight;
                }
                else if(imgRatio > maxRatio){
                    //adjust height according to maxWidth
                    imgRatio = maxWidth / actualWidth;
                    actualHeight = imgRatio * actualHeight;
                    actualWidth = maxWidth;
                }
                else{
                    actualHeight = maxHeight;
                    actualWidth = maxWidth;
                    compressionQuality = 1;
                }
            }
            
            let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
            UIGraphicsBeginImageContext(rect.size);
            image.draw(in: rect)
            let img = UIGraphicsGetImageFromCurrentImageContext();
            let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
            UIGraphicsEndImageContext();
            
            return imageData!;
        }
        
    }
    
    extension UIImage{
        var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
        var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
        var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
        var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
        var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
        var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
    }
    
    private extension CameraController {
        
        func performConfiguration(_ block: @escaping (() -> Void)) {
            sessionQueue.async { () -> Void in
                block()
            }
        }
        
        
        func performConfigurationOnCurrentCameraDevice(_ block: @escaping ((_ currentDevice:AVCaptureDevice) -> Void)) {
            if let currentDevice = self.currentCameraDevice {
                performConfiguration { () -> Void in
                    do{
                        try currentDevice.lockForConfiguration()
                        block(currentDevice)
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
                    let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
                    for device in availableCameraDevices as! [AVCaptureDevice] {
                        if device.position == .front {
                            self.frontCameraDevice = device
                        }
                    }
                    
                    self.currentCameraDevice = self.frontCameraDevice
                    let possibleCameraInput = try AVCaptureDeviceInput.init(device: self.currentCameraDevice) as AVCaptureDeviceInput
                    if let frontCameraInput = possibleCameraInput as? AVCaptureDeviceInput {
                        if self.session.canAddInput(frontCameraInput) {
                            self.session.addInput(frontCameraInput)
                        }
                    }
                }catch let error as NSError{
                    print(error)
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
