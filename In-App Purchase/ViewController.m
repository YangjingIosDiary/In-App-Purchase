//
//  ViewController.m
//  In-App Purchase
//
//  Created by YangJing on 2018/7/30.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import "ViewController.h"
#import "IAPManager.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <IAPManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.textView.text = @"交易详情：";

    [IAPManager manager].delegate = self;
}

- (IBAction)confirmAction:(id)sender {
    self.textView.text = @"交易详情：";
    
    [[IAPManager manager] getProductInfo:@"product001"];

}

- (void)IAPManager:(id)manager logInfo:(NSString *)logInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = self.textView.text;

        self.textView.text = [NSString stringWithFormat:@"%@\n%@", text, logInfo];
    });
}

- (void)IAPManager:(id)manager didSuccessWithResult:(NSString *)result {
    
}

- (void)IAPManager:(id)manager didFailedWithErrorInfo:(NSString *)errorMsg {
    
}

@end
