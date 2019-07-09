//
//  MyUrlManager.swift
//  JYWebViewDebug
//
//  Created by Bennie on 7/8/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

import Foundation

let urlKey = "urlkey"

class MyUrlManager: NSObject {
    class   func saveUrl(url:String) -> Void {
        guard url.count > 0 else {
            return
        }

        var urls:Array<String>? = UserDefaults.standard.value(forKey: urlKey) as? Array<String>
        if urls != nil
        {
            if !urls!.contains(url) {
                urls!.append(url)
                UserDefaults.standard.setValue(urls, forKey: urlKey)
            }
        }
        else
        {
            urls = Array.init()
            urls!.append(url)
            UserDefaults.standard.setValue(urls, forKey: urlKey)
        }
    }

    class   func urls() -> Array<String> {
        let urls:Array<String>? = UserDefaults.standard.value(forKey: urlKey) as? Array<String>
        guard urls != nil else {return Array.init()}
        return urls ?? Array.init()
    }

    class   func rmUrl(url:String)-> Void {
        guard url.count > 0 else {
            return
        }

        var urls:Array<String> = UserDefaults.standard.value(forKey: urlKey) as! Array<String>

        var dstIdx = -1
        for idx in 0...urls.count-1 {
            if url == urls[idx]
            {
                dstIdx = idx
            }
        }

        guard dstIdx != -1 else {
            return
        }

        if urls.contains(url) {
            urls.remove(at:dstIdx )
            UserDefaults.standard.setValue(urls, forKey: urlKey)
        }
    }
}
