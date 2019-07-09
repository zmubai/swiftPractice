//
//  ViewController.swift
//  JYWebViewDebug
//
//  Created by Bennie on 7/3/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,XFPingDelegate {
    // MARK:tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "cell")
        cell.textLabel?.text = dataSource![indexPath.row]

        if self.pingResultDict != nil {
            let pingRes:Float? = self.pingResultDict![dataSource![indexPath.row]]
            if let kPingRes = pingRes{
                cell.detailTextLabel?.text = String(kPingRes) + "ms"
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webVC = WebViewController()
        webVC.urlStr = "http://" +  dataSource![indexPath.row]
        self.navigationController?.pushViewController(webVC, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle==UITableViewCell.EditingStyle.delete {
            MyUrlManager.rmUrl(url: dataSource![indexPath.row])
            self.dataSource!.remove(at: indexPath.row)
            self.resetPingArray(urls: self.dataSource)
            self.tableView?.reloadData()
        }
    }

    var tableView:UITableView?;
    var dataSource:Array<String>?;
    var pingResultDict:Dictionary<String,Float>?
    var pingDict:Dictionary<String,XFPingTester>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "书签"
        dataSource = MyUrlManager.urls()
        if dataSource == nil {
            dataSource = Array.init()
        }
        self.resetPingArray(urls: self.dataSource)
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: UITableView.Style.plain)
        self.view.addSubview(tableView!)
        self.tableViewSetup()
        dataSource = MyUrlManager.urls()
        self.addLeftNavBtn()
        self.addRightNavBtn()
    }

    func tableViewSetup(){
        tableView?.rowHeight = 44;
        tableView?.tableFooterView = UIView.init()
        self.tableView?.delegate = self;
        self.tableView?.dataSource = self;
    }

    func addRightNavBtn() -> Void {
        let btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 40))
        btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        btn.setTitle("addUrl", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(self.addUrlAction), for: UIControl.Event.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
    }

    func addLeftNavBtn() -> Void {
        let btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 40))
        btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        btn.setTitle("ping", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(self.pingAction), for: UIControl.Event.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: btn)
    }

    @objc func addUrlAction() -> Void {
        let alertVc = UIAlertController.init(title: "提示😸", message: "添加url", preferredStyle: UIAlertController.Style.alert)
        alertVc.addTextField { (textField) in

        }

        alertVc.addAction(UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            let textfield:UITextField! = alertVc.textFields?.first
            guard textfield.text != nil else {
                return;
            }
            self.dataSource?.append(textfield.text!)
            self.tableView?.reloadData()
            MyUrlManager.saveUrl(url: textfield.text!)
            self.resetPingArray(urls: self.dataSource)
        }))
        alertVc.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: { (action) in
            print("取消");
        }))
        self.navigationController?.present(alertVc, animated: true, completion: {

        })
    }

    @objc func pingAction() -> Void {
        self.resetPingArray(urls: self.dataSource)
    }

    func resetPingArray (urls:Array<String>?) -> Void {
        guard urls != nil else {
            return
        }
        self.pingDict = Dictionary.init()
        for url in urls! {
            let pingObjc = XFPingTester.init(hostName: url)
            pingObjc?.delegate = self as XFPingDelegate
            self.pingDict!.updateValue(pingObjc!, forKey: url)
            pingObjc?.startPing();
        }
    }

    func didPingSucccess(withHostName hostName: String!, withTime time: Float, withError error: Error!) {
        if self.pingResultDict == nil{
            self.pingResultDict = Dictionary.init()
        }
        if error == nil {
            self.pingResultDict?.updateValue(time, forKey: hostName)
        }
        else
        {
            self.pingResultDict?.updateValue(0.0, forKey: hostName)
        }
        self.tableView?.reloadData()
        if self.pingDict != nil {
             let pingtexter = self.pingDict![hostName!]
            if pingtexter != nil {
                pingtexter?.stopPing()
            }
        }
    }

}

