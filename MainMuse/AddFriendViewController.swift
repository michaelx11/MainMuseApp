//
//  AddFriendViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/6/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import AVFoundation
import UIKit

let kAlertAddingTag = 1
let kAlertAddedTag = 2

class AddFriendViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var qrCodeView: UIImageView!
    @IBOutlet weak var scannerView: UIView!
    
    // Self QR Code containing friend ID
    var qrcodeImage: CIImage!
    
    // QR Scanner
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    // Feedback
    var errorAlert: UIAlertView?
    var addedAlert: UIAlertView?
    
    let localData : AppLocalData = AppLocalData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        generateQRCode()
        setupScanner()
        
        errorAlert = UIAlertView(title: "Error!", message: "", delegate: self, cancelButtonTitle: nil)
        errorAlert?.tag = kAlertAddingTag
            
        addedAlert = UIAlertView(title: "Added!", message: "Successfully added: ", delegate: self, cancelButtonTitle: nil)
        addedAlert?.tag = kAlertAddedTag
    }
    
    func generateQRCode() {
        let data = localData.localFriendCode.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        let inputImage : CIImage = filter.outputImage
        let affineTransform : CGAffineTransform = CGAffineTransformMakeScale(5.0, 5.0)
        qrcodeImage = inputImage.imageByApplyingTransform(affineTransform)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.qrCodeView.image = UIImage(CIImage: self.qrcodeImage)
            return
        })
    }

    func setupScanner() {
        // Setup QR Code Scanner view
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        if (error != nil) {
            println("\(error?.localizedDescription)")
            return
        }
        
        // Setup capture session
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        
        // Setup output object
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Init video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = scannerView.layer.bounds
        scannerView.layer.addSublayer(videoPreviewLayer)
        
        // Start capture
        captureSession?.startRunning()
    }

    // Resize video preview layer after autolayout
    override func viewWillLayoutSubviews() {
        videoPreviewLayer?.frame = scannerView.layer.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject)
            
            if metadataObj.stringValue != nil {
                captureSession?.stopRunning()
                addFriend(metadataObj.stringValue)
            }
        }
    }
    
    func showErrorAlert(errorString: String) {
        errorAlert?.dismissWithClickedButtonIndex(-1, animated: false)
        errorAlert?.message = "\(errorString)"
        errorAlert?.show()
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), {
            self.errorAlert?.dismissWithClickedButtonIndex(-1, animated: false)
            self.captureSession?.startRunning()
        })
    }
    
    func showAddedAlert(friendName: String) {
        addedAlert?.dismissWithClickedButtonIndex(-1, animated: false)
        addedAlert?.message = "Added friend: \(friendName)"
        addedAlert?.show()
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), {
            self.addedAlert?.dismissWithClickedButtonIndex(-1, animated: false)
            self.captureSession?.startRunning()
        })
    }
    
    func addFriend(friendCode : String) {
        var rawPath : String = "http://" + HOST + "/addfriend?id=" + localData.localId + "&token=" + localData.appAccessToken + "&friendcode=" + friendCode;
        let urlPath : String = rawPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
        println(urlPath);
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showErrorAlert("Couldn't reach server!")
                })
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                return;
            }
            var err: NSError?
            
            var jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                return;
            }
            if (jsonResult["error"] != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    if let errorStr = jsonResult["error"] as? String {
                        self.showErrorAlert(errorStr)
                    } else {
                        self.showErrorAlert("Couldn't find user!")
                    }
                })
            } else {
                if let name : String = jsonResult["name"] as? String {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showAddedAlert(name)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showErrorAlert("Couldn't find user!")
                    })
                }

            }
        })
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
