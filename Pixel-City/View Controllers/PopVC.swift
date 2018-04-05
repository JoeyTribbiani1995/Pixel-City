//
//  PopVC.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/5/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import UIKit

class PopVC: UIViewController {
    
    @IBOutlet weak var popImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PopVC.handleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        if let image = ImageService.instance.imageSelected {
            popImageView.image = image
        }
        
    }
    
    @objc func handleTap(_ recog : UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
    
   
    


}
