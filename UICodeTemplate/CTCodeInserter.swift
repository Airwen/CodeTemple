//
//  CTCodeInserter.swift
//  UICodeTemplate
//
//  Created by 张艾文 on 2022/5/10.
//

import Foundation

enum CodeAppendType {
case insert
case append
case none
}

struct CTCodeAppendLocation {
    let startIndex: Int?
    let codeAppendType: CodeAppendType
}


func getNoneCodeAppendlocation(codelines: NSArray, selectedLineNum: Int) -> CTCodeAppendLocation {
    return CTCodeAppendLocation(startIndex: nil, codeAppendType: .none)
}

func getOCCodeAppendlocation(codelines: NSArray, selectedLineNum: Int) -> CTCodeAppendLocation {
    if selectedLineNum >= codelines.count {
        return CTCodeAppendLocation(startIndex: nil, codeAppendType: .none)
    }
    let linesCount = codelines.count
    
    for index in selectedLineNum..<linesCount {
        if let line = codelines[index] as? String{
            if line == "@end\n" {
                return CTCodeAppendLocation(startIndex: index, codeAppendType: .insert)
            }
        }
    }
    // 没有找到类的结束符号
    return CTCodeAppendLocation(startIndex: nil, codeAppendType: .none)
}

func getSwiftCodeAppendlocation(codelines: NSArray, selectedLineNum: Int) -> CTCodeAppendLocation {
    if selectedLineNum >= codelines.count {
        return CTCodeAppendLocation(startIndex: nil, codeAppendType: .none)
    }
    let linesCount = codelines.count
    for index in selectedLineNum..<linesCount {
        if let line = codelines[index] as? String{
            if line == "}\n" {
                if index == linesCount {
                    return CTCodeAppendLocation(startIndex: index, codeAppendType: .append)
                }else {
                    return CTCodeAppendLocation(startIndex: (index+1), codeAppendType: .insert)
                }
            }
        }
    }
    // 没有找到类的结束符号
    return CTCodeAppendLocation(startIndex: nil, codeAppendType: .none)
}

func getNoneClassName(codelines: NSArray, selectedLineNum: Int) -> String? {
    return nil
}

func getOCClassName(codelines: NSArray, selectedLineNum: Int) -> String? {
    if let headLineArray = codelines.subarray(with: NSMakeRange(0, selectedLineNum)) as? [String] {
        for (_, line) in headLineArray.enumerated().reversed() {
            if line.hasPrefix("@implementation") {
                if let className = line.components(separatedBy: " ").last {
                    if className.contains("\n") {
                        return className.replacingOccurrences(of: "\n", with: "")
                    }else {
                        return className
                    }
                }
            }
        }
        return nil
    }
    return nil
}

func getSwiftClassName(codelines: NSArray, selectedLineNum: Int) -> String? {
    let systemKeywords = ["public", "class", "extension", "{"]
    if let headLineArray = codelines.subarray(with: NSMakeRange(0, selectedLineNum)) as? [String] {
        for (_, line) in headLineArray.enumerated().reversed() {
            if !line.hasPrefix(" ") && !line.hasPrefix("//") && (line.contains("class") || line.contains("extension")) {
                if let words = line.components(separatedBy: ":").first?.components(separatedBy: " ") {
                    for codeWord in words {
                        if !systemKeywords.contains(codeWord) {
                            if codeWord.contains("\n") {
                                return codeWord.replacingOccurrences(of: "\n", with: "")
                            }else {
                                return codeWord
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    return nil
}

protocol CTCodeInserter {
    init(with variableName: String)
    
    func insetCode(language : LanguageType) -> String
    func insertOCCode() -> String
    func insertSwiftCode() -> String
    
    func appendLinesLocation (language : LanguageType) -> ((NSArray,Int)->(CTCodeAppendLocation))
    func getClassName (language : LanguageType) -> ((NSArray,Int)->(String?))
    
    func appendLines (language : LanguageType, withinClass: String) -> [String]
    func appendOCCodeLines() -> [String]
    func appendSwiftCodeLines(withinClass: String) -> [String]
}

extension CTCodeInserter {
    func insetCode(language : LanguageType) -> String {
        switch language {
        case .oc:
            return insertOCCode()
        case .swift:
            return insertSwiftCode()
        case .none:
            return ""
        }
    }
    func insertOCCode() -> String { "" }
    func insertSwiftCode() -> String { "" }
    
    func appendLinesLocation (language : LanguageType) -> ((NSArray,Int)->(CTCodeAppendLocation)) {
        switch language {
        case .oc:
            return getOCCodeAppendlocation
        case .swift:
            return getSwiftCodeAppendlocation
        case .none:
            return getNoneCodeAppendlocation
        }
    }
    
    func getClassName (language : LanguageType) -> ((NSArray,Int)->(String?)) {
        switch language {
        case .oc:
            return getOCClassName
        case .swift:
            return getSwiftClassName
        case .none:
            return getNoneClassName
        }
    }
    
    func appendLines (language : LanguageType, withinClass: String) -> [String] {
        switch language {
        case .oc:
            return appendOCCodeLines()
        case .swift:
            return appendSwiftCodeLines(withinClass: withinClass)
        case .none:
            return []
        }
    }
    func appendOCCodeLines() -> [String] { [] }
    func appendSwiftCodeLines(withinClass: String) -> [String] { [] }
    
    
}

struct CTNoneInserter : CTCodeInserter {
    init(with variableName: String) {
    }
}

struct CTLabelInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tUILabel *\(variable) = [[UILabel alloc] init];
        \t\(variable).font = <#UIFont#>;
        \t\(variable).numberOfLines = <#NSInteger#>;
        \t\(variable).textAlignment = <#NSTextAlignment#>;
        \t\(variable).lineBreakMode = <#NSLineBreakMode#>;
        \t\(variable).textColor = <#UIColor#>;
        """
        return result
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UILabel.init()
        \t\t\(variable).font = <#UIFont#>
        \t\t\(variable).numberOfLines = <#NSInteger#>
        \t\t\(variable).textAlignment = <#NSTextAlignment#>
        \t\t\(variable).lineBreakMode = <#NSLineBreakMode#>
        \t\t\(variable).textColor = <#UIColor#>
        """
        return result
    }
}

struct CTButtonInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tUIButton *\(variable) = [UIButton buttonWithType:<#UIButtonType#>];
        \t\(variable).titleLabel.font = <#UIFont#>;
        \t[\(variable) setBackgroundImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>];
        \t[\(variable) setImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>];
        \t[\(variable) setTitleColor:<#(nullable UIColor *)#> forState:<#(UIControlState)#>];
        \t[\(variable) setTitle:<#(nullable NSString *)#> forState:<#(UIControlState)#>];
        \t[\(variable) addTarget:<#(nullable id)#> action:<#(nonnull SEL)#> forControlEvents:<#(UIControlEvents)#>];
        
        """
        return result
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = [UIButton buttonWithType:<#UIButtonType#>];
        \t\t\(variable).titleLabel?.font = <#UIFont#>
        \t\t\(variable).setBackgroundImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        \t\t\(variable).setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        \t\t\(variable).setTitleColor(<#T##color: UIColor?##UIColor?#>, for: <#T##UIControl.State#>)
        \t\t\(variable).setTitle(<#T##title: String?##String?#>, for: <#T##UIControl.State#>)
        \t\t\(variable).addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        """
        return result
    }
}

struct CTViewInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tUIView *\(variable) = [[UIView alloc] init];
        \t\(variable).backgroundColor = <#UIColor#>;
        \t\(variable).layer.cornerRadius = <#CGFloat#>;
        \t\(variable).layer.borderColor = <#CGFloat#>;
        \t\(variable).layer.borderWidth = <#CGFloat#>;
        """
        return result
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UIView.init()
        \t\t\(variable).backgroundColor = <#UIColor#>;
        \t\t\(variable).layer.cornerRadius = <#CGFloat#>;
        \t\t\(variable).layer.borderColor = <#CGColor#>;
        \t\t\(variable).layer.borderWidth = <#CGFloat#>;
        """
        return result
    }
}

struct CTImageViewInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tUIView *\(variable) = [[UIImageView alloc] init];
        \t\(variable).backgroundColor = <#UIColor#>;
        \t\(variable).layer.cornerRadius = <#CGFloat#>;
        \t\(variable).layer.borderColor = <#CGColor#>;
        \t\(variable).layer.borderWidth = <#CGFloat#>;
        \t\(variable).image = [UIImage imageNamed:<#(nonnull NSString *)#>];
        """
        return result
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UIImageView.init()
        \t\t\(variable).backgroundColor = <#UIColor#>
        \t\t\(variable).layer.cornerRadius = <#CGFloat#>
        \t\t\(variable).layer.borderColor = <#CGColor#>
        \t\t\(variable).layer.borderWidth = <#CGFloat#>
        \t\t\(variable).image = UIImage(named: <#T##String#>)
        """
        return result
    }
}

struct CTGradientLayerInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tCAGradientLayer *\(variable) = [CAGradientLayer layer];
        \t//startPoint 与 endPoint 形成一个颜色渐变方向
        \t\(variable).startPoint = <#CGPoint#>;
        \t\(variable).endPoint = <#CGPoint#>;
        \t\(variable).locations = @[<#NSNumber#>, <#NSNumber#>];
        \t\(variable).colors = @[(__bridge id)<#CGColor#>,(__bridge id)<#CGColor#>];
        \t\(variable).frame = <#CGRect#>;
        """
        return result
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = CAGradientLayer()
        \t\t\(variable).startPoint = <#CGPoint#>
        \t\t\(variable).endPoint = <#CGPoint#>
        \t\t\(variable).locations = [<#Float#>, <#Float#>]
        \t\t\(variable).colors = [<#CGColor#>,<#CGColor#>]
        \t\t\(variable).frame = <#CGRect#>;
        """
        return result
    }
}

struct CTTextFieldInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tUITextField *\(variable) = [[UITextField alloc] init];
        \t\(variable).borderStyle = UITextBorderStyleNone;
        \t//光标的颜色
        \t\(variable).tintColor = <#UIColor#>;
        \t\(variable).textColor = <#UIColor#>;
        \t\(variable).font = <#UIFont#>;
        \t\(variable).placeholder = @"<#PlaceHolder#>";
        \t\(variable).clearButtonMode = <#UITextFieldViewMode#>;
        \t\(variable).leftView = <#UIView#>;
        \t\(variable).leftViewMode = <#UITextFieldViewMode#>;
        \t[\(variable) addTarget:<#(nullable id)#> action:<#(nonnull SEL)#> forControlEvents:UIControlEventEditingChanged];
        """
        return result
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UITextField()
        \t\t\(variable).borderStyle = .none
        \t\t\(variable).textColor = <#UIColor#>;
        \t\t//光标的颜色
        \t\t\(variable).tintColor = <#UIColor#>;
        \t\t\(variable).font = <#UIFont#>;
        \t\t\(variable).placeholder = "<#PlaceHolder#>";
        \t\t\(variable).clearButtonMode = <#UITextFieldViewMode#>;
        \t\t\(variable).leftView = <#UIView#>;
        \t\t\(variable).leftViewMode = <#UITextFieldViewMode#>;
        \t\t\(variable).addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: .editingChanged)
        """
        return result
    }
}

struct CTTextViewInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    // id<UITextViewDelegate>
    func insertOCCode() -> String {
        let result = """
        \tUITextView *\(variable) = [[UITextView alloc] init];
        \t\(variable).backgroundColor = <#UIColor#>;
        \t\(variable).textContainerInset = <#UIEdgeInsets#>;
        \t\(variable).font = <#UIFont#>;
        \t\(variable).textColor = <#UIColor#>;
        \t//光标的颜色
        \t\(variable).tintColor = <#UIColor#>;
        \t\(variable).delegate = self;
        """
        return result
    }
    
    func appendOCCodeLines() -> [String] {
        let result = """
        \n
        #pragma mark - <UITextViewDelegate>
        - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
        \t<#code#>
        \treturn YES;
        }
        """
        return [result]
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UITextView()
        \t\t\(variable).backgroundColor = <#UIColor#>;
        \t\t\(variable).textContainerInset = <#UIEdgeInsets#>;
        \t\t\(variable).font = <#UIFont#>;
        \t\t\(variable).textColor = <#UIColor#>;
        \t\t//光标的颜色
        \t\t\(variable).tintColor = <#UIColor#>;
        \t\t\(variable).delegate = self;
        """
        return result
    }
    
    func appendSwiftCodeLines(withinClass: String) -> [String] {
        let result = """
        \n
        extension \(withinClass) : UITextViewDelegate {
        
        \tpublic func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        \t\t<#code#>
        \t}
        }
        """
        return [result]
    }
}

struct CTScrollViewInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    /*
     UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:rootView.bounds];
     containerView.showsVerticalScrollIndicator = NO;
     containerView.showsHorizontalScrollIndicator = NO;
     containerView.delegate = self;
     containerView.scrollsToTop = NO;
     id<UIScrollViewDelegate>
     */
    func insertOCCode() -> String {
        let result = """
        \tUIScrollView *\(variable) = [[UIScrollView alloc] init];
        \t\(variable).backgroundColor = <#UIColor#>;
        \t\(variable).showsVerticalScrollIndicator = NO;
        \t\(variable).showsHorizontalScrollIndicator = NO;
        \t\(variable).delegate = self;
        \t\(variable).pagingEnabled = YES;
        """
        return result
    }
    
    func appendOCCodeLines() -> [String] {
        let result = """
        \n
        #pragma mark - <UIScrollViewDelegate>
        - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        \t<#code#>
        }
        
        - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
        \tif (decelerate) {
        \t\t<#code#>
        \t}
        }
        
        - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        \t<#code#>
        }
        """
        return [result]
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UIScrollView()
        \t\t\(variable).backgroundColor = <#UIColor#>;
        \t\t\(variable).showsVerticalScrollIndicator = false;
        \t\t\(variable).showsHorizontalScrollIndicator = false;
        \t\t\(variable).delegate = <#id<UIScrollViewDelegate>#>;
        \t\t\(variable).isPagingEnabled = YES;
        """
        return result
    }
    
    func appendSwiftCodeLines(withinClass: String) -> [String] {
        let result = """
        \n
        extension \(withinClass) : UIScrollViewDelegate {
        \tpublic func scrollViewDidScroll(_ scrollView: UIScrollView) {
        \t\t<#code#>
        \t}
            
        \tpublic func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        \t\tif decelerate {
        \t\t\t<#code#>
        \t\t}
        \t}
            
        \tpublic func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        \t\t<#code#>
        \t}
        }
        """
        return [result]
    }
}

struct CTTableViewInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    
    func insertOCCode() -> String {
        let result = """
        \tUITableView *\(variable) = [[UITableView alloc] initWithFrame:<#CGRect#>];
        \t\(variable).contentInset = UIEdgeInsetsMake(<#top#>, <#left#>, <#bottom#>, <#right#>);
        \t\(variable).backgroundColor = <#UIColor#>;
        \t\(variable).separatorStyle = UITableViewCellSeparatorStyleNone;
        \t\(variable).estimatedSectionHeaderHeight = 0;
        \t\(variable).estimatedSectionFooterHeight = 0;
        \t\(variable).showsVerticalScrollIndicator = NO;
        \t\(variable).showsHorizontalScrollIndicator = NO;
        \t\(variable).delegate = self;
        \t\(variable).dataSource = self;
        \t[\(variable) registerClass:<#(nullable Class)#> forCellReuseIdentifier:<#(nonnull NSString *)#>];
        \t[\(variable) registerClass:<#(nullable Class)#> forHeaderFooterViewReuseIdentifier:<#(nonnull NSString *)#>];
        """
        return result
    }
    
    func appendOCCodeLines() -> [String] {
        let result = """
        \n
        #pragma mark - <UITableViewDelegate>
        - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        \t<#code#>
        }
        
        - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        \t<#code#>
        }

        #pragma mark - <UITableViewDataSource>
        - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        \treturn <#code#>
        }
        
        - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        \treturn <#code#>
        }
        """
        return [result]
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet \(variable) = UITableView(frame: <#T##CGRect#>, style: <#T##UITableView.Style#>)
        \t\t\(variable).contentInset = UIEdgeInsets(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
        \t\t\(variable).backgroundColor =
        \t\t\(variable).separatorStyle = .none
        \t\t\(variable).estimatedSectionHeaderHeight = 0
        \t\t\(variable).estimatedSectionFooterHeight = 0
        \t\t\(variable).showsVerticalScrollIndicator = false
        \t\t\(variable).showsHorizontalScrollIndicator = false
        \t\t\(variable).delegate = self
        \t\t\(variable).dataSource = self
        \t\t\(variable).register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellReuseIdentifier: <#T##String#>)
        \t\t\(variable).register(<#T##aClass: AnyClass?##AnyClass?#>, forHeaderFooterViewReuseIdentifier: <#T##String#>)
        """
        return result
    }
    
    func appendSwiftCodeLines(withinClass: String) -> [String] {
        let result = """
        \n
        extension \(withinClass): UITableViewDataSource, UITableViewDelegate {
            
        \t// MARK: - UITableViewDataSource
        \tfunc tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        \t\t<#code#>
        \t}
            
        \tfunc tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        \t\t<#code#>
        \t}
            
        \tfunc numberOfSections(in tableView: UITableView) -> Int {
        \t\t<#code#>
        \t}
            
        \t// MARK: - UITableViewDelegate
        \tfunc tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        \t\t<#code#>
        \t}
            
        \tfunc tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        \t\t<#code#>
        \t}
        }
        """
        return [result]
    }
}

struct CTCollectionInser : CTCodeInserter {
    let variable: String
    
    init(with variableName: String) {
        variable = variableName
    }
    /*

     */
    func insertOCCode() -> String {
        let result = """
        \tUICollectionViewFlowLayout *cvLayout = [[UICollectionViewFlowLayout alloc] init];
        \tcvLayout.minimumLineSpacing = <#CGFloat#>;
        \tcvLayout.minimumInteritemSpacing = <#CGFloat#>;
        \tcvLayout.itemSize = CGSizeMake(<#width#>, <#height#>);
        \tcvLayout.sectionInset = UIEdgeInsetsMake(<#top#>, <#left#>, <#bottom#>, <#right#>);
        \t[cvLayout setScrollDirection:<#UICollectionViewScrollDirection#>];
        \tUICollectionView *\(variable) = [[UICollectionView alloc] initWithFrame:CGRectMake(<#x#>, <#y#>, <#width#>, <#height#>) collectionViewLayout:cvLayout];
        \t\(variable).backgroundColor = <#UIColor#>;
        \t[\(variable) registerClass:<#(nullable Class)#> forCellWithReuseIdentifier:<#(nonnull NSString *)#>];
        \t\(variable).delegate = self;
        \t\(variable).dataSource = self;
        \t\(variable).pagingEnabled = YES;
        \t\(variable).showsHorizontalScrollIndicator = NO;
        """
        return result
    }
    
    func appendOCCodeLines() -> [String] {
        let result = """
        \n
        #pragma mark - <UICollectionViewDelegate>
        - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        \t<#code#>
        }

        #pragma mark - <UICollectionViewDataSource>
        - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        \treturn <#code#>
        }
        
        - (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        \treturn <#code#>
        }
        """
        return [result]
    }
    
    func insertSwiftCode() -> String {
        let result = """
        \t\tlet cvLayout = UICollectionViewFlowLayout()
        \t\tcvLayout.minimumLineSpacing = <#CGFloat#>
        \t\tcvLayout.minimumInteritemSpacing = <#CGFloat#>
        \t\tcvLayout.itemSize = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        \t\tcvLayout.sectionInset = UIEdgeInsets(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
        \t\tcvLayout.scrollDirection = .horizontal
        \t\tlet \(variable) = UICollectionView(frame: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>), collectionViewLayout: cvLayout)
        \t\t\(variable).backgroundColor = <#UIColor#>;
        \t\t\(variable).register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellWithReuseIdentifier: <#T##String#>)
        \t\t\(variable).delegate = self
        \t\t\(variable).dataSource = self
        \t\t\(variable).isPagingEnabled = true
        \t\t\(variable).showsHorizontalScrollIndicator = true
        """
        return result
    }
    
    func appendSwiftCodeLines(withinClass: String) -> [String] {
        let result = """
        \n
        extension \(withinClass): UITableViewDataSource, UITableViewDelegate {
            
        \t// MARK: - UITableViewDataSource
        \tpublic func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        \t\t<#code#>
        \t}
            
        \tpublic func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        \t\t<#code#>
        \t}
            
        \tpublic func numberOfSections(in collectionView: UICollectionView) -> Int {
        \t\t<#code#>
        \t}
            
        \t// MARK: - UICollectionViewDelegate
        \tpublic func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        \t\t<#code#>
        \t}
        }
        """
        return [result]
    }
}
