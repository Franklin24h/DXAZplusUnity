//
//  ViewController.swift
//  UnitySwift
//
//  Created by derrick on 2021/10/30.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBlue
  }

  @IBAction func openCameraTapped(_ sender: Any) {
      
      print("🟦 BOTON: openCameraTapped")
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

      
    // ✅ Pega aquí tus IDs reales
    let lensId = ""
    let groupId = "1a1edb69-75f3-4d74-b97d-a6983c3d992b"

      print("🟦 Voy a invokeCameraKit")
      
      
    // Llama al método del sample (Camera Kit)
    appDelegate.invokeCameraKit(
      withLens: lensId,
      withGroupID: groupId,
      withRemoteAPISpecId: "",
      withLaunchData: [:],
      withRenderMode: 0,
      withCameraMode: 0,
      withShutterButtonMode: 0,
      withUnloadLensOption: false
    )
  }
}
