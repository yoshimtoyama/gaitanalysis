//
//  AssCommon.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/03.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class AssCommon {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    // 対象アセスメントの写真を取得する
 /*   static func getPhotoAssessmentList() -> JSON? {
        let jsonStr = AppCommon.getResourceString(forResource: "GetPhotoAssessments", ofType: "json")
        return JSON(string: jsonStr) // JSON読み込み
    }*/
    // 対象アセスメントの写真を取得する
   /* func getPhotoAssessmentList() -> JSON? {
        let jsonStr = AppCommon.getResourceString(forResource: "GetPhotoAssessments", ofType: "json")
        return JSON(string: jsonStr) // JSON読み込み
    }*/
    // 対象のアセスメントの入力を返す
    func getInputAssList() -> JSON {
        // マスタデータの取得
        let url = "\(AppConst.URLPrefix)ass/GetAssDTList/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAss["assMenuGroupId"].asInt!)/\(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!)/\(appDelegate.selectedMstAss["assItemId"].asInt!)/\(appDelegate.selectedImagePartsNum!)"
        let jsonStr = self.appCommon.getSynchronous(url)
        return JSON(string: jsonStr!) // JSON読み込み
    }
    func regAss(controller : UIViewController, photoFlag: String!, inputArray : [String], commentText: String!) -> Bool {
        // 利用者情報の取得
        let url = "\(AppConst.URLPrefix)ass/PostAssessmentDT"
       /* let params: [String: AnyObject] = [
            "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
            "AssID": appDelegate.selectedAss["assId"].asInt! as AnyObject,
            "AssMenuGroupID": appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject,
            "AssMenuSubGroupID": appDelegate.selectedMstAss["assMenuSubGroupId"].asInt! as AnyObject,
            "AssItemID": appDelegate.selectedMstAss["assItemId"].asInt! as AnyObject,
            "ImgPartsNo": appDelegate.selectedImagePartsNum as AnyObject,
            "CommentText": commentText as AnyObject,
            "PhotoFlag": photoFlag as AnyObject,
            "InputArray": inputArray as AnyObject*/
        let params: [String: AnyObject] = [
             "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
             "AssID": appDelegate.selectedAss["assId"].asInt! as AnyObject,
             "AssMenuGroupID": appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject,
            "AssMenuSubGroupID": appDelegate.subGroupID as AnyObject,
            "AssItemID": appDelegate.assItemID as AnyObject,
             "ImgPartsNo": appDelegate.selectedImagePartsNum as AnyObject,
             "CommentText": commentText as AnyObject,
             "PhotoFlag": photoFlag as AnyObject,
             "InputArray": inputArray as AnyObject
        ]
        
        let res = appCommon.postSynchronous(url, params:params)
        if !AppCommon.isNilOrEmpty(string: res.err) {
            AppCommon.alertMessage(controller: controller, title: "登録失敗", message: res.err)
            return false
        } else {
            return true
        }
    }
    func delAss(controller : UIViewController) -> Bool {
        // 利用者情報の取得
        let url = "\(AppConst.URLPrefix)ass/PostAssessmentDT"
        let params: [String: AnyObject] = [
            "CustomerID": appDelegate.selectedUser["customerID"].asInt! as AnyObject,
            "AssID": appDelegate.selectedAss["assId"].asInt! as AnyObject,
            "AssMenuGroupID": appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject,
            "AssMenuSubGroupID": appDelegate.selectedMstAss["assMenuSubGroupId"].asInt! as AnyObject,
            "AssItemID": appDelegate.selectedMstAss["assItemId"].asInt! as AnyObject,
            "PhotoFlag": AppConst.Flag.OFF.rawValue as AnyObject,
        ]
        
        let res = appCommon.postSynchronous(url, params:params)
        if !AppCommon.isNilOrEmpty(string: res.err) {
            AppCommon.alertMessage(controller: controller, title: "登録失敗", message: res.err)
            return false
        } else {
            return true
        }
    }
    // 画像取得する
    func getPhotoAssessmentList() -> JSON {
        // マスタデータの取得
        let url = "\(AppConst.URLPrefix)ass/GetAssPhotoFileBase64String/\(appDelegate.selectedUser["customerID"].asInt!)/\(appDelegate.selectedAss["assId"].asInt!)/\(appDelegate.selectedMstAss["assMenuGroupId"].asInt! as AnyObject)/\(appDelegate.selectedMstAss["assMenuSubGroupId"].asInt!)/\(appDelegate.selectedMstAss["assItemId"].asInt!)/\(appDelegate.photoAssList! ["seqno"].asInt!)"
        let jsonStr = appCommon.getSynchronous(url)
        return JSON(string: jsonStr!) // JSON読み込み
    }
}
