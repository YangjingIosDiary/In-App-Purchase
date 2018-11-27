//
//  ViewController.m
//  In-App Purchase
//
//  Created by YangJing on 2018/7/30.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import "ViewController.h"
#import "IAPManager.h"

@interface ViewController () <IAPManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.text = @"交易详情：";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IAPManager manager] addIAPObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[IAPManager manager] removeIAPObserver];
}

//MARK: - private methods
- (IBAction)expendAction:(id)sender {
    self.textView.text = @"交易详情：";
    
    [[IAPManager manager] getProductInfo:@"YJIAP0001"];

}

- (IBAction)unexpendAction:(id)sender {
    self.textView.text = @"交易详情：";
    
    [[IAPManager manager] getProductInfo:@"YJIAP0002"];
}

//MARK: - IAPManagerDelegate
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
