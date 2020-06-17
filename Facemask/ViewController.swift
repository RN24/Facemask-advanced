//
//  ViewController.swift
//  Facemask
//
//  Created by 西岡亮太 on 2020/06/17.
//  Copyright © 2020 西岡亮太. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        UIApplication.shared.isIdleTimerDisabled = false
        
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true // ダサいので無効化
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!//無効化
        
        // Set the scene to the view
        //sceneView.scene = scene//無効化
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.environmentTexturing = .automatic
//            configuration.frameSemantics = .personSegmentationWithDepth
//
//        // Run the view's session
//        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    private func resetTracking(){
        guard ARFaceTrackingConfiguration.isSupported else{
            return
        }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true

      
        //let options = [.resetTracking, .removeExistingAnchors]//letへの代入がうまく行かないのでコメントアウト
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])//直接入力

    }
    

    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    private let shipNode: SCNReferenceNode? = {
        let path = Bundle.main.path(forResource: "face",
            ofType: "scn",
            inDirectory: "art.scnassets")!
        let url = URL(fileURLWithPath: path)
        return SCNReferenceNode(url: url)
        
      
    }()
    
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        guard anchor is ARFaceAnchor else{
    return
    }
        
        if node.childNodes.isEmpty, let content = shipNode{
            content.load()
            
            let constraint = SCNBillboardConstraint()
            constraint.freeAxes = [.X, .Y]
            content.constraints = [constraint]
            

            
            node.addChildNode(content)
        }
    
    

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
}
