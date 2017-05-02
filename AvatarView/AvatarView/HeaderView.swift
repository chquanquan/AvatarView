//
//  HeaderView.swift
//  AvatarView
//
//  Created by quan on 2017/4/30.
//  Copyright © 2017年 chq.Co.Ltd. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
    func jumpUserViewController(headerView: HeaderView)
}

class HeaderView: UIView {
    
    @IBOutlet weak var imageAvatarView: AvatarView!
    @IBOutlet weak var simpleAvatarView: AvatarView!
    @IBOutlet weak var customAvatarView: AvatarView!
    @IBOutlet weak var topImageAvatarView: AvatarView!
    
    weak var delegate: HeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        simpleAvatarView.resetImage()
        simpleAvatarView.setCornerRadius(cornerRadius: 8)
        simpleAvatarView.action = .changeAvatar
        simpleAvatarView.delegate = self
        
        imageAvatarView.setImage(image: #imageLiteral(resourceName: "myImage"))
        imageAvatarView.action = .customAction
        imageAvatarView.setImageFrame(CGRect(x: 5, y: 0, width: 40, height: 40))
        imageAvatarView.setCornerRadius(cornerRadius: (avatarWidth - 10) * 0.5)
        imageAvatarView.setBorder(width: 2, color: UIColor.green)
        imageAvatarView.setMarkImage(frame: CGRect(x: 0, y: 35, width: 50, height: 10), image: #imageLiteral(resourceName: "normaluser"))
        imageAvatarView.delegate = self
        
        
        topImageAvatarView.setImage(image: #imageLiteral(resourceName: "myImage"))
        topImageAvatarView.action = .customAction
        topImageAvatarView.setCornerRadius(cornerRadius: avatarWidth * 0.5)
        topImageAvatarView.setImageFrame(CGRect(x: 0, y: 10, width: 50, height: 50))
        topImageAvatarView.setMarkImage(frame: CGRect(x: 0, y: 0, width: 50, height: 20), imageName: "crouwn")
        topImageAvatarView.delegate = self
        customAvatarView.refreshImageWithCurrentImage(urlString: imageUrl)
        customAvatarView.action = .customAction
        let label = UILabel()
        label.text = "普通用户"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        label.backgroundColor = UIColor.green
        customAvatarView.setMarkView(frame: CGRect(x: 0, y: 50, width: 50, height: 15), customView: label)
        customAvatarView.delegate = self
  
    }
    
    @IBAction func removeFile(_ sender: UIButton) {
        //其他AvatarView会在创建时加载不到头像文件的时候加载占位图,但是如果已经创建的AvatarView就要在再次展示的时候,自己判断了.
        AvatarView.resetImage {
            print("类方法删除头像文件,但没有重置头像为占位图")
        }
    }
    
    
    @IBAction func resetAvatar(_ sender: UIButton) {
        //一般当用户退出登录后要调用这个方法.
        customAvatarView.resetImage {
            print("删除头像文件并重置头像为占位图")
        }
        
        topImageAvatarView.resetImageAndMark { 
            print("删除头像文件并重置头像为占位图,把标识也删除了.")
        }
    }
    

}

extension HeaderView: AvatarViewDelegate {
    func loadImageFailure(avatarView: AvatarView, url: String) {
        
    }

    func setImageCompletion(avatarView: AvatarView, imageData: Data) {
//        simpleAvatarView.action = .customAction  //更改点击头像的逻辑
    }

    func customAction(avatarView: AvatarView) {
        delegate?.jumpUserViewController(headerView: self)
    }

    
}
