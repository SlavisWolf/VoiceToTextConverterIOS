//
//  ViewController.h
//  VoiceToTextConverter
//
//  Created by Antonio Jesús on 03/05/2019.
//  Copyright © 2019 Antonio Jesús. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *voiceLabel;
- (IBAction)recordAudio:(UIButton *)sender;


@end

