# AvatarView
easy to use! 简单易用,功能全面,高度自定义的头像插件

自己在写代码的时候, 觉得现在写的APP都有一个个人中心的页面,中心页面有各种设计,但是头像按钮就那点功能...
于是就把自己散落在不同controller上的代码集合里来,封装了一个头像控件...
用Swift 3 编写

[GitHub:AvatarView](https://github.com/chquanquan/AvatarView)

没有复杂的逻辑,只有自己平常对功能的理解.

实现的功能包括:

1. 相机或相册选取头像,完成后通过代理可上传到服务器.
2. 通过URL异步加载头像.
3. 头像持久化存储.
4. 给头像附加标识,如,普通用户,VIP用户啥的.
5. 可自定义点击头像的方法.
6. 可xib创建,也可纯代码创建.
7. 头像位置任意调整与设置边框.
8. 一句代码还原头像,删除头像文件.
9. 调试日志开关,默认关闭.
10. demo上有详细调用例子.
11. 可自定义占位图片以及图片保存位置. 
12. 注释都很清晰,不合要求的时候很方便修改

![demo展示](https://github.com/chquanquan/AvatarView/blob/master/demoImage.png?raw=true)


温馨提示:(百度一下就能找到方法)
- 在IOS9以上加载网络头像资源, 要在info.plist里面设置权限,不然不得访问http网络
- 在IOS10以上, 访问相册和摄像头也都要在info.plist里申请权限,不然会crash.

谢谢你看完.如果代码有BUG或你有建议可以告诉我,及时修改.^_^
如果可以给个Star,让我高兴一下? ^_^








