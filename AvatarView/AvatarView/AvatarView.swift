//
//  AvatarView.swift
//  AvatarView
//
//  Created by quan on 2017/4/29.
//  Copyright © 2017年 chq.Co.Ltd. All rights reserved.
//

import UIKit

/**********关于占位头像的选择, 我觉得最好不用使用者每次创建控件的时候指定(而且需求也不一样),而应该由bundle指定,重新给类属性placeholderImageString赋值即可**********/

//本地图片保存的默认文件夹
let defaultAvatarDir: String = {
    let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
    //    print(docDir)
    let avatarDir = docDir! + "/avatar"
    try? FileManager.default.createDirectory(atPath: avatarDir, withIntermediateDirectories: true, attributes: nil)
    return avatarDir
}()

//本地图片保存的默认地址
let defaultAvatarPath: String = {
    //    var dirPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    return defaultAvatarDir + "/avatarImage"
}()

let avatarImageViewTag = 78886


protocol AvatarViewDelegate: class {
    func customAction(avatarView: AvatarView)  //触发自定义行为
    func setImageCompletion(avatarView: AvatarView, imageData: Data) //设定头像完成
    func loadImageFailure(avatarView: AvatarView, url: String)  //加载网络头像失败
}

//点击头像的动作
enum AvatarAction {
    case none //没有动作
    case changeAvatar //设置头像
    case customAction  //自定义动作,通过实现代理来执行.
}

//初始化时候加载的图片类型
enum AvatarImageType {
    case none //空,控件透明
    case placeholderImage  //占位图
    case currentImage  //最近使用的图片,如果本地有.如果没有就用占位图,只要指定过非占位图的图片,就会创建一个最近的图片.
    case newImage(UIImage) //新图片.
    case urlImage(String)  //加载URL图片
}

class AvatarView: UIView {
    
    static var showAvatarLog = true //是否打印日志,发布版时,不会编译Log
    static var placeholderImageString = "pld2"  //为占位图片重新赋值为的图片名称
    static var avatarPath: String = defaultAvatarPath //图片保存路径
    
    weak var delegate: AvatarViewDelegate?
    private let fileManager = FileManager.default
    private let currentController = UIApplication.shared.activityViewController()
    private let placeholderImage = UIImage(named: AvatarView.placeholderImageString) //占位图
    var action: AvatarAction
    var cornerRadius: CGFloat = 0
    var imageFrame: CGRect!
    
    //最简单的创建,默认用最近的图片(如果有,没有就用占位图).默认没有圆角,不触发动作
    convenience override init(frame: CGRect) {
        self.init(frame: frame, imageType: .currentImage, cornerRadius: 0, action: .none)
    }
    
    
    //从xib加载,默认选择最近的头像.如果没有就用占位图.可初始化后后,自行指定头像图片,或者加载网络图片.
    required init?(coder aDecoder: NSCoder) {
        action = .none
        super.init(coder: aDecoder)
        imageView.image = getCurrentImage() ?? placeholderImage
        initAvatarView()
        
    }
    
    
    /// 全能初始化方法
    ///
    /// - Parameters:
    ///   - frame: 大小与位置
    ///   - imageType: 加载图片的类型,默认用占位图
    ///   - cornerRadius: 头像的圆角,默认非圆角
    ///   - action: 点击头像的动作
    ///   - avatarPath: 头像保存的路径,不传就用默认值
    init(frame: CGRect, imageType: AvatarImageType = .placeholderImage, cornerRadius: CGFloat = 0, action: AvatarAction = .none, avatarPath: String = defaultAvatarPath) {
        AvatarView.avatarPath = avatarPath
        self.action = action
        super.init(frame: frame)
        self.cornerRadius = cornerRadius
        
        switch imageType {
        case .none:
            break
        case .placeholderImage:
            imageView.image = placeholderImage
        case .currentImage:
            imageView.image = getCurrentImage() ?? placeholderImage
        case .newImage(let image):
            imageView.image = image
            save(image: image)
        case .urlImage(let urlString):
            refreshImage(urlString: urlString)
        }
        
        initAvatarView()
    }
    
    
    private func initAvatarView() {
        imageFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        imagePicker.delegate = self
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(avatarViewClick(tapGR:)))
        self.addGestureRecognizer(tapGR)
    }
    
    //设置边框大小与颜色
    func setBorder(width: CGFloat = 2, color: UIColor = UIColor.white) {
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = color.cgColor
    }
    
    //设置头像圆角
    func setCornerRadius(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    //设置头像图片的位置
    func setImageFrame(_ imageFrame: CGRect) {
        self.imageFrame = imageFrame
    }
    
    //传图片名称,设置用户标识
    func setMarkImage(frame: CGRect, imageName: String) {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.frame = frame
        addSubview(imageView)
    }
    
    //传图片设置用户标识
    func setMarkImage(frame: CGRect, image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.frame = frame
        addSubview(imageView)
    }
    
    //设置自定义标识视图
    func setMarkView(frame: CGRect, customView: UIView) {
        customView.frame = frame
        addSubview(customView)
    }
    
    
    //点击头像方法
    func avatarViewClick(tapGR: UITapGestureRecognizer) {
        switch action {
        case .changeAvatar:
            changeAvatar()
        case .customAction:
            delegate?.customAction(avatarView: self)
        case .none:
            break
        }
    }
    
    //设置头像
    func setImage(image: UIImage?) {
        guard let image = image else {
            AvatarLog(message: "设置了一个空头像")
            return
        }
        imageView.image = image
        save(image: image)
    }
    
    //设置为最近头像,如果有
    func setCurrentImage() {
        imageView.image = getCurrentImage() ?? placeholderImage
    }
    
    //设置头像
    func setImage(imageName: String) {
        guard let image = UIImage(named: imageName) else {
            AvatarLog(message: "设置了一个空头像")
            return
        }
        imageView.image = image
        save(image: image)
    }
    
    //加载网络图片,未加载的时候,用占位图填充
    func refreshImageWithPlaceholderImage(urlString: String) {
        imageView.image = placeholderImage
        refreshImage(urlString: urlString)
    }
    
    //加载网络图片,未加载的时候,用最近的本地图片填充(如果载不到就用占位图)
    func refreshImageWithCurrentImage(urlString: String) {
        imageView.image = getCurrentImage() ?? placeholderImage
        refreshImage(urlString: urlString)
    }
    
    //根据url刷新头像,有时候网络慢或者更新用户信息可能需要刷新
   private func refreshImage(urlString: String) {
        AvatarLog(message: "加载网络图片地址:\n " + urlString)
        
        guard let url = URL(string: urlString), urlString.hasPrefix("http") else {
            AvatarLog(message: "不是一个网络地址")
            delegate?.loadImageFailure(avatarView: self, url: urlString)
            return
        }
        
        DispatchQueue.global().async {
            [weak self] in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self?.imageView.image = image;
                    self?.save(image: image!)
                }
            } else {
                DispatchQueue.main.async {
                    self?.AvatarLog(message: "加载图片失败")
                    self?.delegate?.loadImageFailure(avatarView: self!, url: urlString)
                }
            }
        }
    }
    
    
    
    //获取最近的头像
    func getCurrentImage() -> UIImage? {
        if hasCurrentImage() {
            return UIImage(contentsOfFile: AvatarView.avatarPath)
        }
        return nil
    }
    
    //删除最近(本地)头像,还原为占位头像
    func resetImage(completion: (() -> Swift.Void)? = nil) {
        if hasCurrentImage() {
            try? fileManager.removeItem(atPath: AvatarView.avatarPath)
        }
        imageView.image = placeholderImage
        if completion != nil {
            completion!()
        }
    }
    
    //删除最近(本地)头像,还原为占位头像,并删除mark
    func resetImageAndMark(completion: (() -> Swift.Void)? = nil) {
        for subView in self.subviews {
            if subView.tag != avatarImageViewTag {
                subView.removeFromSuperview()
            }
        }
        resetImage(completion: completion)
    }
    
    //类方法,可以不用取得头像控件的情况下删除头像文件(如果有)
    static func resetImage(completion: (() -> Swift.Void)? = nil) {
        try? FileManager.default.removeItem(atPath: AvatarView.avatarPath)
        if completion != nil {
            completion!()
        }
    }
    
    
    //判断是否有最近的图片.
    func hasCurrentImage() -> Bool {
        if fileManager.fileExists(atPath: AvatarView.avatarPath) {
            return true
        }
        return false
    }
    
    
    //改变头像
   private func changeAvatar() {
        
        //拍照动作
        let camera = UIAlertAction(title: "拍照", style: .default) {
            [weak self] (action) in
            self?.AvatarLog(message: "拍照")
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                guard self != nil else {
                    return
                }
                self!.imagePicker.sourceType = .camera
                self!.currentController.present(self!.imagePicker, animated: true, completion: nil)
            }
        }
        
        //相册选取动作
        let photo = UIAlertAction(title: "从相册选取", style: .default) {
            [weak self] (action) in
            self?.AvatarLog(message: "从相册选取")
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                guard self != nil else {
                    return
                }
                self!.imagePicker.sourceType = .photoLibrary
                self!.currentController.present(self!.imagePicker, animated: true, completion: nil)
            }
        }
        
        //取消
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        currentController.present(actionSheet, animated: true, completion: nil)
        
    }
    
    //保存图片到文件
    @discardableResult
    func save(image: UIImage) -> Data {
        var data: Data
        
        if UIImagePNGRepresentation(image) != nil { //PNG格式
            data = UIImagePNGRepresentation(image)! as Data
        } else { //JPEG格式
            data = UIImageJPEGRepresentation(image, 1)! as Data
        }
        
        let success = fileManager.createFile(atPath: AvatarView.avatarPath, contents: data, attributes: nil)
        if success {
            AvatarLog(message: "头像保存成功,地址是:\n" + AvatarView.avatarPath)
        } else {
            AvatarLog(message: "头像保存失败")
        }
        
        return data
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        imageView.frame = imageFrame
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
    }
    
    //展示调试信息
   fileprivate func AvatarLog<T>(message: T,
                   file: String = #file,
                   method: String = #function,
                   line: Int = #line)
    {
        #if DEBUG
            if AvatarView.showAvatarLog {
                print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
            }
        #endif
    }
    
    
    // MARK: - lazy
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.videoQuality = .typeLow
        return picker
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = avatarImageViewTag
        self.addSubview(imageView)
        return imageView
    }()
    
}


extension AvatarView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //选择完图片后的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if image != nil {
            //TODO: 图片不是正方形或太大,需要转换,,,现在会拉伸图片
            imageView.image = image;
            let data = save(image: image!)
            delegate?.setImageCompletion(avatarView: self, imageData: data)
            
        } else {
            AvatarLog(message: "设置自定义图片失败") //一般不会失败.如果需要自己添加,代理方法.
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}


extension UIApplication {
    //获得当前显示的最顶的controller.如果需要可以去掉文件私有的限制
    fileprivate  func activityViewController() -> UIViewController {
        
        var normalWindow = self.delegate?.window!
        if normalWindow?.windowLevel != UIWindowLevelNormal {
            for (_,window) in self.windows.enumerated() {
                if window.windowLevel == UIWindowLevelNormal {
                    normalWindow = window
                    break
                }
            }
        }
        return self.nextTopForViewController(inViewController: (normalWindow?.rootViewController)!)
    }
    
    private func nextTopForViewController(inViewController: UIViewController) -> UIViewController {
        
        var newInViewController = inViewController
        while (newInViewController.presentedViewController != nil) {
            newInViewController = newInViewController.presentedViewController!
        }
        
        if newInViewController is UITabBarController {
            let selectedVC = self.nextTopForViewController(inViewController: ((newInViewController as! UITabBarController).selectedViewController)!)
            return selectedVC;
        } else if (newInViewController is UINavigationController) {
            let selectedVC = self.nextTopForViewController(inViewController: ((newInViewController as! UINavigationController).visibleViewController)!)
            return selectedVC
        } else {
            return newInViewController
        }
        
    }
    
}


