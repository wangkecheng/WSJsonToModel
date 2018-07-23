#
#  Be sure to run `pod spec lint WSJsonToModel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#
Pod::Spec.new do |s|

s.name = "WSJsonToModel"

s.version = "1.0.0"

s.summary = "upload"

s.platform     = :ios, "9.0"

s.swift_version = "4.0"

s.description  = <<-DESC
                     json 字典转 模型
                    * Markdown 格式
                   DESC

s.homepage = "https://github.com/wangkecheng/WSJsonToModel"

s.license      = "MIT"

s.author = { "wangkecheng" => "670894753@qq.com" }

s.source = { :git => "https://github.com/wangkecheng/WSJsonToModel.git"}

s.source_files = "NSObjectJsonRuntime.swift'

s.requires_arc = true

s.module_name = 'WSJsonToModel'  

end 
