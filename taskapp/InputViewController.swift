//
//  InputViewController.swift
//  taskapp
//
//  Created by Kusanagi Shuichi on 2022/03/03.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        categoryTextField.text = task.category
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        
        try! realm.write {
            
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text!
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
            
        }
        
        super.viewWillDisappear(animated)
                
    }
    
    
    //タスクのローカル通知を登録する
    func setNatification(task: Task) {
        
        let content = UNMutableNotificationContent()
        
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            
            content.title = "(タイトルなし)"
            
        } else {
            
            content.title = task.title
            
        }
        
        if task.contents == "" {
            
            content.body = "(内容なし)"
            
        } else {
            
            content.body = task.contents
            
        }
        
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nilならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                
                print("/---------------")
                print(request)
                print("---------------/")
                
            }
        }
        
    }
    
    
    @objc func dismissKeyboard() {
        
        //キーボードを閉じる
        view.endEditing(true)
        
    }

}
