//
//  TransitionViewController.swift
//  Collab
//
//  Created by Anirudh Natarajan on 4/16/17.
//  Copyright © 2017 Kodikos. All rights reserved.
//


import UIKit

var countdownInt = 3
var timer = Timer()

class TransitionViewController: UIViewController {

    @IBOutlet var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownInt = 3
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        countdownInt = 3
        super.viewDidAppear(true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if(landscape) {
            return .landscape
        }
        return .portrait
    }

    func update() {
        if countdownInt > 0 {
            countdownInt -= 1
            let numberFromString = String(countdownInt)
            countdownLabel.text = numberFromString
        }
        else {
            countdownInt = 3
            timer.invalidate()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "drawVC")
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
