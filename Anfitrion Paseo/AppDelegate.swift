//
//  AppDelegate.swift
//  Anfitrion Paseo
//
//  Created by Macbook on 19/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import UIKit

/*
 Funcion para determinar un maximo de caracteres a un UITextField
 */
private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
}

/*
 Funcion para determinar un minimo de caracteres a un UITextField, FUNCION ESPECIAL PARA ESTA APP NO ES GENERICA
*/
private var __minLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var minLength: Int {
        get {
            guard let l = __minLengths[self] else {
                return 0 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __minLengths[self] = newValue
            addTarget(self, action: #selector(fixx), for: .editingDidEnd)
            addTarget(self, action: #selector(initing), for: .editingDidBegin)
        }
    }
    func fixx(textField: UITextField) {
        let contador = textField.text!.characters.count
        if (contador < 1) {
            textField.backgroundColor = UIColor.white
        } else if (contador < minLength) {
            textField.backgroundColor = UIColor.red
        }
    }
    func initing(textField: UITextField) {
        textField.backgroundColor = UIColor.white
    }
}

// funcion para setear el maximo de un text
extension String
{
    func safelyLimitedTo(length n: Int)->String {
        let c = self.characters
        if (c.count <= n) { return self }
        return String( Array(c).prefix(upTo: n) )
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

