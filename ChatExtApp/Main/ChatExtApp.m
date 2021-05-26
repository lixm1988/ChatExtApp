//
//  ChatExtApp.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "ChatExtApp.h"
#import "ChatManager+SendGift.h"
#import <BarrageRenderer/BarrageRenderer.h>
#import "AvatarBarrageView.h"
#import "EmojiKeyboardView.h"
#import "GiftView.h"
#import <WHToast/WHToast.h>
#import "UIImage+ChatExt.h"

static const NSString* kAvatarUrl = @"avatarUrl";
static const NSString* kNickname = @"nickName";
static const NSString* kChatRoomId = @"chatroomId";

#define CONTAINVIEW_HEIGHT 50
#define SENDBUTTON_HEIGHT 30
#define SENDBUTTON_WIDTH 40
#define INPUT_WIDTH 120
#define GIFTBUTTON_WIDTH 28
#define EMOJIBUTTON_WIDTH 30

@interface ChatExtApp () <ChatManagerDelegate,UITextFieldDelegate,BarrageRendererDelegate,GiftViewDelegate,EmojiKeyboardDelegate>
@property (nonatomic,strong) AgoraExtAppContext * context;
@property (nonatomic,strong) ChatManager* chatManager;
@property (nonatomic,strong) UITextField* inputField;
@property (nonatomic,strong) UIView* containView;
@property (nonatomic,strong) UIButton* emojiButton;
@property (nonatomic,strong) UIButton* sendButton;
@property (nonatomic,strong) UIButton* giftButton;
@property (nonatomic,strong) BarrageRenderer * renderer;// 弹幕控制
@property (nonatomic) BOOL isShowBarrage;
@property (nonatomic,strong) EmojiKeyboardView *emojiKeyBoardView;
@property (nonatomic,strong) GiftView* giftView;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@end

@implementation ChatExtApp
#pragma mark - Data callback
- (void)propertiesDidUpdate:(NSDictionary *)properties {
    NSString* avatarurl = [self.context.properties objectForKey:kAvatarUrl];
    if(avatarurl.length > 0) {
        [self.chatManager updateAvatar:avatarurl];
    }
    NSString* nickname = [self.context.properties objectForKey:kNickname];
    if(nickname.length > 0) {
        [self.chatManager updateNickName:nickname];
    }
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    //[self.view becomeFirstResponder];
    self.context = context;
    [self initViews];
    [self initData];
}

- (void)extAppWillUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.chatManager logout];
}

#pragma mark - ChatExtApp
- (void)initViews {
    
    self.isShowBarrage = YES;
    
    self.containView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - CONTAINVIEW_HEIGHT, self.view.bounds.size.width, CONTAINVIEW_HEIGHT)];
    self.containView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containView];
    
    
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(self.containView.bounds.size.width-INPUT_WIDTH - 20-GIFTBUTTON_WIDTH, 10, INPUT_WIDTH, CONTAINVIEW_HEIGHT-20)];
    self.inputField.placeholder = @"发个弹幕吧";
    self.inputField.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    self.inputField.layer.cornerRadius = 15;
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.delegate = self;
    [self.containView addSubview:self.inputField];
    
    self.giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamedFromBundle:@"icon_gift"];
    [self.giftButton setImage:image forState:UIControlStateNormal];
    [self.giftButton setImage:image forState:UIControlStateDisabled];
    self.giftButton.frame = CGRectMake(self.containView.bounds.size.width-GIFTBUTTON_WIDTH, (CONTAINVIEW_HEIGHT - GIFTBUTTON_WIDTH)/2, GIFTBUTTON_WIDTH, GIFTBUTTON_WIDTH);
    self.giftButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.containView addSubview:self.giftButton];
    [self.giftButton addTarget:self action:@selector(sendGiftAction) forControlEvents:UIControlEventTouchUpInside];
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_emoji"] forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamedFromBundle:@"icon_keyboard"] forState:UIControlStateSelected];
    self.emojiButton.frame = CGRectMake(self.containView.bounds.size.width - 100, CONTAINVIEW_HEIGHT-EMOJIBUTTON_WIDTH-5,  EMOJIBUTTON_WIDTH, EMOJIBUTTON_WIDTH);
    [self.containView addSubview:self.emojiButton];
    self.emojiButton.hidden = YES;
    [self.emojiButton addTarget:self action:@selector(emojiButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.containView.bounds.size.width - SENDBUTTON_WIDTH, CONTAINVIEW_HEIGHT-SENDBUTTON_HEIGHT-5,  SENDBUTTON_WIDTH, SENDBUTTON_HEIGHT);
    [self.containView addSubview:self.sendButton];
    self.sendButton.hidden = YES;
    [self.sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    if(self.isShowBarrage)
    {
        [self setupBarrangeRender];
        [self startBarrage];
    }
    
    self.emojiKeyBoardView = [[EmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 176)];
    self.emojiKeyBoardView.delegate = self;
    
    [self.view addSubview:self.giftView];
    self.giftView.hidden = YES;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    [self.view addGestureRecognizer:self.tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    
}

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {

        if([self.inputField isFirstResponder]) {
            [self.inputField resignFirstResponder];
        }
    }
}

- (void)setupBarrangeRender
{
    _renderer = [[BarrageRenderer alloc]init];
    _renderer.smoothness = .2f;
    _renderer.delegate = self;
    _renderer.canvasMargin = UIEdgeInsetsMake(10, 10, 10, 60);
    [self.view addSubview:_renderer.view];
    [self.view sendSubviewToBack:_renderer.view];
}

- (void)startBarrage
{
    [_renderer start];
}

- (void)stopBarrage
{
    [_renderer stop];
}

- (void)recallMsg:(NSString*)msgId
{
    if(msgId.length > 0)
        [_renderer removeSpriteWithIdentifier:msgId];
}

- (BarrageDescriptor *)buildBarrageDescriptor:(BarrageMsgInfo*)aInfo
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc] init];
    
    descriptor.params[@"speed"] = @(arc4random() % 30+30);
    descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
    descriptor.params[@"side"] = @(BarrageWalkSideDefault);
    if(aInfo.isGift)
    {
        descriptor.spriteName = NSStringFromClass([BarrageWalkSprite class]);
        descriptor.params[@"viewClassName"] = NSStringFromClass([AvatarBarrageView class]);
        descriptor.params[@"titles"] = @[aInfo.text];
        if(aInfo.avatarUrl.length > 0)
            descriptor.params[@"avatarUrl"] = aInfo.avatarUrl;
        if(aInfo.giftUrl.length > 0){
            descriptor.params[@"giftUrl"] = aInfo.giftUrl;
        }
    }else{
        descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
        descriptor.params[@"text"] = aInfo.text;
        descriptor.params[@"textColor"] = [UIColor blueColor];
    }
    
    descriptor.params[@"identifier"] = aInfo.msgId;
    
    return descriptor;
}

- (void)initData {
    [self.chatManager launch];
}

- (ChatManager*)chatManager
{
    if(!_chatManager) {
        ChatUserConfig* user = [[ChatUserConfig alloc] init];
        user.username = [self.context.localUserInfo.userUuid lowercaseString];
        user.avatarurl = [self.context.properties objectForKey:kAvatarUrl];
        user.nickname = [self.context.properties objectForKey:kNickname];
        user.roomUuid = self.context.roomInfo.roomUuid;
        user.role = 2;
        _chatManager = [[ChatManager alloc] initWithUserConfig:user chatRoomId:[self.context.properties objectForKey:kChatRoomId]];
        _chatManager.delegate = self;
    }
    return _chatManager;
}

- (GiftView*)giftView
{
    if(!_giftView) {
        _giftView = [[GiftView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 180, self.view.bounds.size.width, 180)];
        _giftView.delegate = self;
    }
    return _giftView;
}

- (void)sendGiftAction
{
    self.giftView.hidden = NO;
}

- (void)emojiButtonAction
{
    [self.emojiButton setSelected:!self.emojiButton.isSelected];
    [self changeKeyBoardType];
}

- (void)changeKeyBoardType
{
    if(self.emojiButton.isSelected) {
        self.inputField.inputView = self.emojiKeyBoardView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField reloadInputViews];
        });
    }else{
        self.inputField.inputView = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.inputField reloadInputViews];
        });
    }
}

- (void)sendButtonAction
{
    NSString* sendText = self.inputField.text;
    if(sendText.length > 0) {
        [self.chatManager sendCommonTextMsg:sendText];
    }
    self.inputField.text = @"";
    [self.inputField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButtonAction];
    return YES;
    
}
#pragma mark - CustomKeyBoardDelegate

- (void)emojiItemDidClicked:(NSString *)item{
    self.inputField.text = [self.inputField.text stringByAppendingString:item];
}

- (void)emojiDidDelete
{
    if ([self.inputField.text length] > 0) {
        NSRange range = [self.inputField.text rangeOfComposedCharacterSequenceAtIndex:self.inputField.text.length-1];
        self.inputField.text = [self.inputField.text substringToIndex:range.location];
    }
}

#pragma mark - 键盘显示
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
        //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //self.keyView.frame = keyboardFrame;
    //执行动画
    [UIView animateWithDuration:duration animations:^{
        self.containView.frame = CGRectMake(0, self.view.bounds.size.height - CONTAINVIEW_HEIGHT - keyboardFrame.size.height, self.view.bounds.size.width, CONTAINVIEW_HEIGHT);
        self.inputField.frame = CGRectMake(20, 10, self.containView.bounds.size.width - 80, CONTAINVIEW_HEIGHT-10);
        self.giftButton.hidden = YES;
        self.sendButton.hidden = NO;
        self.emojiButton.hidden = NO;
    }];
    
    
}

#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.containView.frame = CGRectMake(0, self.view.bounds.size.height - CONTAINVIEW_HEIGHT, self.view.bounds.size.width, CONTAINVIEW_HEIGHT);
        self.inputField.frame = CGRectMake(self.containView.bounds.size.width-INPUT_WIDTH-20-GIFTBUTTON_WIDTH, 10, INPUT_WIDTH, CONTAINVIEW_HEIGHT - 20);
        self.giftButton.hidden = NO;
        self.sendButton.hidden = YES;
        self.emojiButton.hidden = YES;
    }];
}

#pragma mark - ChatManagerDelegate
- (void)barrageMessageDidReceive
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakself.isShowBarrage) {
            NSArray<BarrageMsgInfo*>* array = [weakself.chatManager msgArray];
            for (BarrageMsgInfo* msg in array) {
                if(msg.text.length > 0 && msg.msgId.length > 0) {
                    [weakself.renderer receive:[weakself buildBarrageDescriptor:msg]];
                }
            }
        }
    });
    
}

- (void)barrageMessageDidSend:(BarrageMsgInfo*)aInfo
{
    if(self.isShowBarrage) {
        if(aInfo.msgId.length > 0 && aInfo.text.length > 0)
            [self.renderer receive:[self buildBarrageDescriptor:aInfo]];
    }
}

- (void)exceptionDidOccur:(NSString*)aErrorDescription
{
    [WHToast showErrorWithMessage:aErrorDescription duration:2 finishHandler:^{
            
    }];
}

- (void)mutedStateDidChanged
{
    if(self.chatManager.isAllMuted) {
        self.inputField.text = @"";
        self.inputField.placeholder = @"全员禁言中";
        self.inputField.enabled = NO;
        self.giftButton.enabled = NO;
    }else{
        if(self.chatManager.isMuted) {
            self.inputField.text = @"";
            self.inputField.placeholder = @"你已被禁言";
            self.inputField.enabled = NO;
            self.giftButton.enabled = NO;
        }else{
            self.inputField.placeholder = @"发个弹幕吧";
            self.inputField.enabled = YES;
            self.giftButton.enabled = YES;
        }
    }
}

- (void)barrageMessageDidRecall:(NSString*)aMessageId
{
    if(aMessageId.length > 0) {
        [self recallMsg:aMessageId];
    }
}

- (void)roomStateDidChanged:(ChatRoomState)aState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (aState) {
            case ChatRoomStateLogin:
                self.inputField.placeholder = @"正在登录";
                break;
            case ChatRoomStateLoginFailed:
                self.inputField.placeholder = @"登录失败";
                break;
            case ChatRoomStateLogined:
                self.inputField.placeholder = @"登录成功";
                break;
            case ChatRoomStateJoining:
                self.inputField.placeholder = @"正在加入房间";
                break;
            case ChatRoomStateJoined:
                self.inputField.placeholder = @"发个弹幕吧";
                break;
            case ChatRoomStateJoinFail:
                self.inputField.placeholder = @"加入房间失败";
                break;
            default:
                break;
        }
    });
    
}

#pragma mark - GiftViewDelegate
- (void)sendGift:(GiftCellView*)giftView
{
    if(giftView) {
        [self.chatManager sendGiftMsg:giftView.giftType];
    }
}

@end
