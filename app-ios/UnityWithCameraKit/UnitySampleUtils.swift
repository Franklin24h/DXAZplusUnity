//
//  UnitySampleUtils.swift
//  UnitySwift
//
//  Created by derrick on 2021/12/16.
//

import Foundation
import UIKit
#if canImport(UnityFramework)
import UnityFramework
#endif

class UnitySampleUtils {
    static func showAlert(_ title: String, _ msg: String, window: UIWindow?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_ action: UIAlertAction!) in })

        alert.addAction(defaultAction)
        window?.rootViewController?.present(alert, animated: true)
    }

#if canImport(UnityFramework)
    static func showAlertWithUnity(_ title: String, _ msg: String, window: UIWindow?, _ ufw: UnityFramework) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (_ action: UIAlertAction!) in
            ufw.unloadApplication()
        })
        alert.addAction(defaultAction)
        window?.rootViewController?.present(alert, animated: false, completion: nil)
    }
#else
    // Fallback when Unity is not available
    static func showAlertWithUnity(_ title: String, _ msg: String, window: UIWindow?, _ ufw: AnyObject? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        window?.rootViewController?.present(alert, animated: false, completion: nil)
    }
#endif
}
