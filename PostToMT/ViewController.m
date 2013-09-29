//
//  ViewController.m
//  PostToMT
//
//  Created by hajime fujimoto on 2013/09/18.
//  Copyright (c) 2013年 Hajime Fujimoto. All rights reserved.
//

#import "ViewController.h"

NSString const *endpoint_base = @"http://your-host/path-to-mt/mt-data-api.cgi/v1/";
NSString const *username = @"your-username";
NSString const *password = @"your-password";
NSString const *siteId = @"1";

@implementation ViewController
NSString *accessToken;

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    [self.btnSend setEnabled:NO];
    NSString* endpoint_auth = [NSString stringWithFormat:@"%@/authentication", endpoint_base];
    NSURL *url = [NSURL URLWithString:endpoint_auth];
    NSString *query = [NSString stringWithFormat:@"username=%@&password=%@&clientId=example", username, password];
    NSData *reqbody = [query dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL: url
            cachePolicy:NSURLRequestUseProtocolCachePolicy
            timeoutInterval:60.0];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [reqbody length]]
             forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:reqbody];
    
    [NSURLConnection sendAsynchronousRequest:request
        queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (data) {
                NSError *error = nil;
                NSDictionary *resp =
                    [NSJSONSerialization JSONObjectWithData:data
                        options:NSJSONReadingMutableContainers
                        error:&error];
                //NSLog(@"%@", resp);
                if ([resp objectForKey:@"error"] != nil) {
                    NSString *errmsg = [[resp objectForKey:@"error"] objectForKey:@"message"];
                    NSString *msg = [NSString stringWithFormat:@"ログインできませんでした:%@", errmsg];
                    [self showMessage:@"ログイン失敗" message:msg];
                }
                else {
                    accessToken = [resp objectForKey:@"accessToken"];
                    [self showMessage:@"ログイン成功" message:@"ログインしました"];
                    [self.btnSend setEnabled:YES];
                }
            }
            else {
                [self showMessage:@"ログイン失敗" message:@"ログインできませんでした:通信異常"];
            }
        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClick:(id)sender {
    //NSLog(@"click");
    NSError *error;
    [self.btnSend setEnabled:NO];
    NSString* endpoint_create = [NSString stringWithFormat:@"%@/sites/%@/entries", endpoint_base, siteId];
    NSURL *url = [NSURL URLWithString:endpoint_create];
    NSDictionary *entry = @{
        @"title": self.txtTitle.text,
        @"body": self.tvwBody.text
    };
    NSData *json = [NSJSONSerialization dataWithJSONObject:entry options:NSJSONWritingPrettyPrinted error:&error];
    //NSLog(@"json = %@", json);
    NSString *jsonstr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSString *json_encoded = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)jsonstr, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                          kCFStringEncodingUTF8 );
    //NSLog(@"jsonstr = %@", json_encoded);
    NSString *query = [NSString stringWithFormat:@"entry=%@", json_encoded];
    NSData *reqbody = [query dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"reqbody = %@", reqbody);

    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL: url
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:60.0];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [reqbody length]]
             forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"MTAuth accessToken=%@", accessToken]
             forHTTPHeaderField:@"X-MT-Authorization"];
    [request setHTTPBody:reqbody];
    //NSLog(@"request = %@", request);
    [NSURLConnection sendAsynchronousRequest:request
        queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            //NSLog(@"response = %@", response);
            [self.btnSend setEnabled:YES];
            if (data) {
                NSError *error = nil;
                NSDictionary *resp =
                    [NSJSONSerialization JSONObjectWithData:data
                        options:NSJSONReadingMutableContainers
                        error:&error];
                if ([resp objectForKey:@"error"] != nil) {
                    NSString *errmsg = [[resp objectForKey:@"error"] objectForKey:@"message"];
                    NSString *msg = [NSString stringWithFormat:@"記事を作成できませんでした:%@", errmsg];
                    [self showMessage:@"記事作成失敗" message:msg];
                }
                else {
                    accessToken = [resp objectForKey:@"accessToken"];
                    [self showMessage:@"記事作成成功" message:@"記事を作成しました"];
                    self.txtTitle.text = @"";
                    self.tvwBody.text = @"";
                }
            }
            else {
                [self showMessage:@"記事作成失敗" message:@"記事を作成できませんでした:通信異常"];
            }
        }
    ];
}

-(void) showMessage:(NSString*) title
            message:(NSString*) msg {
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:title
                               message:msg
                              delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alert show];
}

@end
