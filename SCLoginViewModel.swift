//
//  SCLoginViewModel.swift
//  SinaAutoDriver
//
//  Created by dengyanzhou on 16/5/3.
//  Copyright © 2016年 SInaAuto. All rights reserved.
//

import UIKit
class SCLoginViewModel: NSObject {
    
    //发送验证码
    class func sendAuthCode(mobile:String!,complete finished:(error:NSError?) -> Void) -> Void {
        SCHttpTools.sharedHttpTools().POSTWithUrlString("interface2/driver/identifyingCode",
                                                        parameters:["mobile":mobile] ,
                                                        reqIdentify:"interface2/driver/identifyingCode",
                                                        successBlock: {(task, responseObject) in
                                                            if let responseData:[String:AnyObject] = responseObject as? Dictionary{
                                                                if let code =  responseData["code"] as? NSNumber{
                                                                    if Int(code) == 10000{
                                                                        finished(error: nil)
                                                                    }else{
                                                                        let mesg = responseData["mesg"];
                                                                        let mesgStr =  mesg as! String
                                                                        let error = NSError.init(domain:"544.sina.cn", code: 10001, userInfo: [NSLocalizedDescriptionKey:mesgStr])
                                                                        finished(error: error)
                                                                    }
                                                                }
                                                            }else{
                                                                let error = NSError.init(domain:"544.sina.cn", code: 10005, userInfo: [NSLocalizedDescriptionKey:"类型转换失败"])
                                                                finished(error:error)
                                                            }
            },
                                                        failBlock: {(error)in
                                                            finished(error: error)

            }
        )
    }
    // 用户登录
    class  func userLogin(withParas paras:[NSObject:AnyObject],complete finished:(error:NSError?) ->  Void) -> Void {
        SCHttpTools.sharedHttpTools().POSTWithUrlString("interface2/driver/login",
                                                        parameters: paras,
                                                        reqIdentify:"interface/driver/login",
                                                        successBlock: {(task, responseObject) in
                                                            if let responseData:[String:AnyObject] = responseObject as? Dictionary{
                                                                if let code =  responseData["code"] as? NSNumber{
                                                                    if  Int(code) == 10000{
                                                                        let data:[String:String] = responseData["data"]! as! [String : String]
                                                                        SCUserInfo.sharedUserInfo().sessionId = data["sessionid"]!;
                                                                        let tempParas = paras as! [String:String]
                                                                        SCUserInfo.sharedUserInfo().mobile = tempParas["mobile"]
                                                                        finished(error: nil)
                                                                    }else{
                                                                        let mesg = responseData["mesg"];
                                                                        let mesgStr =  mesg as! String
                                                                        let error = NSError.init(domain:"544.sina.cn", code: 10001, userInfo: [NSLocalizedDescriptionKey:mesgStr])
                                                                        finished(error: error)
                                                                    }
                                                                }
                                                            }else{
                                                                 let error = NSError.init(domain:"544.sina.cn", code: 10005, userInfo: [NSLocalizedDescriptionKey:"类型转换失败"])
                                                                finished(error:error)
                                                            }
            },
                                                        failBlock: {(error)in
                                                            finished(error: error)
        })
    }
    
}
