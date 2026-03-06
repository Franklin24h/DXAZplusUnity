//
//  AppDelegate.swift
//  UnitySwift
//
//  Created by derrick on 2021/10/30.
//

import SCSDKCameraKit
import SCSDKCameraKitReferenceUI
import UIKit
#if canImport(UnityFramework)
import UnityFramework
#endif
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    fileprivate var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown
    fileprivate var cameraViewController: UnityCameraViewController?

    var window: UIWindow?
    var appLaunchOpts: [UIApplication.LaunchOptionsKey: Any]?
    var unitySampleView: UnityUIView!
    var didQuit: Bool = false
    var locationManager: CLLocationManager?

#if canImport(UnityFramework)
    @objc public var unityFramework: UnityFramework?
#endif

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        ///PARCHE 1INICIO
        window = UIWindow(frame: UIScreen.main.bounds)

        let vc = UIViewController()
        vc.view.backgroundColor = .systemRed

        let label = UILabel()
        label.text = "DXAZ DEBUG"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
          label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
          label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        ///PARCHE 1 FIN
        
#if canImport(UnityFramework)
        unityFramework = getUnityFramework()


#endif
        //PARCHES 2 INICIO
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let root = storyboard.instantiateInitialViewController() else {
          fatalError("Main.storyboard NO tiene Initial View Controller (falta la flecha).")
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
                
        #if canImport(UnityFramework)
                initUnity()
        #endif

        //PARCHES 2 FIN
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
#if canImport(UnityFramework)
        if let unityFramework {
            unityFramework.appController()?.applicationWillResignActive(application)
        }
#endif
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
#if canImport(UnityFramework)
        if let unityFramework {
            unityFramework.appController()?.applicationDidEnterBackground(application)
        }
#endif
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
#if canImport(UnityFramework)
        if let unityFramework {
            unityFramework.appController()?.applicationWillEnterForeground(application)
        }
#endif
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
#if canImport(UnityFramework)
        if let unityFramework {
            unityFramework.appController()?.applicationDidBecomeActive(application)
        }
#endif
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        supportedOrientations
    }

    func applicationWillTerminate(_ application: UIApplication) {
#if canImport(UnityFramework)
        if let unityFramework {
            unityFramework.appController()?.applicationWillTerminate(application)
        }
#endif
    }

#if canImport(UnityFramework)
    // MARK: Unity API

    private func getUnityFramework() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"

        let bundle = Bundle(path: bundlePath)
        if bundle?.isLoaded == false {
            bundle?.load()
        }

        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header

            ufw!.setExecuteHeader(machineHeader)
        }
        return ufw
    }

    func unityIsInitialized() -> Bool {
        unityFramework != nil && unityFramework?.appController() != nil
    }

    func initUnity() {
        if let nativeWindow = window {
            if unityIsInitialized() {
                UnitySampleUtils.showAlert(
                    Constants.ErrorMessages.alreadyInitialized,
                    Constants.ErrorMessages.unloadFirst,
                    window: nativeWindow
                )
                return
            }

            if didQuit {
                UnitySampleUtils.showAlert(
                    Constants.ErrorMessages.cannotBeInitialized,
                    Constants.ErrorMessages.useUnload,
                    window: nativeWindow
                )
                return
            }
        }

        unityFramework = getUnityFramework()

        if let unityframework = unityFramework {
            unityframework.setDataBundleId("com.unity3d.framework")
            unityframework.register(self)
            NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
            unityframework.runEmbedded(
                withArgc: CommandLine.argc,
                argv: CommandLine.unsafeArgv,
                appLaunchOpts: appLaunchOpts
            )
        }
    }

    func unloadButtonTouched(_ sender: UIButton) {
        unloadUnity()
    }

    func quitButtonTouched(_ sender: UIButton) {
        if !unityIsInitialized() {
            UnitySampleUtils.showAlert(
                Constants.ErrorMessages.notInitialized,
                Constants.ErrorMessages.initFirst,
                window: window
            )
        } else {
            if let unityFramework = getUnityFramework() {
                unityFramework.quitApplication(0)
            }
        }
    }

    private func unloadUnityInternal() {
        if let unityFramework {
            unityFramework.unregisterFrameworkListener(self)
        }
        unityFramework = nil

        if let nativeWindow = window {
            nativeWindow.makeKeyAndVisible()
        }
    }

    private func unloadUnity() {
        if !unityIsInitialized() {
            UnitySampleUtils.showAlert(
                Constants.ErrorMessages.notInitialized,
                Constants.ErrorMessages.initFirst,
                window: window
            )
            return
        } else {
            if let unityFramework = getUnityFramework() {
                unityFramework.unloadApplication()
            }
        }
    }

    func unityDidUnload(_ notification: Notification!) {
        unloadUnityInternal()
    }

    func unityDidQuit(_ notification: Notification!) {
        unloadUnityInternal()
        didQuit = true
    }
#endif
}

extension AppDelegate: AppOrientationDelegate {
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        supportedOrientations = orientation
    }

    func unlockOrientation() {
        supportedOrientations = .allButUpsideDown
    }
}

extension AppDelegate {
    func invokeCameraKit(
        withLens lensId: String!,
        withGroupID groupId: String!,
        withRemoteAPISpecId remoteApiSpecId: String!,
        withLaunchData launchData: [String: String]!,
        withRenderMode renderMode: NSNumber!,
        withCameraMode cameraMode: NSNumber!,
        withShutterButtonMode shutterButtonMode: NSNumber!,
        withUnloadLensOption unloadLens: Bool
    ) {
        
        print("✅ invokeCameraKit() lensId:", lensId ?? "nil")
        print("✅ invokeCameraKit() groupId:", groupId ?? "nil")
        
        
        let cameraController = UnityCameraController()
        
        if (cameraViewController == nil) {
            cameraViewController = UnityCameraViewController(cameraController: cameraController)
        }
        // ===== OBSERVER (UNICO) INICIO =====

        // 1) Limpia estado anterior (importante al cambiar lens)
        cameraViewController?.applyLensId = nil
        cameraViewController?.applyGroupId = nil

        // 2) Siempre observa el grupo
        cameraController.cameraKit.lenses.repository.addObserver(
            cameraViewController!,
            groupID: groupId
        )
        cameraViewController?.applyGroupId = groupId

        // 3) Si hay lensId => observa/aplica SOLO esa lens
        if let lensId = lensId, !lensId.isEmpty {
            cameraController.cameraKit.lenses.repository.addObserver(
                cameraViewController!,
                specificLensID: lensId,
                inGroupID: groupId
            )
            cameraViewController?.applyLensId = lensId
        } else {
            cameraViewController?.applyLensId = nil
        }

        // ===== OBSERVER (UNICO) FIN =====
    
        cameraViewController?.appOrientationDelegate = self
        cameraViewController?.applyLensId = lensId;
        cameraViewController?.applyGroupId = groupId;
        cameraViewController?.launchDataFromUnity = launchData;
        cameraViewController?.cameraView.carouselView.isHidden = true
        cameraViewController?.shutterButtonMode = shutterButtonMode
        cameraViewController?.clearLensAfterDismiss = unloadLens;
        cameraViewController?.selectedCamera = cameraMode;
        
        if (renderMode == Constants.RenderMode.BehindUnity) { 
            invokeCameraKitAsBackgroundLayer()
        } else {
            invokeCameraKitAsModalFullScreen()
        }
    
        if (shutterButtonMode == Constants.ShutterButtonMode.On) {
            cameraViewController?.cameraView.cameraButton.isHidden = false
        } else if (shutterButtonMode == Constants.ShutterButtonMode.Off) {
            cameraViewController?.cameraView.cameraButton.isHidden = true
        } else if (shutterButtonMode == Constants.ShutterButtonMode.OnlyOnFrontCamera) {
            if (cameraViewController?.cameraController.cameraPosition == .front) {
                cameraViewController?.cameraView.cameraButton.isHidden = false
            } else {
                cameraViewController?.cameraView.cameraButton.isHidden = true
            }
        }
        
    }
    
    func invokeCameraKitAsModalFullScreen() {
#if canImport(UnityFramework)
        unityFramework?.pause(true)
#endif
       // OPEN CAMARA INICIO
        let navVC = UINavigationController(rootViewController: cameraViewController!)
        navVC.modalPresentationStyle = .fullScreen
        // Presentar SIEMPRE la UI de Camera Kit (sin depender de UnityFramework)
        if let root = window?.rootViewController {
            root.present(navVC, animated: true)
        } else {
            print("❌ No window.rootViewController para presentar Camera Kit")
        }
        
        //OPEN CAMARA FINAL
        
        cameraViewController?.hideCameraUiControls(hide: false);
    }

    func invokeCameraKitAsBackgroundLayer() {
        if let nativeWindow = window {
#if canImport(UnityFramework)
            unityFramework?.appController().rootView.backgroundColor = UIColor.black.withAlphaComponent(0.0);
#endif
            nativeWindow.rootViewController?.add(cameraViewController!, frame: UIScreen.main.bounds)
        }
        cameraViewController?.hideCameraUiControls(hide: true);
    }
    
    func updateLensState(_ launchData: [String : String]!) {
        LensRequestStateApiServiceCall.updateAppState(appState: launchData)
    }
    
    func dismissCameraKit() {
#if canImport(UnityFramework)
        unityFramework?.appController().rootView.backgroundColor = UIColor.black;
#endif
        cameraViewController?.remove();
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.requestWhenInUseAuthorization()
    }
}

class UnityCameraViewController: CameraViewController  {
    
    fileprivate var launchDataFromUnity: [String: String]?
    fileprivate var applyLensId: String?
    fileprivate var applyGroupId: String?
    fileprivate var shutterButtonMode: NSNumber?
    fileprivate var clearLensAfterDismiss: Bool = false
    fileprivate var selectedCamera: NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf) )
        cameraController.uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let lens = cameraController.cameraKit.lenses.repository.lens(id: applyLensId!, groupID: applyGroupId!)
        let launchDataBuilder = LensLaunchDataBuilder()
        launchDataFromUnity?.forEach {
            launchDataBuilder.add(string: $1, key: $0)
        }
        let launchDataToLens = launchDataBuilder.launchData ?? EmptyLensLaunchData()
        if (lens != nil) {
            cameraController.cameraKit.lenses.processor?.apply(lens: lens!, launchData: launchDataToLens)
        }
                
        if ((selectedCamera == Constants.Device.BackCamera && cameraController.cameraPosition == .front)
            || (selectedCamera == Constants.Device.FrontCamera && cameraController.cameraPosition == .back)) {
            cameraController.flipCamera()
        }
    }

    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
#if canImport(UnityFramework)
        appDelegate.unityFramework?.pause(false)
        appDelegate.unityFramework?.sendMessageToGO(withName: "CameraKitHandler", functionName: "MessageCameraKitDismissed", message:"")
#endif
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (clearLensAfterDismiss) {
            clearLens()
            cameraController.cameraKit.stop()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.cameraViewController = nil
        }
    }
    
    fileprivate func hideCameraUiControls(hide: Bool) {
        cameraView.cameraActionsView.isHidden = hide
    }
    
    
    // To get ShutterButtonMode.OnlyOnFrontCamera to work:
    // 1- Mark the function flip() as "open" in CameraViewController
    // 2- Uncomment the function below
    
//    override func flip(sender: Any) {
//        super.flip(sender: sender)
//        if (shutterButtonMode == Constants.ShutterButtonMode.OnlyOnFrontCamera) {
//            if (cameraController.cameraPosition == .front) {
//                cameraView.cameraButton.isHidden = false
//            } else if (cameraController.cameraPosition == .back) {
//                cameraView.cameraButton.isHidden = true
//            }
//        }
//    }
    
}
    
class UnityCameraController: CameraController {
    
    override init(cameraKit: CameraKitProtocol, captureSession: AVCaptureSession) {
        super.init(cameraKit: cameraKit, captureSession: captureSession)
    }
    
    override func configureDataProvider() -> DataProviderComponent {
        DataProviderComponent(
            deviceMotion: nil, userData: UserDataProvider(), lensHint: nil, location: nil,
            mediaPicker: lensMediaProvider, remoteApiServiceProviders: [UnityRemoteApiServiceProvider()]
        )
    }
    
    override func takePhoto(completion: ((UIImage?, Error?) -> Void)?) {
        super.takePhoto(completion: {image, error in
            let pathToSavedImage = self.saveImageToDocumentsDirectory(image: image!, withName: "CameraKitOutput.png")
            if (pathToSavedImage == nil) {
                print("Error. Failed to save image")
            }
            DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
#if canImport(UnityFramework)
                appDelegate.unityFramework?.sendMessageToGO(withName: "CameraKitHandler", functionName: "MessageCameraKitCaptureResult", message: pathToSavedImage)
#endif
                appDelegate.cameraViewController?.dismiss(animated: true)
            }
        })
        
    }
    
    override func finishRecording(completion: ((URL?, Error?) -> Void)?) {
        super.finishRecording(completion: {url, error in
            DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
#if canImport(UnityFramework)
                appDelegate.unityFramework?.sendMessageToGO(withName: "CameraKitHandler", functionName:  "MessageCameraKitCaptureResult", message: url?.absoluteString)
#endif
                appDelegate.cameraViewController?.dismiss(animated: true)
            }
        })
    }
    
    func getDocumentDirectoryPath() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, withName: String) -> String? {
        if let data = image.pngData() {
            let dirPath = getDocumentDirectoryPath()
            let imageFileUrl = URL(fileURLWithPath: dirPath.appendingPathComponent(withName) as String)
            do {
                try data.write(to: imageFileUrl)
                print("Successfully saved image at path: \(imageFileUrl)")
                return imageFileUrl.absoluteString
            } catch {
                print("Error saving image: \(error)")
            }
        }
        return nil
    }
}

extension UnityCameraViewController: LensRepositorySpecificObserver, LensRepositoryGroupObserver {

  func repository(_ repository: LensRepository, didUpdateLenses lenses: [Lens], forGroupID groupID: String) {
    print("✅ didUpdateLenses groupID:", groupID, "count:", lenses.count)
    for (i, lens) in lenses.enumerated() {
        print("  [\(i)] id: \(lens.id) name: \(lens.name ?? "nil")")
    }
  }

  func repository(_ repository: LensRepository, didFailToUpdateLensesForGroupID groupID: String, error: Error?) {
      print("❌ didFailToUpdateLensesForGroupID groupID:", groupID)
      if let error = error {
        print("   error:", error)
        print("   localized:", error.localizedDescription)
      } else {
        print("   error: nil")
      }
  }

  func repository(_ repository: LensRepository, didUpdate lens: Lens, forGroupID groupID: String) {
    print("✅ didUpdate lens:", lens.id, "name:", lens.name, "groupID:", groupID)
  }

  func repository(_ repository: LensRepository, didFailToUpdateLensID lensID: String, forGroupID groupID: String, error: Error?) {
    print("❌ didFailToUpdateLensID lensID:", lensID, "groupID:", groupID, "error:", error ?? "nil")
  }
}

        // OJO CON ESTA PARTE FIN
@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }
        // OJO CON ESTA PARTE FIN

        //        view.addSubview(child.view)
  
        view.insertSubview(child.view, at: 1)
        child.didMove(toParent: self)
    }
    

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
