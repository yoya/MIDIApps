#import "SSERecordOneController.h"

#import "SSEMainWindowController.h"
#import "SSEMIDIController.h"


@interface SSERecordOneController (Private)

- (void)readFinished:(NSNotification *)notification;

@end


@implementation SSERecordOneController

//
// SSERecordController subclass
//

- (NSString *)nibName;
{
    return @"RecordOne";
}

- (void)tellMIDIControllerToStartRecording;
{
    [nonretainedMIDIController listenForOneMessage];    
}

- (void)updateIndicatorsWithMessageCount:(unsigned int)messageCount bytesRead:(unsigned int)bytesRead totalBytesRead:(unsigned int)totalBytesRead;
{
    if ((bytesRead == 0 && messageCount == 0)) {
        [progressMessageField setStringValue:[self waitingForSysexMessage]];
        [progressBytesField setStringValue:@""];
    } else {
        [progressIndicator animate:nil];
        [progressMessageField setStringValue:[self receivingSysexMessage]];
        [progressBytesField setStringValue:[NSString SnoizeMIDI_abbreviatedStringForByteCount:bytesRead + totalBytesRead]];
    }
}

- (void)observeMIDIController;
{
    [super observeMIDIController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readFinished:) name:SSEMIDIControllerReadFinishedNotification object:nonretainedMIDIController];
}

- (void)stopObservingMIDIController;
{
    [super stopObservingMIDIController];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:SSEMIDIControllerReadFinishedNotification object:nonretainedMIDIController];
}

@end


@implementation SSERecordOneController (Private)

- (void)readFinished:(NSNotification *)notification;
{
    // If there is an update pending, cancel it and do it now.
    if (scheduledProgressUpdate) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateIndicators) object:nil];
        scheduledProgressUpdate = NO;
        [self updateIndicators];
    }

    // Close the sheet, after a little bit of a delay (makes it look nicer)
    [NSApp performSelector:@selector(endSheet:) withObject:sheetWindow afterDelay:0.5];

    [self stopObservingMIDIController];

    [nonretainedMainWindowController addReadMessagesToLibrary];
}

@end
