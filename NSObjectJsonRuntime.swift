//
//  NSObject+Runtime.swift
//  DatabaseDemo
//
//  Created by 王帅 on 2018/7/20. 670894753@qq.com
//  Copyright © 2018 王帅. All rights reserved. 70894753@qq.com
//

import UIKit
import Foundation

var SetResultKeyToObjKeyArr = "setResultKeyToObjKeyArr"
var SetObjClassInArrayArr = "setObjClassInArrayArr"
extension NSObject {
    
    func setResultKeyToObjKeyArr(keyValueArr:[[String:String]]){ //如果 返回数据 key 是 id 及ida id->ID ida -> IDNew   就把需要转换的字典放入 数组中
        objc_setAssociatedObject(self, &SetResultKeyToObjKeyArr, keyValueArr, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func getResultKeyToObjKeyArr() -> [[String:String]]? {
        let objc = objc_getAssociatedObject(self, &SetResultKeyToObjKeyArr)
        if objc == nil{
            return Optional.none
        }
        return (objc as! [[String:String]])
    }
    
    func setObjClassInArrayArr(keyValueArr:[[String:String]]){//数组模型的映射 ，比如 arrModel 里边装的是User模型 及 arrModel1装User1 那么映射是 [["arrModel":"User"],["arrModel1":"User1"]]
        objc_setAssociatedObject(self, &SetObjClassInArrayArr, keyValueArr, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func getObjClassInArrayArr() -> [[String:String]]? {
        let objc = objc_getAssociatedObject(self, &SetObjClassInArrayArr)
        if objc  == nil{
            return Optional.none
        }
        return  (objc as! [[String:String]])
    }
    
    //字典转 -> 模型  传字典
    class func objcByKeyValues(keyValue:NSDictionary?) -> AnyObject?{
        return self.objcByKeyValues(keyValue: keyValue, resultKeyToObjKeyArr: Optional.none, objClassInArrayArr: Optional.none)
    }
    //字典转 -> 模型  传字典 映射属性
    class func objcByKeyValues(keyValue:NSDictionary?,resultKeyToObjKeyArr:[[String:String]]?) -> AnyObject?{
        return self.objcByKeyValues(keyValue: keyValue, resultKeyToObjKeyArr: resultKeyToObjKeyArr, objClassInArrayArr: Optional.none)
    }
    //字典转 -> 模型 传字典 映射数组
    class func objcByKeyValues(keyValue:NSDictionary?,objClassInArrayArr:[[String:String]]?) -> AnyObject?{
        return self.objcByKeyValues(keyValue: keyValue, resultKeyToObjKeyArr: Optional.none, objClassInArrayArr: objClassInArrayArr)
    }
    //字典转 -> 模型 传字典 映射属性 映射数组
    class func objcByKeyValues(keyValue:NSDictionary?,resultKeyToObjKeyArr:[[String:String]]?,objClassInArrayArr:[[String:String]]?) -> AnyObject?{
        
        if keyValue == Optional.none{//传值为空，不允许转换
            return Optional.none
        }
        if keyValue?.classForCoder != NSDictionary.self && keyValue?.classForCoder != [String:String].self{//传入的不是字典不允许转换
            return Optional.none
        }
        let model = self.init()
        if resultKeyToObjKeyArr != nil {
            model.setResultKeyToObjKeyArr(keyValueArr:resultKeyToObjKeyArr!)
        }
        if objClassInArrayArr != nil {
            model.setObjClassInArrayArr(keyValueArr: objClassInArrayArr!)
        }
        //获取所有的属性
        let properties = self.allProperties(resultKeyToObjKeyArr:resultKeyToObjKeyArr)
        model.setValuesForProperties(properties: properties, dict: keyValue!)
        return model
    }
    //    //把一个字典数组转成一个模型数组
    //    class func objectArrayWithKeyValuesArray(array:NSArray) -> [AnyObject]{
    //        var temp = Array<AnyObject>()
    //        let properties = self.allProperties(resultKeyToObjKey:)
    //        for i in 0..<array.count{
    //            let keyValues = array[i] as? NSDictionary
    //            if (keyValues != nil){
    //                let model = self.init()
    //                //为每个model赋值
    //                model.setValuesForProperties(properties: properties, keyValues: keyValues!)
    //                temp.append(model)
    //            }
    //        }
    //        return temp
    //    }
    //把一个字典里的值赋给一个对象的值
    func setValuesForProperties(properties:[RutimeProperty]?,dict:NSDictionary){
        //判断属性数组是否存在
        if let _ = properties{
            for property in properties!{
                //判断该属性是否属于Foundtation框架
                if property.isFromFoundtion! {
                    if let valueArrOrDict = dict[property.propertyNameKey]{
                        if property.isArray!  && valueArrOrDict is NSArray{//判断是否是数组
                            self.analysisArr(valueArr: valueArrOrDict as AnyObject,property:property)//调用解析数组的方法
                        }else if valueArrOrDict is NSDictionary{ //是字典
                            let obj = getClassWitnClassName(name: property.code! as String)//为model类赋值
                            let objModel = (obj as! NSObject.Type).objcByKeyValues(keyValue: (valueArrOrDict as! NSDictionary), resultKeyToObjKeyArr: self.getResultKeyToObjKeyArr(), objClassInArrayArr: self.getObjClassInArrayArr())
                            self.setValue(objModel, forKey: property.propertyName as String)
                        }else{//原封不动返回去
                            self.setValue(valueArrOrDict, forKey: property.propertyName as String)
                        }
                    }
                }else{//构建的属性不是 Foundation 类型时
                    if let value = dict[property.propertyNameKey]{
                        if value is NSDictionary{
                            let subClass = NSDictionary.objcByKeyValues(keyValue: (value as! NSDictionary), resultKeyToObjKeyArr: self.getResultKeyToObjKeyArr(), objClassInArrayArr: self.getObjClassInArrayArr())
                            //为model类赋值
                            self.setValue(subClass, forKey: property.propertyName as String)
                        }
                    }
                }
            }
        }
    }
    func analysisArr(valueArr:AnyObject,property:RutimeProperty) {
        //把字典数组转换成模型数组
        let arr:NSMutableArray = NSMutableArray()
        var className:String? = nil
        for itemArr in (valueArr as! NSArray){
            
            if let getObjClassInArrayArr = self.getObjClassInArrayArr(){ //可能是对象有多个数组
                for dict in getObjClassInArrayArr{
                    if (dict.keys.first! as NSString) != property.propertyName{
                        continue
                    }
                    className = (dict[property.propertyName! as String] as! String)
                }
            }else{//解析数组：字典->模型，当未传入的映射 字典时 ，返回未解析的数组
                arr.addObjects(from: (itemArr as! NSArray) as! [Any])
                break //直接就终止
            }
            if className == nil{//传入了映射字典，比如有两个需要映射的数组(数组内装模型)，但只传了一个映射字典
                arr.add(itemArr)
                continue
            }
            let obj = (getClassWitnClassName(name: className as! String) as! NSObject.Type)
            let objModel = obj.objcByKeyValues(keyValue: (itemArr as? NSDictionary), resultKeyToObjKeyArr: self.getResultKeyToObjKeyArr(), objClassInArrayArr: self.getObjClassInArrayArr())
            if objModel != nil{
                arr.add(objModel as Any)
            }else{
                arr.add(itemArr)//尽可能的解析数据
            }
        }
        if arr.count != 0{
            self.setValue(arr, forKey: property.propertyName as String)//为数组赋值
        }
    }
    
    class func allProperties(resultKeyToObjKeyArr:[[String:String]]?) -> [RutimeProperty]?{
        let className = NSString.init(cString: class_getName(self), encoding: String.Encoding.utf8.rawValue)
        if className?.length == 0 || className!.isEqual(to: "NSObject"){//不用为NSObject的属性赋值
            return nil
        }
        var outCount:UInt32 = 0
        //所有属性RutimeProperty里面放着存放这个属性
        var propertiesArray = [RutimeProperty]()
        let properties = class_copyPropertyList(object_getClass(self.init()),&outCount)
        
        //获取父类的所有属性
        let superM = (self.superclass() as! NSObject.Type).allProperties(resultKeyToObjKeyArr:resultKeyToObjKeyArr)
        if let _ = superM{
            propertiesArray += superM!
        }
        for  i in 0..<Int(outCount) {
            let property = RutimeProperty(property: properties![i],resultKeyToObjKeyArr: resultKeyToObjKeyArr)
            propertiesArray.append(property)
        }
        return propertiesArray
    }
}

class RutimeProperty:NSObject{
    var propertyName:NSString!  //属性名字 可能是id
    var propertyNameKey:NSString!  //属性名字 转换后的名字 id -> ID
    
    var property:objc_property_t? //属性
    
    var code:NSString?  //类名字
    
    var typeClass:AnyObject?//类的类型
    
    var isFromFoundtion:Bool? = true//是否属于Foundtation框架
    
    var isArray:Bool? = false//是否是数组
    
    var arrayClass:AnyObject? //数组里面存放的类型
    
    var resultKeyToObjKeyArr:[[String:String]]?
    
    init(property:objc_property_t,resultKeyToObjKeyArr:[[String:String]]?){
        self.property = property
        self.resultKeyToObjKeyArr = resultKeyToObjKeyArr
        self.propertyName = NSString.init(utf8String: property_getName(property))
        self.propertyNameKey = NSString.init(string: self.propertyName)
        
        //自定义的类的Types格式为T@"_TtC15字典转模型4Card",N,&,Vcard
        //T+@+"+..+工程的名字+数字+类名+"+,+其他,而我们想要的只是类名，所以要修改这个字符串
        var code: NSString = NSString.init(cString: property_getAttributes(property)!, encoding: String.Encoding.utf8.rawValue)!
        //直接取出""中间的内容
        code = code.components(separatedBy: "\"")[1] as NSString
        let bundlePath = getBundleName()
        let range = code.range(of: bundlePath)
        if range.length > 0{
            //去掉工程名字之前的内容
            code = code.substring(from: range.length + range.location) as NSString
        }
        //在去掉剩下的数字
        var number:String = ""
        for char in (code as String).characters{
            if char <= "9" && char >= "0"{
                number += String(char)
            }else{
                break
            }
        }
        let numberRange = code.range(of: number)
        if numberRange.length > 0{
            //得到类名
            code = code.substring(from: numberRange.length + numberRange.location) as NSString
        }
        self.code = code
        if isFoundtion(className: self.code!){//判断是否属于Foundtation框架
            self.typeClass = NSClassFromString(self.code! as String)
            self.isFromFoundtion = true
            if (self.code?.hasPrefix("NSArray"))!{
                self.isArray = true
            }
        }else{//如果是自定义的类NSClassFromString这个方法传得字符串是工程的名字+类名
            self.typeClass = getClassWitnClassName(name: self.code! as String)
            self.isFromFoundtion = false
        }
        
        if resultKeyToObjKeyArr != nil {//判断是否有映射
            for dict:[String:String] in resultKeyToObjKeyArr!{
                let value:NSString = dict.keys.first! as NSString
                if value == self.propertyName{
                    self.propertyNameKey = dict[self.propertyName as String]! as NSString
                }
            }
        }
        super.init()
    }
}

func isFoundtion(className:NSString) -> Bool {
    if className.hasPrefix("NS"){
        return true
    }
    var obj:AnyObject? = nil
    if className.contains(".") {
        obj = NSClassFromString(className as String)?.superclass()
    }else{
        obj = getClassWitnClassName(name: className as String)?.superclass()
    }
    if obj == nil{
        return false
    }
    if isFoundtion(className: NSStringFromClass(obj as! AnyClass) as NSString){
        return true
    }
    return false
}
//获取工程的名字
func getBundleName() -> String{
    var bundlePath = Bundle.main.bundlePath
    bundlePath = bundlePath.components(separatedBy:"/").last!
    bundlePath = bundlePath.components(separatedBy:".").first!
    return bundlePath
}
//通过类名返回一个AnyClass
func getClassWitnClassName(name:String) ->AnyClass?{
    let type = getBundleName() + "." + name
    return NSClassFromString(type)
}

