//
//  UIFontExtension.swift
//  Proto
//
//  Created by Kenneth on 5/27/16.
//  Copyright © 2016 Ada. All rights reserved.
//

import UIKit

extension UIFont {
    class func systemFontOfSizeByScreenWidth(_ defaultWidth: CGFloat, fontSize: CGFloat) -> UIFont {
        let screenWidth = UIScreen.main.bounds.size.width
        let ratio = screenWidth / defaultWidth
        return UIFont.systemFont(ofSize: floor(fontSize * ratio))
    }

    class func boldSystemFontOfSizeByScreenWidth(_ defaultWidth: CGFloat, fontSize: CGFloat) -> UIFont {
        let screenWidth = UIScreen.main.bounds.size.width
        let ratio = screenWidth / defaultWidth
        return UIFont.boldSystemFont(ofSize: floor(fontSize * ratio))
    }

    class func systemFontOfSizeByScreenHeight(_ defaultHeight: CGFloat, fontSize: CGFloat) -> UIFont {
        let screenHeight = UIScreen.main.bounds.size.height
        let ratio = screenHeight / defaultHeight
        return UIFont.systemFont(ofSize: floor(fontSize * ratio))
    }

    class func boldSystemFontOfSizeByScreenHeight(_ defaultHeight: CGFloat, fontSize: CGFloat) -> UIFont {
        let screenHeight = UIScreen.main.bounds.size.height
        let ratio = screenHeight / defaultHeight
        return UIFont.boldSystemFont(ofSize: floor(fontSize * ratio))
    }
}
