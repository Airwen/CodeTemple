# CodeTemple
Xcode Source Editor Extension For UI Code Insert.

这是一款Xcode扩展程序，用于快速插入UI控件代码。适用于纯代码编写iOS App项目程序代码，如果项目使用的是XIB，Storyboard，SwiftUI，这个插件就没有用处了。

1. 根据当前的文件类型，判别是应该填充的是Objective-C还是Swift代码。
2. 根据变量的前缀判断要插入那种UI控件，在`CTCodeContext`中列出了前缀对应的UI控件类型(以作者自己的编写习惯定的，可以根据自己的喜好来改)：

```
struct UINamePrefix {
    static var label: String { "lbl" }
    static var button : String { "btn" }
    static var view : String { "v" }
    static var imageView : String { "imgv" }
    static var gradientLayer : String { "gradient" }
    static var TextField : String { "edtxt" }
    static var textView : String { "txt" }
    static var scroll : String { "sr" }
    static var tableview : String { "tv" }
    static var collectionview : String { "cv" }
}
```

使用方法一：

![Example1](https://user-images.githubusercontent.com/6836962/168228391-3f8d47e0-1454-4c6a-a817-e2f3b4218d07.png)

使用方法二：

Xcode -> "Preferences" -> "Key Bindings" -> UICodeTemple -> 添加你喜欢的快捷键(我设置的是**option+U**)

使用范例：

![Example2](https://gitee.com/AirWen/BlogImage/raw/master/Example.gif)
