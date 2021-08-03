//
//  DetailEventDetail.swift
//  gaitanalysis
//
//  Created by ToyamaYoshimasa on 2019/09/02.
//  Copyright © 2019 System. All rights reserved.
//

import UIKit

class DetailEventDetail: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    let sections: NSArray = ["イベント基本情報", "時間と場所", "ウェブサイト", "画像"]
    let basicItems: NSArray = ["名称","詳細"]
    let timeLocationItems: NSArray = ["施設名", "講師", "対象", "制限", "参加料", "日時"]
    let websiteItems: NSArray = ["URL"]
    let reuseidentifier = "dynamicCellTableViewCell"
    var imageItems:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
        let selectedEvent = appDelegate.selectedEvent as JSON
        let imagePath = selectedEvent["imageMainUrl"].asString ?? ""
        let imagePath1 = selectedEvent["imageSubUrl1"].asString ?? ""
        let imagePath2 = selectedEvent["imageSubUrl2"].asString ?? ""
        let imagePath3 = selectedEvent["imageSubUrl3"].asString ?? ""
        if !imagePath .isEmpty{
            imageItems.insert(imagePath, at: 0)
        }
        if !imagePath1 .isEmpty{
            imageItems.insert(imagePath1, at: 1)
        }
        if !imagePath2 .isEmpty{
            imageItems.insert(imagePath2, at: 2)
        }
        if !imagePath3 .isEmpty{
            imageItems.insert(imagePath3, at: 3)
        }
    }
    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return basicItems.count
        } else if section == 1 {
            return timeLocationItems.count
        } else if section == 2 {
            return websiteItems.count
        } else if section == 3 {
            return imageItems.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if indexPath.section == 3 {
            let imagePath = imageItems[indexPath.row]
                let url = URL(string:imagePath)!
                do {
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)
                    return ((image?.size.height)! + 40)
                } catch {
                    print(error.localizedDescription)
                }
            }
         return super.tableView(tableView, heightForRowAt: indexPath)
      }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath as NSIndexPath
        
        let selectedEvent = appDelegate.selectedEvent as JSON
        if index.section == 0 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(basicItems[index.row])"
            if index.row == 0 {
                cell.detailTextLabel?.text = selectedEvent["eventName"].asString!
            } else if index.row == 1 {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator // 詳細矢印
                cell.detailTextLabel?.text = selectedEvent["detail"].asString!
            }
            return cell
        } else if index.section == 1 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(timeLocationItems[index.row])"
            if index.row == 0 {
                cell.detailTextLabel?.text = selectedEvent["place"].asString!
            } else if index.row == 1 {
                cell.detailTextLabel?.text = selectedEvent["teacher"].asString!.isEmpty ? "" : selectedEvent["teacher"].asString!
            } else if index.row == 2 {
                cell.detailTextLabel?.text = selectedEvent["target"].asString!.isEmpty ? "" : selectedEvent["target"].asString!
            } else if index.row == 3 {
                cell.detailTextLabel?.text = selectedEvent["limit"].isNull ? "" : selectedEvent["limit"].asString!
            } else if index.row == 4 {
                cell.detailTextLabel?.text = selectedEvent["entryFee"].asString!.isEmpty ? "" : selectedEvent["entryFee"].asString!
            }else if index.row == 5 {
                // The default timeZone for ISO8601DateFormatter is UTC
                let utcISODateFormatter = ISO8601DateFormatter()

                // Printing a Date
                let date = Date()
                print(utcISODateFormatter.string(from: date))

                // Parsing a string timestamp representing a date
                let startDateString = selectedEvent["fromDateTime"].isNull ? "" : selectedEvent["fromDateTime"].asString!
                let toDateString = selectedEvent["toDateTime"].isNull ? "" : selectedEvent["toDateTime"].asString!
                let sutcDate = startDateString.isEmpty ? nil :   utcISODateFormatter.date(from:startDateString)
                let tutcDate = toDateString.isEmpty ? nil : utcISODateFormatter.date(from:toDateString)

                if sutcDate == nil{
                    cell.detailTextLabel?.text = " ~ \(AppCommon.convertDateStringFromServerDate(fromDateString: utcISODateFormatter.string(from: tutcDate!), format: "yyyy-MM-dd HH:MM"))"
                }else if tutcDate == nil {
                    cell.detailTextLabel?.text = "\(AppCommon.convertDateStringFromServerDate(fromDateString: utcISODateFormatter.string(from: sutcDate!), format: "yyyy-MM-dd HH:MM")) ~"
                }
                else{
                    cell.detailTextLabel?.text = "\(AppCommon.convertDateStringFromServerDate(fromDateString: utcISODateFormatter.string(from: sutcDate!), format: "yyyy-MM-dd HH:MM")) ~ \(AppCommon.convertDateStringFromServerDate(fromDateString: utcISODateFormatter.string(from: tutcDate!), format: "yyyy-MM-dd HH:MM"))"
                }
               
            }
        return cell
        } else if index.section == 2 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            let url = selectedEvent["url"].asString ?? ""
            cell.textLabel?.textAlignment = NSTextAlignment.center
            if AppCommon.isNilOrEmpty(string: url) {
                cell.textLabel?.text = "WEBサイトなし"
            } else {
                cell.textLabel?.text = "WEBサイトを開く"
                cell.textLabel?.textColor = UIColor.blue
            }
            
            return cell
        }else if index.section == 3 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            let url = imageItems[index.row]
            cell.textLabel?.textAlignment = NSTextAlignment.center
            if !AppCommon.isNilOrEmpty(string: url) {
                let url = URL(string:url)!
                do {
                        let data = try Data(contentsOf: url)
                            // 取得した画像表示
                    let image = UIImage(data: data)
                    let iconImageView = UIImageView()
                    iconImageView.frame = CGRect(x: 200, y: 20, width: cell.frame.width, height: (image?.size.height)!)
                    iconImageView.image = image
                    cell.addSubview(iconImageView)
                        
                } catch {
                    print(error.localizedDescription)
                }
                    
            }
           
            return cell
        }else  {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            return cell
        }
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath as NSIndexPath
        if index.section == 0 {
            if index.row == 1 { // 詳細表示
                // 表示する詳細を設定する
                appDelegate.viewDetailTitle = "\(basicItems[1])"
                appDelegate.viewDetailText = appDelegate.selectedEvent["detail"].asString!
                // 遷移
                performSegue(withIdentifier: "SegueViewEventDetail",sender: self)
            }
        } else if index.section == 1 {
            print("キャンセル")
        } else if index.section == 2 {
            let selectedEvent = appDelegate.selectedEvent as JSON
            let url = selectedEvent["url"].asString ?? ""
            if !AppCommon.isNilOrEmpty(string: url) {
                // ブラウザ起動
                let nsUrl = URL(string:"\(url)")
                UIApplication.shared.open(nsUrl!,options:[:],completionHandler:nil)
            }
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
