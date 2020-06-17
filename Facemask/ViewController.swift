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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var faceNode = SCNNode()
    private var virtualFaceNode = SCNNode()
    private let serialQueue = DispatchQueue(label: "com.test.FaceTracking.serialSceneKitQueue")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Face Tracking が使えなければ、これ以下の命令を実行を実行しない
           guard ARFaceTrackingConfiguration.isSupported else { return }
        

        UIApplication.shared.isIdleTimerDisabled = true
   

        
        // ARSCNView と ARSession のデリゲート、周囲の光の設定
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        // virtualFaceNode に ARSCNFaceGeometry を設定する
        let device = sceneView.device!
        let maskGeometry = ARSCNFaceGeometry(device: device)!

        maskGeometry.firstMaterial?.diffuse.contents = UIColor.lightGray
        maskGeometry.firstMaterial?.lightingModel = .physicallyBased

        virtualFaceNode.geometry = maskGeometry
        
        // トラッキングの初期化を実行
        resetTracking()
        
       self.addTapGesture()
        
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
 
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true

      
        //let options = [.resetTracking, .removeExistingAnchors]//letへの代入がうまく行かないのでコメントアウト
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])//直接入力

    }
    
    // Face Tracking の起点となるノードの初期設定
    private func setupFaceNodeContent() {
        // faceNode 以下のチルドノードを消す
        for child in faceNode.childNodes {
            child.removeFromParentNode()
        }
        
        // ARNodeTracking 開始
//        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//            faceNode = node
//            serialQueue.async {
//                self.setupFaceNodeContent()
//            }
//        }
        
        // マスクのジオメトリの入った virtualFaceNode をノードに追加する
        faceNode.addChildNode(virtualFaceNode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
//    private let shipNode: SCNReferenceNode? = {
//        let path = Bundle.main.path(forResource: "face",
//            ofType: "scn",
//            inDirectory: "art.scnassets")!
//        let url = URL(fileURLWithPath: path)
//        return SCNReferenceNode(url: url)
   
     //   var shipNode = virtualFaceNode
    
      
  //  }()
    
    

 //    Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        faceNode = node
               serialQueue.async {
                   self.setupFaceNodeContent()
               }
           }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        let geometry = virtualFaceNode.geometry as! ARSCNFaceGeometry
        geometry.update(from: faceAnchor.geometry)
    }
//        guard anchor is ARFaceAnchor else{
//    return
//    }

//        if node.childNodes.isEmpty, let content = shipNode{
//            content.load()
//
//            let constraint = SCNBillboardConstraint()
//            constraint.freeAxes = [.X, .Y]
//            content.constraints = [constraint]
//
//
//
//            node.addChildNode(shipNode)
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


extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // タップジェスチャ設定
    func addTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    // タップジェスチャ動作時の関数
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary) != false) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated:true, completion:nil)
        }else{
            print("fail")
        }
    }
    
    // フォトライブラリで画像選択時の処理
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // オリジナルサイズの画像を選択
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        
        // マスクにテクスチャを反映させる
        virtualFaceNode.geometry?.firstMaterial?.diffuse.contents = pickedImage

        // UIImagePickerController を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    // フォトライブラリでキャンセルタップ時の処理
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController を閉じる
        dismiss(animated: true, completion: nil)
    }
}
