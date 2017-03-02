//
//  LauncherAnimationViewController.swift
//  POTD
//
//  Created by Jeremy Conley on 2/18/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class LauncherAnimationViewController: UIViewController {
    
    let logoImg: UIImageView = {
        let imgView = UIImageView()
        imgView.image = #imageLiteral(resourceName: "HiliteLetters")
        return imgView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(logoImg)
        logoImg.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 200, height: 200)
        logoImg.center = self.view.center
        
        
        UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseOut, animations: {
            self.logoImg.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 100, height: 100)
            self.logoImg.center = self.view.center
            }) { (completed) in
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.logoImg.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 2000, height: 4000)
                    self.view.backgroundColor = .white
                    self.logoImg.center = self.view.center
                }) { (completed) in
                    self.performSegue(withIdentifier: "toRootController", sender: self)
                }
                
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
