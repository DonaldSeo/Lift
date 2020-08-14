//
//  PopAnimator.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-12.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  let duration = 0.8
  var presenting = true
  var originFrame = CGRect.zero

  var dismissCompletion: (() -> Void)?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let exerciseDetailView = transitionContext.view(forKey: presenting ? .to : .from)!
    
    let initialFrame = presenting ? originFrame : exerciseDetailView.frame
    let finalFrame = presenting ? exerciseDetailView.frame : originFrame

    let xScaleFactor = presenting ?
      initialFrame.width / finalFrame.width :
      finalFrame.width / initialFrame.width

    let yScaleFactor = presenting ?
      initialFrame.height / finalFrame.height :
      finalFrame.height / initialFrame.height

    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

    if presenting {
      exerciseDetailView.transform = scaleTransform
      exerciseDetailView.center = CGPoint(
        x: initialFrame.midX,
        y: initialFrame.midY)
      exerciseDetailView.clipsToBounds = true
    }

    exerciseDetailView.layer.cornerRadius = presenting ? 20.0 : 0.0
    exerciseDetailView.layer.masksToBounds = true
    
    
    containerView.addSubview(exerciseDetailView)
    containerView.bringSubviewToFront(exerciseDetailView)

    UIView.animate(
      withDuration: duration,
      delay:0.0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 0.2,
      animations: {
        exerciseDetailView.transform = self.presenting ? .identity : scaleTransform
        exerciseDetailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        exerciseDetailView.layer.cornerRadius = !self.presenting ? 20.0 : 0.0
      }, completion: { _ in
        transitionContext.completeTransition(true)
    })


  }
  

}
