//
//  ViewController.swift
//  Collab
//
//  Created by Anirudh Natarajan on 4/16/17.
//  Copyright © 2017 Kodikos. All rights reserved.
//


import UIKit
import ReplayKit

class ViewController: UIViewController, RPPreviewViewControllerDelegate{
    
    @IBOutlet var slider: UISlider!{
        didSet{
            slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
    }
    @IBOutlet weak var thicknessButton: UIButton!
    
    
    var bounds = UIScreen.main.bounds
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var toolbarBackground: UIImageView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var thickness:Int = 5
    var isEraserSelected = false
    var currentColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    var lastColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    
    @IBOutlet var paintPressed: UIButton!
    @IBOutlet var colorPressBtn: UIButton!
    @IBOutlet var colorWheelFrame: UIView!
    var colorPicker: SwiftHSVColorPicker!
    
    
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var eraserButton: UIButton!
    
    @IBAction func eraserPressed(_ sender: UIButton) {
        if(isEraserSelected == false){
            lastColor = currentColor
            currentColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
            eraserButton.setImage(UIImage(named: "pencil"), for: UIControlState.normal)
            hideEverything()
            isEraserSelected = true
        }
        else {
            currentColor = lastColor
            eraserButton.setImage(UIImage(named: "eraser"), for: UIControlState.normal)
            revealPalette()
            isEraserSelected = false
        }
    }
    
    func hideEverything(){
        paintPressed.isHidden=true;
    }
    
    @IBAction func clearEverything() {
        self.imageView.image = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bg:UIImage = bgImage {
            backgroundImageView.image = bg
        }
        
        slider.isHidden = true
        colorPressBtn.isHidden = true
        
        revealPalette()
        buttonCrazy()
        startRecording()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if(landscape) {
            return .landscape
        }
        return .portrait
    }
    
    func buttonCrazy(){
        stopButton.layer.cornerRadius = 40
        stopButton.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let bg:UIImage = bgImage {
            backgroundImageView.image = bg
        }
        
        let circlePath = UIBezierPath(arcCenter: thicknessButton.center, radius: CGFloat(thickness/2), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = currentColor.cgColor
        view.layer.addSublayer(shapeLayer)
        
        colorPicker = SwiftHSVColorPicker(frame: colorWheelFrame.frame)
        self.view.addSubview(colorPicker)
        
        slider.isHidden = true
        
        revealPalette()
        buttonCrazy()
    }
    
    func startRecording() {
        let recorder = RPScreenRecorder.shared()
        recorder.isCameraEnabled = true
        recorder.isMicrophoneEnabled = true
        
        recorder.startRecording { [unowned self] (error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                recorder.isMicrophoneEnabled = true
                if let cameraPreview = recorder.cameraPreviewView {
                    cameraPreview.frame = CGRect(x: 5, y: 5, width: 100, height: 117)
                    self.view.addSubview(cameraPreview)
                    cameraPreview.layer.borderWidth = 3
                    cameraPreview.layer.borderColor = UIColor(red:251/255, green:128/255, blue:47/255.0, alpha: 0.75).cgColor
                }
                
            }
        }
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.shared()
        
        recorder.stopRecording { [unowned self] (preview, error) in
            
            if let unwrappedPreview = preview {
                unwrappedPreview.previewControllerDelegate = self
                
                unwrappedPreview.popoverPresentationController?.sourceView = self.view
                unwrappedPreview.popoverPresentationController?.passthroughViews = [self.view]
                
                //self.view.isUserInteractionEnabled = false
                bgImage = nil
                self.present(unwrappedPreview, animated: true)
                
            }
        }
    }
    
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "homeVC")
        self.present(controller, animated: true, completion: nil)
    }
    
    func drawLines(fromPoint: CGPoint, toPoint: CGPoint){
        UIGraphicsBeginImageContext(self.view.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        let thk: CGFloat = CGFloat(thickness)/2
        context?.move(to: CGPoint(x:fromPoint.x, y: fromPoint.y - thk))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y - thk))
        
        if(!isEraserSelected){
            context?.setBlendMode(CGBlendMode.normal)
        } else {
            context?.setBlendMode(CGBlendMode.clear)
        }
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(CGFloat(thickness))
        context?.setStrokeColor(currentColor.cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        swiped = true
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func isPaintPressed() {
        //        hidePalette()
        
        colorPicker.setViewColor(currentColor)
        colorPicker.isHidden = false
        colorPressBtn.isHidden = false
    }
    
    @IBAction func colorPicked(_ sender: Any) {
        currentColor = colorPicker.color
        updateThickness()
        colorPressBtn.isHidden = true
        colorPicker.isHidden = true
    }
    
    func revealPalette(){
        paintPressed.isHidden=false;
    }
    
    func hidePalette(){
        paintPressed.isHidden=true;
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopRecording()
    }
    
    func updateThickness() {
        for layer in self.view.layer.sublayers! {
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        let circlePath = UIBezierPath(arcCenter: thicknessButton.center, radius: CGFloat(thickness/2), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        if(!isEraserSelected){
            shapeLayer.fillColor = currentColor.cgColor
        } else {
            shapeLayer.fillColor = lastColor.cgColor
        }
        view.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func thicknessPressed(_ sender: Any) {
        slider.isHidden = !slider.isHidden
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        thickness = Int(sender.value)
        updateThickness()
    }
    
    
}

