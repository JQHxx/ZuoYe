//
//  SetPriceTool.m
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "SetPriceTool.h"

@interface SetPriceTool ()<UITextFieldDelegate>{
    UIButton  *subtractBtn;
    UITextField   *quantityText;
    UIButton  *addBtn;
    double    price;
}
@end

@implementation SetPriceTool

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        price = 10.00;
        CGFloat labHeight=frame.size.height;
        
        self.layer.borderColor = [UIColor colorWithHexString:@"#FF6363"].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 4.0;
        
        //减
        subtractBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0, 30.0, labHeight)];
        [subtractBtn setTitle:@"-" forState:UIControlStateNormal];
        [subtractBtn setTitleColor:[UIColor colorWithHexString:@"#FF6363"] forState:UIControlStateNormal];
        subtractBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:22];
        [subtractBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        subtractBtn.tag=100;
        [self addSubview:subtractBtn];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(subtractBtn.right, 0, 1.0, labHeight)];
        line1.backgroundColor = [UIColor colorWithHexString:@"#FF6363"];
        [self addSubview:line1];
        
        quantityText = [[UITextField alloc] initWithFrame:CGRectMake(line1.right+5.0,5.0, 55.0,25.0)];
        quantityText.textAlignment = NSTextAlignmentCenter;
        quantityText.text=@"10.00";
        quantityText.keyboardType = UIKeyboardTypeDecimalPad;
        quantityText.delegate = self;
        quantityText.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        [quantityText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        [self addSubview:quantityText];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(quantityText.right+5.0, 0, 1.0, labHeight)];
        line2.backgroundColor = [UIColor colorWithHexString:@"#FF6363"];
        [self addSubview:line2];
        
        //加
        addBtn = [[UIButton alloc] initWithFrame:CGRectMake(line2.right, 0, 30.0, labHeight)];
        [addBtn setTitle:@"+" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor colorWithHexString:@"#FF6363"] forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:22];
        [addBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.tag=101;
        [self addSubview:addBtn];
        
    }
    return self;
}

#pragma mark -- UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]invertedSet];
    // allow backspace
    if (range.length > 0 && [string length] == 0) {
        return YES;
    }
    // do not allow . at the beggining
    if (range.location == 0 && [string isEqualToString:@"."]) {
        return NO;
    }
    
    NSString *currentText = textField.text;  //当前确定的那个输入框
    if ([string isEqualToString:@"."]&&[currentText rangeOfString:@"." options:NSBackwardsSearch].length == 0) {
        
    }else if([string isEqualToString:@"."]&&[currentText rangeOfString:@"." options:NSBackwardsSearch].length== 1) {
        string = @"";
        //alreay has a decimal point
    }
    if ([currentText containsString:@"."]) {
        NSInteger pointLo = [textField.text rangeOfString:@"."].location;
        if (currentText.length-pointLo>2) {
            string = @"";
        }
    }
    // set the text field value manually
    NSString *newValue = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([newValue doubleValue]>99.99) {
        return NO;
    }
    newValue = [[newValue componentsSeparatedByCharactersInSet:nonNumberSet]componentsJoinedByString:@""];
    textField.text = newValue;
    price = [textField.text doubleValue];
    MyLog(@"price:%.2f",price);
    if ([self.delegate respondsToSelector:@selector(setPriceToolDidSetPrice:)]) {
        [self.delegate setPriceToolDidSetPrice:price];
    }
    return NO;
}

#pragma mark 监听输入
- (void)textFieldDidChange:(UITextField *)textField{
    price = [textField.text doubleValue];
    MyLog(@"监听输入 price:%.2f",price);
    if ([self.delegate respondsToSelector:@selector(setPriceToolDidSetPrice:)]) {
        [self.delegate setPriceToolDidSetPrice:price];
    }
}


#pragma mark -- Event response
#pragma mark 数量加减
-(void)handleQuantityAction:(UIButton *)sender{
    [quantityText resignFirstResponder];
    if (sender.tag == 100) {
        price -= 1.00;
        if (price < 1.0) {
            price = 1.00;
        }
    }else{
        price += 1.00;
    }
    
    MyLog(@"price:%.1f",price);
    subtractBtn.enabled = price >1.00;
    quantityText.text=[NSString stringWithFormat:@"%.2f",price];
    if ([self.delegate respondsToSelector:@selector(setPriceToolDidSetPrice:)]) {
        [self.delegate setPriceToolDidSetPrice:price];
    }
}

@end
