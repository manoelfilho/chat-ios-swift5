//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Lottie

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var buttonRegister: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    
    let animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonRegister.layer.cornerRadius = 35.0
        buttonLogin.layer.cornerRadius = 35.0
        setupAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func setupAnimation() {
        animationView.animation = Animation.named("chatjs")
        animationView.frame = CGRect(x: 0, y:-100, width: 150, height: 150)
        animationView.center = view.center
        animationView.backgroundColor = #colorLiteral(red: 1, green: 0.7800406814, blue: 0, alpha: 1)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        
    }
    
}
