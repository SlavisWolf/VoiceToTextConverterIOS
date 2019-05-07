//
//  ViewController.m
//  VoiceToTextConverter
//
//  Created by Antonio Jesús on 03/05/2019.
//  Copyright © 2019 Antonio Jesús. All rights reserved.
//

#import "ViewController.h"
#import <Speech/Speech.h>

typedef enum permissionStatus {
    accepted, denied, recognizing
}permissionStatus;

@interface ViewController ()

@property(nonatomic) permissionStatus status;

@property(nonatomic, strong)  AVAudioEngine *audioEngine;
@property(nonatomic, strong)  SFSpeechRecognizer *speechRecognizer;
@property(nonatomic, strong)  SFSpeechAudioBufferRecognitionRequest *request;
@property(nonatomic, strong)  SFSpeechRecognitionTask *recognitionTask;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _audioEngine = [AVAudioEngine new];
    _speechRecognizer = [SFSpeechRecognizer new];
    _request = [SFSpeechAudioBufferRecognitionRequest new];
    _recognitionTask = [SFSpeechRecognitionTask new];
    

}

- (void)viewDidAppear:(BOOL)animated {
    [self checkIfSpeechHasPermission];
    return [super viewDidAppear:animated];
}

- (IBAction)recordAudio:(UIButton *)sender {
    
    if (_status == accepted)  {
        [self startRecording];
        self.voiceLabel.text = @"Recording...";
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        _status = recognizing;
    }
    
    else if(_status == recognizing) {
        [self cancelRecording];
        [sender setTitle:@"Record" forState:UIControlStateNormal];
        _status = accepted;
    }
}


#pragma mark - Audio methods

-(void) startRecording {
    // Setup audio engine and speech recognizer
    AVAudioInputNode *node = _audioEngine.inputNode;
    AVAudioFormat *recordinFormat = [node outputFormatForBus:0];
    [node installTapOnBus:0 bufferSize:1024 format:recordinFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.request appendAudioPCMBuffer:buffer];
    }];
    
    //Prepare and start recording
    [_audioEngine prepare];
    NSError *error = [NSError errorWithDomain:@"AudioEngine" code:200 userInfo:@{}];
    if([_audioEngine startAndReturnError:  &error]) {
        _recognitionTask = [_speechRecognizer recognitionTaskWithRequest:_request
                                                           resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
                                                               
                                                               if(self.recognitionTask.isCancelled == NO) {
                                                                   if(result) {
                                                                       NSString *cadena = result.bestTranscription.formattedString;
                                                                       self.voiceLabel.text = cadena;
                                                                   }
                                                                   else {
                                                                       self.voiceLabel.text = @"Error recording";
                                                                   }
                                                               }
                                                           }];
    }
}

-(void) cancelRecording {
    [_audioEngine stop];
    [_audioEngine.inputNode removeTapOnBus:0];
    [_recognitionTask cancel];
}

#pragma mark - Permission methods

-(void) checkIfSpeechHasPermission {
    //We need check permissions, if we don´t have, we ask them
    switch ([SFSpeechRecognizer authorizationStatus]) {
        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
            [self askSpeechPermission];
            break;
        case SFSpeechRecognizerAuthorizationStatusAuthorized:
            _status = accepted;
            break;
            
        case SFSpeechRecognizerAuthorizationStatusDenied:
            _status = denied;
            break;
        default:
            break;
    }
}

-(void) askSpeechPermission {
    // We ask autthorization, the string of the Alert View is in info.plist
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        //When the user give a response, we update the value of our status variable
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                self.status = accepted;
                break;
                
            case SFSpeechRecognizerAuthorizationStatusDenied:
                self.status = denied;
                break;
                
            default:
                break;
        }
    }];
}

@end
