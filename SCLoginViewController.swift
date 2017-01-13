//
//  SCLoginViewController.swift
//  SinaAutoDriver
//
//  Created by dengyanzhou on 16/4/28.
//  Copyright © 2016年 SInaAuto. All rights reserved.
//

import UIKit
@objc(SCLoginViewController)
class SCLoginViewController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var phoneNumFeild: UITextField!
    @IBOutlet weak var authCodeField: UITextField!
    @IBOutlet weak var sendAuthCodeBtn: UIButton!
    @IBOutlet weak var picAuthCodeField: UITextField!
    @IBOutlet weak var authCodeView: SCAuthcodeView!
    @IBOutlet weak var loginBtn: UIButton!
    var loginSucess:((Bool) -> Void)?
    var  timeDown:UInt8 = 60
    override func viewDidLoad() {
       super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let whiteColor = UIColor.whiteColor()

            phoneNumFeild.setValue(whiteColor, forKeyPath:"placeholderLabel.textColor")
            phoneNumFeild.setValue(UIFont.systemFontOfSize(16), forKeyPath:"placeholderLabel.font")
            phoneNumFeild.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
            
            authCodeField.setValue(whiteColor, forKeyPath:"placeholderLabel.textColor")
            authCodeField.setValue(UIFont.systemFontOfSize(16), forKeyPath: "placeholderLabel.font")
            authCodeField.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
            
            picAuthCodeField.setValue(whiteColor, forKeyPath:"placeholderLabel.textColor")
            picAuthCodeField.setValue(UIFont.systemFontOfSize(16), forKeyPath:"placeholderLabel.font")
            picAuthCodeField.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
            
            self.sendAuthCodeBtn.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
            self.sendAuthCodeBtn.layer.cornerRadius = 5;
            self.sendAuthCodeBtn.layer.masksToBounds = true;
            self.loginBtn.layer.cornerRadius = 5;
            self.loginBtn.layer.masksToBounds = true;
    }
    //MARK: - 发送验证码
    @IBAction func sendAuthCode(sender: AnyObject)
    {
        if  self.isValidPhoneNum(self.phoneNumFeild.text)
            && self.isValidPicAuthCode(self.picAuthCodeField.text)
        {
            SCLoginViewModel.sendAuthCode(self.phoneNumFeild.text!, complete: {(error) in
                if error != nil {
                    if  error?.code >= 10000{
                        UIWindow.autoShowMsg(error?.userInfo[NSLocalizedDescriptionKey] as! String, duration: 1, completion: nil)
                    }
                }
            })
            //点击发送按钮 --- 倒计时
            self.sendAuthCodeBtn.setTitle("\(timeDown)s", forState: .Normal)
            //倒计时期间 不让点击
            self.sendAuthCodeBtn.enabled = false
            self.performSelector(#selector(SCLoginViewController.startTimeDown), withObject: nil, afterDelay: 1)
        }
    }
    //MARK: - 登录
    @IBAction func gotoLogin(sender: AnyObject)
    {
        if  self.isValidPhoneNum(self.phoneNumFeild.text)
            && self.isValidPicAuthCode(self.picAuthCodeField.text)
            && self.isValidAuthCode(self.authCodeField.text)

        {
                SCLoginViewModel.userLogin(withParas: ["mobile":self.phoneNumFeild.text!,"code":self.authCodeField.text!],
                                           complete: { (error) in
                                            if error != nil {
                                                if error?.code >= 10000{
                                                    UIWindow.autoShowMsg(error?.userInfo[NSLocalizedDescriptionKey] as! String, duration: 1, completion: nil)
                                                }
                                            }else{                                                NSNotificationCenter.defaultCenter().postNotificationName("SCUserLoginSuccessNotification", object: nil)
                                            }
                })
        }
    }
    //MARK: - 倒计时
    private func startTimeDown() -> Void
    {
        timeDown -= 1
        if timeDown == 0 //结束倒计时
        {
            self.sendAuthCodeBtn.enabled = true;
            self.sendAuthCodeBtn.setTitle("发送验证码", forState: .Normal)
            //恢复初始值
            self.timeDown = 60;
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:#selector(SCLoginViewController.startTimeDown), object: nil)
        }
        else
        {
            self.sendAuthCodeBtn.setTitle("\(timeDown)s", forState: .Normal)
            self.performSelector(#selector(SCLoginViewController.startTimeDown), withObject: nil, afterDelay: 1)
        }
    }
    //MARK: - 判断是否是有效的手机号
    private func isValidPhoneNum(phoneNum:String?) -> Bool
    {
        if phoneNum?.characters.count == 0
        {
            UIWindow.autoShowMsg("手机号为空", duration: 1, completion: nil)
            return false
        }
        if phoneNum?.characters.count < 11 && phoneNum?.characters.count > 0
        {
            UIWindow.autoShowMsg("手机号不足11位", duration: 1, completion: nil)
            return false
        }
        if phoneNum?.characters.count > 11         {
            UIWindow.autoShowMsg("手机号超出11位", duration: 1, completion: nil)
            return false
        }
        if phoneNum!.isValidPhoneNum()
        {
            return true
        }else
        {
            UIWindow.autoShowMsg("手机号格式不正确", duration: 1, completion: nil)
            return false
        }
    }
    
    //MARK: - 判断是否有效的图片验证码
    private func isValidPicAuthCode(authCode:String?) -> Bool
    {
        if authCode?.characters.count == 0
        {
            UIWindow.autoShowMsg("请输入图片验证码", duration: 1, completion: nil)
            return false
        }
        if self.authCodeView.equalAnotherAuthCode(authCode)
        {
            return true
        }else
        {
            UIWindow.autoShowMsg("图片验证码不正确", duration: 1, completion: nil)
            self.authCodeView.refresh()
            return false
        }
    }
    //MARK: - 判断是否是一个有效的手机验证码
    private func isValidAuthCode(authCode:String?) -> Bool {
        if authCode?.characters.count == 0
        {
            UIWindow.autoShowMsg("请输入手机验证码", duration: 1, completion: nil)
            return false
        }
        if authCode?.characters.count != 6  {
            UIWindow.autoShowMsg("手机验证码为6位", duration: 1, completion: nil)
            return false
        }
        return true
    }
    
    //MARK: - 返回上一页
    @IBAction func gotoBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SCLoginViewController{
    //MARK: - textFeildDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if "" == string{
            return true
        }
        if textField == self.phoneNumFeild {
            if textField.text?.characters.count > 10 {
                return false
            }else{
                return true
            }
        }
        if textField == self.picAuthCodeField {
            if textField.text?.characters.count > 3 {
                return false
            }else{
                return true
            }
        }
        if textField == self.authCodeField {
            if textField.text?.characters.count > 5 {
                return false
            }else{
                return true;
            }
        }
        return true
    }

}
