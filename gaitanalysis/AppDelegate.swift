//
//  AppDelegate.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/27.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Login画面で取得したFirebaseユーザ
    var loginUser: JSON?
    var idToken: String!
    // ログイン情報
    var LoginInfo : JSON?
    // False：個人利用、True：法人利用
    var isFacility = false
    // 利用者一覧で選択された利用者情報
    var selectedUser: JSON!
    // イベント一覧で選択されたイベント情報
    var selectedEvent: JSON!
    /******************** 詳細画面で利用 start ********************/
    var viewDetailTitle: String!
    var viewDetailText: String!
    var viewDatailUnit: String!
    /******************** 詳細画面で利用 end ********************/
    
    // 選択されたアセスメントマスタ
    var selectedMstAss: JSON!
    // 選択されたアセスメントサブグループ
    var selectedMstAssSubGroup: JSON!
    // 選択されたアセスメント情報
    var selectedAss: JSON!
    // VideoViewのYを保存する。
    var videoContainerFrameOriginY: CGFloat?
    
    /********************Schema画面で利用 start ********************/
    // 選択されたSchemaを情報
    var assMstImagePartsList: JSON!
    var selectedImagePartsNum : Int! = 0
    var selectedMstAssessmentItem: JSON!
    //Schema情報取得したテータ
    var inputAssList: JSON!
    
    /********************Event画面で利用 start ********************/
    var eventList: JSON!
    var window: UIWindow?
    
    // ログイン情報
    //var LoginInfo : JSON?
    var LoginEmail: String!
    var LoginName: String!
    
    //photo情報取得したテータ
    var photoAssList: JSON?
    
    // ReportIrai= true -> can not update assessment
    var isReportIrai = false
    
    /********************保存するためAssessment情報データ ********************/
    var arrChoiceMulti : [assDataArray] = []
    var arrChoiceOne : [assDataOneArray] = []
    var subGroupID : Int!
    var assItemID:Int!
    var arrinputAccText : [assDataTextArray] = []
    var arrMediaList :[mediaArray] = []
    var goSegument: String!
    
    struct assDataArray: Identifiable {
        var id: Int
        var subGroupID : Int
        var cmtIntput : String
        var multiChoice: [String]
    }
    struct assDataOneArray: Identifiable {
        var id: Int
        var subGroupID : Int
        var oneChoice: [String]
        var cmtIntput : String
    }
    struct assDataTextArray: Identifiable {
        var id: Int
        var subGroupID : Int
        var textData: [String]
        var cmtIntput : String
    }
    struct mediaArray {
        var id: Int
        var subGroupID : Int
        var flgSave : Bool
    }
    
    override init() {
        super.init()
        // Firebase関連の機能を使う前に必要
        FirebaseApp.configure()
    }
    
    /******************** 利用者情報更新で利用 start ********************/
    var mstCustomerList: JSON?
    var selectedMstCustomer: JSON!
    var selectedCustomerValue: String!
    var ChangeCustomerInfo : Bool! = false
    /******************** 利用者情報更新で利用 end ********************/

    // 問診マスタ
    var mstMonshinAssSubGroupList: JSON?
    // アセスメントマスタ
    var mstAssList: JSON?
    // アセスメント更新されたフラグ（入力画面で値が変更された場合に立てる。一覧で表示を更新する為に使用する）
    var changeInputAssFlagForList: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        let appCommon = AppCommon()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        appCommon.saveAssessment(controller: (self.window?.rootViewController)!)
        // データリセット
        self.arrChoiceMulti.removeAll()
        self.arrChoiceOne.removeAll()
        self.arrinputAccText.removeAll()
        self.assItemID = nil
        self.subGroupID = nil
        self.saveContext()
    }
    // facebook&Google認証時に呼ばれる関数
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        // GoogleまたはFacebook認証の場合、trueを返す
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "gaitanalysis")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

