//
//  AppConst.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/08/29.
//  Copyright © 2019 System. All rights reserved.
//

import Foundation

class AppConst {
    class var URLPrefix : String {
       //return "http://localhost:5900/api/"
        //return "https://pga.re-walk.com/api/"
        return "http://192.168.1.32/rewalk/api/" //外山さんのIP
        //return "http://192.168.10.19:5900/api/"
       // return "http://14.193.170.59:5900/api/"
    
    }
    class var ErrLogin : String {
        return "Err00002"
    }
    class var ErrStr : String {
        return "ErrCode"
    }

    /*
     選択肢の区切り文字
    */
    class var ChoiceSeparater : String {
        return "|"
    }
    /*
     フラグ
     */
    enum Flag : String {
        case ON = "1"
        case OFF = "0"
    }
    /*
     レポート作成区分
     */
    enum ReportCreateKbn : String {
        case NO = "1" // 未作成
        case REQUEST = "2" // 作成依頼済み
        case CREATED = "3" // 作成済み
    }
    /*
     入力区分
    */
    enum InputKB : String {
        case SINGLE = "1"
        case MULTI = "2"
        case INPUT = "3"
        case BIRTHDAY = "4"
        case PHOTO = "5"
        case INPUT_AREA = "6"
        case NPS = "7"
        case DATETIME = "8"
        case BARCODE = "9"
        case DRUG = "10"
        case BUI = "11"
        case VIDEO = "12"
        case HINDO = "20"
        case ITAMI = "21"
        case INPUT_AREA_READ_ONLY = "56" // 50番以降は読み取り専用
    }
    /*
    入力フォーマット
    */
    enum InputValueID : String {
        case NUM = "12"
        case ZENKAKU = "31"
    }
    /*
    シェーマ区分
    */
    enum SchemaKB : String {
        case NO_SCHEMA = "1"
        case SINGLE = "2"
        case MULTI = "3"
        case ONLY_SCHEMA_SINGLE = "4"//　内容いかない
        case ONLY_SCHEMA_MULTI = "5"//　内容いかない
        case ONLY_SCHEMA_PHOTO_SINGLE = "6"
        case ONLY_SCHEMA_PHOTO_MULTI = "7"
        case SINGLE_REQUIRE_PHOTO = "8"
        case MULTI_REQUIRE_PHOTO = "9"
        case ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO = "10"
        case ONLY_SCHEMA_PHOTO_MULTI_REQUIRE_PHOTO = "11"
    }
    // 認証用ヘッダー
    class var AuthorizationHeaderKey : String {
        return "Authorization"
    }
    // 認証用ヘッダー値のプレフィックス
    class var AuthorizationHeaderValuePrefix : String {
        return "Bearer "
    }
    enum AssMenuSubGroupID : String {
        case BASIC = "1"
        case MONSHIN = "2"
    }
}
