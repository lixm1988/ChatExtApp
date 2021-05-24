//
//  GiftView.m
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/18.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "GiftView.h"

@interface GiftView ()<GiftCellViewDelegate>
@property (nonatomic,strong) GiftCellView* selectedGift;
@end

@implementation GiftView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    self.layer.cornerRadius = 5;
    UILabel * textRemainder = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 16)];
    textRemainder.text = @"剩余:";
    textRemainder.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    [self addSubview:textRemainder];
    
    UILabel * valueRemainder = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 50, 16)];
    valueRemainder.text = @"2000";
    valueRemainder.textColor = [UIColor colorWithRed:253/255.0 green:163/255.0 blue:0/255.0 alpha:1.0];
    [self addSubview:valueRemainder];
    
    UILabel * getCreditsText = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-35, 10, 70, 16)];
    getCreditsText.text = @"获取学分";
    getCreditsText.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [self addSubview:getCreditsText];
    
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"X" forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:20] ];
    closeButton.frame = CGRectMake(self.bounds.size.width - 40, 12, 18, 18);
    [closeButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self addSubview:closeButton];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* spliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, 1)];
    spliderView.backgroundColor = [UIColor grayColor];
    [self addSubview:spliderView];
    
    int buttonwidth = self.bounds.size.width/8;
    GiftCellView* flowerGift = [[GiftCellView alloc] initWithFrame:CGRectMake(0, 44, buttonwidth, 110) type:GiftTypeFlower];
    flowerGift.delegate = self;
    [self addSubview:flowerGift];
    
    GiftCellView* heartGift = [[GiftCellView alloc] initWithFrame:CGRectMake(buttonwidth, 44, buttonwidth, 110) type:GiftTypeHeart];
    heartGift.delegate = self;
    [self addSubview:heartGift];
    
    GiftCellView* drumsticksGift = [[GiftCellView alloc] initWithFrame:CGRectMake(buttonwidth * 2, 44, buttonwidth, 110) type:GiftTypeDrumsticks];
    drumsticksGift.delegate = self;
    [self addSubview:drumsticksGift];
    
    GiftCellView* colaGift = [[GiftCellView alloc] initWithFrame:CGRectMake(buttonwidth * 3, 44, buttonwidth, 110) type:GifttypeCola];
    colaGift.delegate = self;
    [self addSubview:colaGift];
    
    GiftCellView* sugerGift = [[GiftCellView alloc] initWithFrame:CGRectMake(buttonwidth * 4, 44, buttonwidth, 110) type:GiftTypeSuger];
    sugerGift.delegate = self;
    [self addSubview:sugerGift];
    
    GiftCellView* backBloodGift = [[GiftCellView alloc] initWithFrame:CGRectMake(buttonwidth * 5, 44, buttonwidth, 110) type:GiftTypeBackBlood];
    backBloodGift.delegate = self;
    [self addSubview:backBloodGift];
    
    GiftCellView* rocketGift = [[GiftCellView alloc] initWithFrame:CGRectMake(buttonwidth * 6, 44, buttonwidth, 110) type:GiftTypeRocket];
    rocketGift.delegate = self;
    [self addSubview:rocketGift];
    
}

- (void)closeAction
{
    self.hidden = YES;
}

#pragma mark - GiftCellViewDelegate

- (void)sendGift:(GiftCellView*)giftView
{
    if(self.delegate) {
        [self.delegate sendGift:giftView];
    }
}

- (void)giftDidSelected:(GiftCellView*)giftView
{
    if(self.selectedGift && self.selectedGift != giftView) {
        [self.selectedGift setGiftSelected:NO];
    }
    self.selectedGift = giftView;
}

@end
