//
//  HDCommonToolsSwift+UI.swift
//  HDCommonToolsSwift
//
//  Created by Damon on 2020/7/2.
//  Copyright © 2020 Damon. All rights reserved.
//

import UIKit

public enum HDGradientDirection {
    case leftToRight            //AC - BD
    case topToBottom            //AB - CD
    case leftTopToRightBottom   //A - D
    case leftBottomToRightTop   //C - B
}
//      A         B
//       _________
//      |         |
//      |         |
//       ---------
//      C         D

public extension HDCommonToolsSwift {
    ///通过十六进制字符串获取颜色
    func getColor(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        
        var hex = ""
        if hexString.hasPrefix("#") {
            hex = String(hexString.suffix(hexString.count - 1))
        } else if (hexString.hasPrefix("0x") || hexString.hasPrefix("0X")) {
            hex = String(hexString.suffix(hexString.count - 2))
        }
        guard hex.count == 6 else {
            //不足6位不符合
            return UIColor.clear
        }
        
        var red: UInt32 = 0
        var green: UInt32 = 0
        var blue: UInt32 = 0
        
        var startIndex = hex.startIndex
        var endIndex = hex.index(hex.startIndex, offsetBy: 2)
        
        Scanner(string: String(hex[startIndex..<endIndex])).scanHexInt32(&red)
        
        startIndex = hex.index(hex.startIndex, offsetBy: 2)
        endIndex = hex.index(hex.startIndex, offsetBy: 4)
        Scanner(string: String(hex[startIndex..<endIndex])).scanHexInt32(&green)
        
        startIndex = hex.index(hex.startIndex, offsetBy: 4)
        endIndex = hex.index(hex.startIndex, offsetBy: 6)
        Scanner(string: String(hex[startIndex..<endIndex])).scanHexInt32(&blue)
        
        return UIColor(displayP3Red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    ///获取当前的normalwindow
    func getCurrentNormalWindow() -> UIWindow? {
        var window:UIWindow? = UIApplication.shared.keyWindow
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                if windowScene.activationState == .foregroundActive {
                    window = windowScene.windows.first
                    for tmpWin in windowScene.windows {
                        if tmpWin.windowLevel == .normal {
                            window = tmpWin
                            break
                        }
                    }
                    break
                }
            }
        }
        if window == nil || window?.windowLevel != UIWindow.Level.normal {
            for tmpWin in UIApplication.shared.windows {
                if tmpWin.windowLevel == UIWindow.Level.normal {
                    window = tmpWin
                    break
                }
            }
        }
        return window
    }
    
    ///获取当前显示的vc
    func getCurrentVC() -> UIViewController? {
        let currentWindow = self.getCurrentNormalWindow()
        guard let window = currentWindow else { return nil }
        var vc: UIViewController?
        let frontView = window.subviews.first
        if let nextResponder = frontView?.next {
            if nextResponder is UIViewController {
                vc = nextResponder as? UIViewController
            } else {
                vc = window.rootViewController
            }
        } else {
            vc = window.rootViewController
        }
        
        if let currentVC = vc {
            if currentVC is UITabBarController {
                let tabBarController = currentVC as! UITabBarController
                vc = tabBarController.selectedViewController
            }
        }
        if let currentVC = vc {
            if currentVC is UINavigationController {
                let navigationController = currentVC as! UINavigationController
                vc = navigationController.visibleViewController
            }
        }
        return vc
    }
    
    ///通过颜色获取纯色图片
    func getImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        var image: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        if let context = context {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }
    
    ///线性渐变
    func getLinearGradientImage(colors: [UIColor], directionType: HDGradientDirection, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        if (colors.count == 0) {
            return UIImage()
        } else if (colors.count == 1) {
            return self.getImage(color: colors.first!)
        }
        let gradientLayer = CAGradientLayer()
        var cgColors = [CGColor]()
        var locations = [NSNumber]()
        for i in 0..<colors.count {
            let color = colors[i]
            cgColors.append(color.cgColor)
            let location = Float(i)/Float(colors.count - 1)
            locations.append(NSNumber(value: location))
        }
        
        gradientLayer.colors = cgColors
        gradientLayer.locations = locations
        
        if (directionType == .leftToRight) {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        } else if (directionType == .topToBottom){
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        } else if (directionType == .leftTopToRightBottom){
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        } else if (directionType == .leftBottomToRightTop){
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        }
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0)
        var gradientImage: UIImage?
        
        let context: CGContext? = UIGraphicsGetCurrentContext()
        if let context = context {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return gradientImage ?? UIImage()
    }
    
    ///角度渐变
    func getRadialGradientImage(colors: [UIColor], raduis: CGFloat, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        if (colors.count == 0) {
            return UIImage()
        } else if (colors.count == 1) {
            return self.getImage(color: colors.first!)
        }
        
        UIGraphicsBeginImageContext(size);
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: size.width/2.0, y: size.height / 2.0), radius: raduis, startAngle: 0, endAngle: CGFloat(Double.pi) * 2, clockwise: false)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var cgColors = [CGColor]()
        var locations = [CGFloat]()
        for i in 0..<colors.count {
            let color = colors[i]
            cgColors.append(color.cgColor)
            let location = Float(i)/Float(colors.count - 1)
            locations.append(CGFloat(location))
        }
        
        let colorGradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations)
        guard let gradient = colorGradient else { return UIImage() }
        
        let pathRect = path.boundingBox;
        let center = CGPoint(x: pathRect.midX, y: pathRect.midY)
        
        let currentContext: CGContext? = UIGraphicsGetCurrentContext()
        guard let context = currentContext else {
            return UIImage()
        }
        context.saveGState();
        context.addPath(path);
        context.clip()
        context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: raduis, options: .drawsBeforeStartLocation);
        context.restoreGState();
        
        //        CGGradientRelease(gradient);
        //        CGColorSpaceRelease(colorSpace);
        //
        //        CGPathRelease(path);
        
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img ?? UIImage()
    }
}

///16进制颜色转为UIColor 0xffffff
public func UIColor(hexValue: Int, darkHexValue: Int = 0x333333, alpha: Float = 1.0, darkAlpha: Float = 1.0) -> UIColor {
    if #available(iOS 10.0, *) {
        if #available(iOS 13.0, *) {
            let dyColor = UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    return UIColor(displayP3Red: CGFloat(((Float)((hexValue & 0xFF0000) >> 16))/255.0), green: CGFloat(((Float)((hexValue & 0xFF00) >> 8))/255.0), blue: CGFloat(((Float)(hexValue & 0xFF))/255.0), alpha: CGFloat(alpha))
                } else {
                    return UIColor(displayP3Red: CGFloat(((Float)((darkHexValue & 0xFF0000) >> 16))/255.0), green: CGFloat(((Float)((darkHexValue & 0xFF00) >> 8))/255.0), blue: CGFloat(((Float)(darkHexValue & 0xFF))/255.0), alpha: CGFloat(darkAlpha))
                }
            }
            return dyColor
        } else {
            return UIColor(displayP3Red: CGFloat(((Float)((hexValue & 0xFF0000) >> 16))/255.0), green: CGFloat(((Float)((hexValue & 0xFF00) >> 8))/255.0), blue: CGFloat(((Float)(hexValue & 0xFF))/255.0), alpha: CGFloat(alpha))
        }
    } else {
        return UIColor(red: CGFloat(((Float)((hexValue & 0xFF0000) >> 16))/255.0), green: CGFloat(((Float)((hexValue & 0xFF00) >> 8))/255.0), blue: CGFloat(((Float)(hexValue & 0xFF))/255.0), alpha: CGFloat(alpha))
    };
}

///16进制字符串转为UIColor #ffffff
public func UIColor(hexString: String, darkHexString: String = "#333333", alpha: CGFloat = 1.0, darkAlpha: CGFloat = 1.0) -> UIColor {
    if #available(iOS 13.0, *) {
        let dyColor = UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .light {
                return HDCommonToolsSwift.shared.getColor(hexString: hexString, alpha: alpha)
            } else {
                return HDCommonToolsSwift.shared.getColor(hexString: darkHexString, alpha: darkAlpha)
            }
        }
        return dyColor
    } else {
        return HDCommonToolsSwift.shared.getColor(hexString: hexString, alpha: alpha)
    }
}

///高度坐标配置
public var UIScreenWidth: CGFloat {
    return UIScreen.main.bounds.size.width
}
public var UIScreenHeight: CGFloat {
    return UIScreen.main.bounds.size.height
}

///状态栏高度
public var HD_StatusBar_Height: CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}

///导航栏高度
public func HD_Default_NavigationBar_Height(vc: UIViewController? = nil) -> CGFloat {
    if let navigationController = vc?.navigationController {
        return navigationController.navigationBar.frame.size.height
    } else {
        return UINavigationController(nibName: nil, bundle: nil).navigationBar.frame.size.height
    }
}

///tabbar高度
public func HD_Default_Tabbar_Height(vc: UIViewController? = nil) -> CGFloat {
    if let tabbarViewController = vc?.tabBarController {
        return tabbarViewController.tabBar.frame.size.height
    } else {
        return UITabBarController(nibName: nil, bundle: nil).tabBar.frame.size.height
    }
}

///状态栏和导航栏总高度
public func HD_Default_Nav_And_Status_Height(vc: UIViewController? = nil) -> CGFloat {
    return HD_Default_NavigationBar_Height(vc: vc) + HD_StatusBar_Height
}
