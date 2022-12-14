//
//  ViewController.swift
//  OE
//
//  Created by 서정덕 on 2022/12/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var uploadFilterSegment: UISegmentedControl!
    
    @IBAction func uploadFilterValueChanged(_ sender: UISegmentedControl) {
        print("HomeVC - uploadFilterValueChanged() called /index: \(sender.selectedSegmentIndex) ")
    }
    @IBAction func onUploadButtonClicked(_ sender: Any) {
        var segueId: String = ""
                
                switch uploadFilterSegment.selectedSegmentIndex {
                case 0:
                    print("물체 인식으로 이동")
                    segueId = "goToObject"
                case 1:
                    print("문서 인식으로 이동")
                    segueId = "goToOCR"
                default:
                    print("default, 물체 인식으로 이동")
                    segueId = "goToObject"
                }
        self.performSegue(withIdentifier: segueId, sender: self)
    }
    
    @IBAction func unwindToFirst(_ unwindSegue: UIStoryboardSegue) {
            
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

