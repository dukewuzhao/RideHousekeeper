//
//  CRBoxInputView.m
//  CRBoxInputView
//
//  Created by Chobits on 2019/1/3.
//  Copyright © 2019 Chobits. All rights reserved.
//

#import "CRBoxInputView.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, CRBoxTextChangeType) {
    CRBoxTextChangeType_NoChange,
    CRBoxTextChangeType_Insert,
    CRBoxTextChangeType_Delete,
};

@interface CRBoxInputView () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>
{
    NSInteger _oldLength;
    BOOL _ifNeedBeginEdit;
}

@property (nonatomic, strong) UITapGestureRecognizer *tapGR;
@property (nonatomic, strong, readwrite) CRBoxTextField *textField;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) NSMutableArray <NSString *> *valueArr;
@property (nonatomic, strong) NSMutableArray <CRBoxInputCellProperty *> *cellPropertyArr;

@end

@implementation CRBoxInputView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefaultValue];
        [self addNotificationObserver];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDefaultValue];
        [self addNotificationObserver];
    }
    
    return self;
}

#pragma mark - Notification Observer
- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    // 触发home按下，光标动画移除
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    // 重新进来后响应，光标动画重新开始
    [_mainCollectionView reloadData];
}

#pragma mark - You can inherit
- (void)initDefaultValue
{
    _oldLength = 0;
    self.ifNeedSecurity = NO;
    self.securityDelay = 0.3;
    self.codeLength = 4;
    self.ifNeedCursor = YES;
    self.keyBoardType = UIKeyboardTypeNumberPad;
    self.backgroundColor = [UIColor clearColor];
    _valueArr = [NSMutableArray new];
    _ifNeedBeginEdit = NO;
}

- (void)loadAndPrepareView
{
    [self loadAndPrepareViewWithBeginEdit:YES];
}

- (void)loadAndPrepareViewWithBeginEdit:(BOOL)beginEdit
{
    if (_codeLength<=0) {
        NSAssert(NO, @"请输入大于0的验证码位数");
        return;
    }
    
    [self generateCellPropertyArr];
    
    // mainCollectionView
    [self addSubview:self.mainCollectionView];
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    // textView
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
        make.left.top.mas_equalTo(0);
    }];
    
    // tap
    [self addGestureRecognizer:self.tapGR];
    
    if (beginEdit) {
        [self beginEdit];
    }
}

- (void)generateCellPropertyArr
{
    [self.cellPropertyArr removeAllObjects];
    for (int i = 0; i < self.codeLength; i++) {
        [self.cellPropertyArr addObject:[self.customCellProperty copy]];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _ifNeedBeginEdit = YES;
    [self.mainCollectionView reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _ifNeedBeginEdit = NO;
    [self.mainCollectionView reloadData];
}

#pragma mark - TextViewEdit
- (void)beginEdit{
    [self.textField becomeFirstResponder];
}

- (void)endEdit{
    [self.textField resignFirstResponder];
}

- (void)clearAll
{
    [self clearAllWithBeginEdit:YES];
}

- (void)clearAllWithBeginEdit:(BOOL)beginEdit
{
    _oldLength = 0;
    [_valueArr removeAllObjects];
    self.textField.text = @"";
    [self allSecurityClose];
    [self.mainCollectionView reloadData];
    [self triggerBlock];
    
    if (beginEdit) {
        [self beginEdit];
    }
}

#pragma mark - UITextFieldDidChange
- (void)textDidChange:(UITextField *)textField{
    
    __weak typeof(self) weakSelf = self;
    
    NSString *verStr = textField.text;
    
    //有空格去掉空格
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (verStr.length >= _codeLength) {
        verStr = [verStr substringToIndex:_codeLength];
        [self endEdit];
    }
    textField.text = verStr;
    
    // 判断删除/增加
    CRBoxTextChangeType boxTextChangeType = CRBoxTextChangeType_NoChange;
    if (verStr.length > _oldLength) {
        boxTextChangeType = CRBoxTextChangeType_Insert;
    }else if (verStr.length < _oldLength){
        boxTextChangeType = CRBoxTextChangeType_Delete;
    }
    
    // _valueArr
    if (boxTextChangeType == CRBoxTextChangeType_Delete) {
        [self setSecurityShow:NO index:_valueArr.count-1];
        [_valueArr removeLastObject];
        
    }else if (boxTextChangeType == CRBoxTextChangeType_Insert){
        if (verStr.length > 0) {
            if (_valueArr.count > 0) {
                [self replaceValueArrToAsteriskWithIndex:_valueArr.count - 1 needEqualToCount:NO];
            }
//            NSString *subStr = [verStr substringWithRange:NSMakeRange(verStr.length - 1, 1)];
//            [strongSelf.valueArr addObject:subStr];
            [_valueArr removeAllObjects];
            
            [verStr enumerateSubstringsInRange:NSMakeRange(0, verStr.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf.valueArr addObject:substring];
            }];
            
            [self delaySecurityProcess];
        }
    }
    [_mainCollectionView reloadData];
    
    _oldLength = verStr.length;
    
    if (boxTextChangeType != CRBoxTextChangeType_NoChange) {
        [self triggerBlock];
    }
}

#pragma mark - Control security show
- (void)setSecurityShow:(BOOL)isShow index:(NSInteger)index
{
    if (index < 0) {
        NSAssert(NO, @"index必须大于0");
        return;
    }
    
    CRBoxInputCellProperty *cellProperty = self.cellPropertyArr[index];
    cellProperty.ifShowSecurity = isShow;
}

- (void)allSecurityClose
{
    [self.cellPropertyArr enumerateObjectsUsingBlock:^(CRBoxInputCellProperty * _Nonnull cellProperty, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cellProperty.ifShowSecurity == YES) {
            cellProperty.ifShowSecurity = NO;
        }
    }];
}

- (void)allSecurityOpen
{
    [self.cellPropertyArr enumerateObjectsUsingBlock:^(CRBoxInputCellProperty * _Nonnull cellProperty, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cellProperty.ifShowSecurity == NO) {
            cellProperty.ifShowSecurity = YES;
        }
    }];
}


#pragma mark - Trigger block
- (void)triggerBlock
{
    if (self.textDidChangeblock) {
        BOOL isFinished = _valueArr.count == _codeLength ? YES : NO;
        self.textDidChangeblock(_textField.text, isFinished);
    }
}

#pragma mark - Asterisk
// 替换密文
- (void)replaceValueArrToAsteriskWithIndex:(NSInteger)index needEqualToCount:(BOOL)needEqualToCount
{
    if (!self.ifNeedSecurity) {
        return;
    }
    
    if (needEqualToCount && index != _valueArr.count - 1) {
        return;
    }
    
    [self setSecurityShow:YES index:index];
}

// 延时替换密文
- (void)delaySecurityProcess
{
    if (!self.ifNeedSecurity) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self delayAfter:_securityDelay dealBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.valueArr.count > 0) {
            [strongSelf replaceValueArrToAsteriskWithIndex:strongSelf.valueArr.count-1 needEqualToCount:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.mainCollectionView reloadData];
            });
        }
    }];
}

#pragma mark - DelayBlock
- (void)delayAfter:(CGFloat)delayTime dealBlock:(void (^)(void))dealBlock
{
    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime *NSEC_PER_SEC));
    dispatch_after(timer, dispatch_get_main_queue(), ^{
        if (dealBlock) {
            dealBlock();
        }
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _codeLength;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id tempCell = [self customCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if ([tempCell isKindOfClass:[CRBoxInputCell class]]) {
        
        CRBoxInputCell *cell = (CRBoxInputCell *)tempCell;
        cell.ifNeedCursor = self.ifNeedCursor;
        
        // CellProperty
        CRBoxInputCellProperty *cellProperty = self.cellPropertyArr[indexPath.row];
        cellProperty.index = indexPath.row;
        
        NSString *currentPlaceholderStr = nil;
        if (_placeholderText.length > indexPath.row) {
            currentPlaceholderStr = [_placeholderText substringWithRange:NSMakeRange(indexPath.row, 1)];
            cellProperty.cellPlaceholderText = currentPlaceholderStr;
        }
        
        // setOriginValue
        NSUInteger focusIndex = _valueArr.count;
        if (_valueArr.count > 0 && indexPath.row <= focusIndex - 1) {
            cellProperty.originValue = _valueArr[indexPath.row];
        }else{
            cellProperty.originValue = @"";
        }
        
        cell.boxInputCellProperty = cellProperty;
        
        if (_ifNeedBeginEdit) {
            cell.selected = indexPath.row == focusIndex ? YES : NO;
        }else{
            cell.selected = NO;
        }
    }
    
    return tempCell;
}

#pragma mark - Qiuck set
- (void)quickSetSecuritySymbol:(NSString *)securitySymbol
{
    if (securitySymbol.length != 1) {
        securitySymbol = @"✱";
    }
    
    self.customCellProperty.securitySymbol = securitySymbol;
}

#pragma mark - You can rewrite
- (UICollectionViewCell *)customCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CRBoxInputCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CRBoxInputCellID forIndexPath:indexPath];
    return cell;
}

#pragma mark - Setter & Getter
- (UITapGestureRecognizer *)tapGR
{
    if (!_tapGR) {
        _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEdit)];
    }
    
    return _tapGR;
}

- (UICollectionView *)mainCollectionView
{
    if (!_mainCollectionView) {
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.boxFlowLayout];
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.layer.masksToBounds = NO;
        _mainCollectionView.clipsToBounds = NO;
        [_mainCollectionView registerClass:[CRBoxInputCell class] forCellWithReuseIdentifier:CRBoxInputCellID];
    }
    
    return _mainCollectionView;
}

- (CRBoxFlowLayout *)boxFlowLayout
{
    if (!_boxFlowLayout) {
        _boxFlowLayout = [CRBoxFlowLayout new];
        _boxFlowLayout.itemSize = CGSizeMake(42, 47);
    }
    
    return _boxFlowLayout;
}

- (void)setCodeLength:(NSInteger)codeLength
{
    _codeLength = codeLength;
    self.boxFlowLayout.itemNum = codeLength;
}

- (void)setKeyBoardType:(UIKeyboardType)keyBoardType{
    _keyBoardType = keyBoardType;
    self.textField.keyboardType = keyBoardType;
}

- (CRBoxTextField *)textField
{
    if (!_textField) {
        _textField = [CRBoxTextField new];
//        _textField.alpha = 0.1;
//        _textField.tintColor = [UIColor clearColor];
//        _textField.backgroundColor = [UIColor clearColor];
//        _textField.textColor = [UIColor clearColor];
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (void)setTextContentType:(UITextContentType)textContentType
{
    _textContentType = textContentType;
    
    _textField.textContentType = textContentType;
}

- (CRBoxInputCellProperty *)customCellProperty
{
    if (!_customCellProperty) {
        _customCellProperty = [CRBoxInputCellProperty new];
    }
    
    return _customCellProperty;
}

- (NSMutableArray <CRBoxInputCellProperty *> *)cellPropertyArr
{
    if (!_cellPropertyArr) {
        _cellPropertyArr = [NSMutableArray new];
    }
    
    return _cellPropertyArr;
}

- (NSString *)textValue
{
    return _textField.text;
}

@synthesize inputAccessoryView = _inputAccessoryView;
- (void)setInputAccessoryView:(UIView *)inputAccessoryView
{
    _inputAccessoryView = inputAccessoryView;
    self.textField.inputAccessoryView = _inputAccessoryView;
}

- (UIView *)inputAccessoryView
{
    return _inputAccessoryView;
}

- (void)setIfNeedSecurity:(BOOL)ifNeedSecurity
{
    _ifNeedSecurity = ifNeedSecurity;
    
    if (ifNeedSecurity == YES) {
        [self allSecurityOpen];
    }else{
        [self allSecurityClose];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainCollectionView reloadData];
    });
}

@end
