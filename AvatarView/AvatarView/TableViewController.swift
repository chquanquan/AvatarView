//
//  TableViewController.swift
//  AvatarView
//
//  Created by quan on 2017/4/30.
//  Copyright © 2017年 chq.Co.Ltd. All rights reserved.
//

import UIKit

let imageUrl = "http://img4.duitang.com/uploads/item/201504/15/20150415H0046_Ban8u.jpeg"
let avatarWidth: CGFloat = 50.0
let normalAvatarHeight: CGFloat = 50.0
let markAvatarHeight: CGFloat = 65.0
let borderWidth: CGFloat = 2.0

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AvatarView"
        
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: nil, options: nil)?.first as! HeaderView
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        let avatarView: AvatarView!
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "占位图"
            cell?.detailTextLabel?.text = "点击设定头像,回完成后,通过回调上传到服务器"
            avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: avatarWidth, height: normalAvatarHeight), imageType: .placeholderImage, cornerRadius: 8, action: .changeAvatar)
        case 1:
            cell?.textLabel?.text = "底部图片标识"
            cell?.detailTextLabel?.text = "点击跳转个人中心"
            avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: avatarWidth, height: normalAvatarHeight - 5), imageType: .newImage(#imageLiteral(resourceName: "myImage")), cornerRadius: avatarWidth * 0.5, action: .customAction, avatarPath: defaultAvatarDir + "/myAvatarImage")
            //上面更改头像保存位置是有效的,只是被其他avatarView给覆盖了.
            avatarView.setBorder(width: borderWidth, color: UIColor.orange)
            avatarView.setMarkImage(frame: CGRect(x: 0, y: 45, width: avatarWidth, height: 10), image: #imageLiteral(resourceName: "normaluser"))
        case 2:
            cell?.textLabel?.text = "顶部图片标识"
            cell?.detailTextLabel?.text = "点击跳转个人中心,"
            avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: avatarWidth, height: markAvatarHeight))
            avatarView.action = .customAction
            avatarView.setCurrentImage()
            avatarView.setBorder(width: borderWidth, color: UIColor(red: 255/255.0, green: 0/255.0, blue: 255/255.0, alpha: 1.0))
            avatarView.setCornerRadius(cornerRadius: avatarWidth * 0.5)
            avatarView.setImageFrame(CGRect(x: 0, y: 10, width: avatarWidth, height: normalAvatarHeight))
            avatarView.setMarkImage(frame: CGRect(x: 0, y: 0, width: avatarWidth, height: 20), imageName: "crouwn")
        case 3:
            cell?.textLabel?.text = "自定义标识"
            cell?.detailTextLabel?.text = "加载网络头像,想添加啥view都可以."
            avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: avatarWidth, height: markAvatarHeight))
            avatarView.action = .customAction
            avatarView.refreshImageWithPlaceholderImage(urlString: imageUrl)
            let label = UILabel()
            label.text = "普通用户"
            label.font = UIFont.systemFont(ofSize: 11)
            label.textAlignment = .center
            label.backgroundColor = UIColor.green
            avatarView.setMarkView(frame: CGRect(x: 0, y: 50, width: normalAvatarHeight, height: 15), customView: label)
        default:
            fatalError("不到会这里的")
        }
        cell?.accessoryView = avatarView
        avatarView.delegate = self
        cell?.selectionStyle = .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
 

}

extension TableViewController: AvatarViewDelegate {
    
    func setImageCompletion(avatarView: AvatarView, imageData: Data) {
        //此处上传图片到自己服务器,如果需要.   PS:网络刷新和通过setImage方法展示的图片,不会回调此方法.
        print("设置自定义图片(相册或拍照)完成.")
    }
    
    
    func loadImageFailure(avatarView: AvatarView, url: String) {
        print("加载网络图片失败") //如果需要可以把占位图赋值回去.
    }
    
    
    func customAction(avatarView: AvatarView) {
        print("点击头像自定义的回调")
        navigationController?.pushViewController(UserViewController(), animated: true)
        
    }
}

extension TableViewController: HeaderViewDelegate {
    func jumpUserViewController(headerView: HeaderView) {
        navigationController?.pushViewController(UserViewController(), animated: true)
    }
}
