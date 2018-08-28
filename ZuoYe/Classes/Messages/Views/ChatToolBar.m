//
//  ChatToolBar.m
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ChatToolBar.h"
#import "EaseFaceView.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseEmotionManager.h"

@interface ChatToolBar()<UITextViewDelegate,EaseFaceViewDelegate>

@property (strong, nonatomic) UIView        *toolbarView;
@property (nonatomic, strong) UITextView    *chatTextView;
@property (nonatomic, strong) UIButton      *faceButton;
@property (nonatomic, strong) EaseFaceView  *faceView;
@property (nonatomic, strong) UIView        *activityButtomView;

@property (nonatomic, assign) CGFloat inputViewMaxHeight;
@property (nonatomic, assign) CGFloat inputViewMinHeight;
@property (nonatomic) CGFloat previousTextViewContentHeight;   //上一次chatTextView的contentSize.height

@end

@implementation ChatToolBar

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.inputViewMinHeight=36;
        self.inputViewMaxHeight=150;
        _activityButtomView = nil;
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        UIImageView  *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundImageView.backgroundColor = [UIColor clearColor];
        backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
        [self addSubview:backgroundImageView];
        
        _toolbarView = [[UIView alloc] initWithFrame:self.bounds];
        _toolbarView.backgroundColor = [UIColor clearColor];
        [self addSubview:_toolbarView];
        
        
        [_toolbarView addSubview:self.chatTextView];
        _previousTextViewContentHeight = [self getTextViewContentH:self.chatTextView];
        [_toolbarView addSubview:self.faceButton];
        [_toolbarView addSubview:self.faceView];
        
        [self setUpEmotions];
    }
    return self;
}

#pragma mark -- UITextViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            self.chatTextView.text = @"";
        }
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}

#pragma mark -- EaseFaceViewDelegate
#pragma mark 输入表情键盘的默认表情，或者点击删除按钮
-(void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete{
    NSString *chatText = self.chatTextView.text;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.chatTextView.attributedText];
    if (!isDelete && str.length > 0) {
        NSRange range = [self.chatTextView selectedRange];
        [attr insertAttributedString:[[EaseEmotionEscape sharedInstance] attStringFromTextForInputView:str textFont:self.chatTextView.font] atIndex:range.location];
        self.chatTextView.attributedText = attr;
    } else {
        if (chatText.length > 0) {
            NSInteger length = 1;
            if (chatText.length >= 2) {
                NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                if ([EaseEmoji stringContainsEmoji:subStr]) {
                    length = 2;
                }
            }
            self.chatTextView.attributedText = [self backspaceText:attr length:length];
        }
    }
    [self textViewDidChange:self.chatTextView];
}

#pragma mark 点击表情键盘的发送回调
-(void)sendFace{
    NSString *chatText = self.chatTextView.text;
    if (chatText.length > 0) {
        //转义回来
        NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.chatTextView.attributedText.string];
        [self.chatTextView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                  inRange:NSMakeRange(0, self.chatTextView.attributedText.length)
                                                  options:NSAttributedStringEnumerationReverse
                                               usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             if (value) {
                 EMTextAttachment* attachment = (EMTextAttachment*)value;
                 NSString *str = [NSString stringWithFormat:@"%@",attachment.imageName];
                 [attStr replaceCharactersInRange:range withString:str];
             }
         }];
        
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            if (![self.chatTextView.text isEqualToString:@""]) {
                [self.delegate didSendText:attStr];
                self.chatTextView.text = @"";
            }
        }
    }
}


#pragma mark -- Event Response
#pragma mark 表情
-(void)faceButtonAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.chatTextView resignFirstResponder];
        [self willShowBottomView:self.faceView];
        self.chatTextView.hidden = !sender.selected;
    }else{
        [self.chatTextView becomeFirstResponder];
    }
}

#pragma mark -- NSNotification
#pragma mark  UIKeyboardNotification
- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
}

#pragma mark -- Private methods
#pragma mark 创建表情
-(void)setUpEmotions{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *emotion = [emotions objectAtIndex:0];
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
    [self.faceView setEmotionManagers:@[manager]];
}

#pragma mark 切换菜单视图
- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.height : 0;
        [self willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

#pragma mark 获取textView的高度(实际为textView的contentSize的高度)
- (CGFloat)getTextViewContentH:(UITextView *)textView{
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}

#pragma mark 删除文本光标前长度为length的字符串
-(NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length{
    NSRange range = [self.chatTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}

#pragma mark 调整toolBar的高度
- (void)willShowBottomHeight:(CGFloat)bottomHeight{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    if(bottomHeight == 0 && self.height == self.toolbarView.height){
        return;
    }
    self.frame = toFrame;
}

#pragma mark 通过传入的toHeight，跳转toolBar的高度
- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < self.inputViewMinHeight) {
        toHeight = self.inputViewMinHeight;
    }
    if (toHeight > self.inputViewMaxHeight) {
        toHeight = self.inputViewMaxHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight){
        return;
    }else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
        _previousTextViewContentHeight = toHeight;
    }
}

#pragma mark 显示键盘
- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        [self willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height){
        [self willShowBottomHeight:0];
        
    }else{
        [self willShowBottomHeight:toFrame.size.height];
    }
}

#pragma mark -- Getters
#pragma mark 聊天输入框
-(UITextView *)chatTextView{
    if (!_chatTextView) {
        _chatTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 8, kScreenWidth-16-50, 34)];
        _chatTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _chatTextView.scrollEnabled = YES;
        _chatTextView.returnKeyType = UIReturnKeySend;
        _chatTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        _chatTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        _chatTextView.layer.borderWidth = 0.65f;
        _chatTextView.layer.cornerRadius = 6.0f;
        _chatTextView.font = kFontWithSize(16);
        _chatTextView.delegate = self;
    }
    return _chatTextView;
}

#pragma mark 表情
-(UIButton *)faceButton{
    if (!_faceButton) {
        _faceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.chatTextView.right+8, 5, 40, 40)];
        _faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_faceButton setImage:[UIImage imageNamed:@"chatBar_face"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
        [_faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

#pragma mark 表情视图
-(EaseFaceView *)faceView{
    if (!_faceView) {
        _faceView = [[EaseFaceView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolbarView.frame), self.width, 180)];
        [_faceView setDelegate:self];
        _faceView.backgroundColor = kRGBColor(240, 242, 247);
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _faceView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _delegate=nil;
    self.chatTextView.delegate = nil;
    self.chatTextView = nil;
}


@end
