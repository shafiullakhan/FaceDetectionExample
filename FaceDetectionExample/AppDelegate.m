//
//  AppDelegate.m
//  FaceDetectionExample
//
//  Created by Johann Dowa on 11-11-01.
//  Copyright (c) 2011 ManiacDev.Com All rights reserved.
//
//  "Monster Face" Image by Tobyotter on Flickr


#import <CoreImage/CoreImage.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>   


#import "AppDelegate.h"

#import "ViewController.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

-(void)markFaces:(NSArray *)imageArray
{
    UIImageView *facePicture = [imageArray objectAtIndex:0];
    CGRect frameBounds = CGRectFromString([imageArray objectAtIndex:1]);
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace 
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // create an array containing all the detected faces from the detector    
    NSArray* features = [detector featuresInImage:image];
    
    // we'll iterate through every detected face.  CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected.  Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    for(CIFaceFeature* faceFeature in features)
    {
        // get the width of the face
        // 1. get the width by dividing Image Actual width by width that is manually set to fit the image on screen
        CGFloat faceWidth =frameBounds.size.width/facePicture.bounds.size.width;
        CGFloat faceHeight = frameBounds.size.height/facePicture.bounds.size.height;
        // 2. divide this width by faceFeature Width 
        CGFloat width = faceFeature.bounds.size.width / faceWidth;
        CGFloat height  =faceFeature.bounds.size.height / faceHeight;
        // Get Coordinate which by dividing get the actaul position of given image
        CGFloat x =frameBounds.size.width/facePicture.bounds.size.width;
        CGFloat y = frameBounds.size.height/facePicture.bounds.size.height;
        
        
        // create a UIView using the bounds of the face
        UIView* faceView = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.bounds.origin.x/x, faceFeature.bounds.origin.y/y, width, height)];
        
        // add a border around the newly created UIView
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        
        
        // add the new view to create a box around the face
        [self.window addSubview:faceView];
        
        if(faceFeature.hasLeftEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(0,0, width*0.3, width*0.3)];
            // change the background color of the eye view
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the leftEyeView based on the face
            [leftEyeView setCenter:CGPointMake(faceFeature.leftEyePosition.x/x, faceFeature.leftEyePosition.y/y)];
            // round the corners
            leftEyeView.layer.cornerRadius = width*0.15;
            // add the view to the window
            [self.window addSubview:leftEyeView];
        }
        
        if(faceFeature.hasRightEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEye = [[UIView alloc] initWithFrame:CGRectMake(0,0, width*0.3, width*0.3)];
            // change the background color of the eye view
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the rightEyeView based on the face
            [leftEye setCenter:CGPointMake(faceFeature.rightEyePosition.x/x, faceFeature.rightEyePosition.y/y)];
            // round the corners
            leftEye.layer.cornerRadius = width*0.15;
            // add the new view to the window
            [self.window addSubview:leftEye];
        }
        
        if(faceFeature.hasMouthPosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* mouth = [[UIView alloc] initWithFrame:CGRectMake(0,0, width*0.4, width*0.4)];
            // change the background color for the mouth to green
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            // set the position of the mouthView based on the face
            [mouth setCenter:CGPointMake(faceFeature.mouthPosition.x/x, faceFeature.mouthPosition.y/y)];
            // round the corners
            mouth.layer.cornerRadius = width*0.2;
            // add the new view to the window
            [self.window addSubview:mouth];
        }
    }
}

-(void)faceDetector
{
    // Load the picture for face detection
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facedetectionpic.jpg"]];
    CGRect frameBounds = image.bounds;
    
    // Change the image size to fit the screen
    image.frame = CGRectMake(0, 0, 160, 480);
//    image.frame = CGRectMake(0, 0, 320, 480);
    // Draw the face detection image
    [self.window addSubview:image];
    NSArray *array = [[NSArray alloc] initWithObjects:image,NSStringFromCGRect(frameBounds), nil];
    // Execute the method used to markFaces in background
    [self performSelectorInBackground:@selector(markFaces:) withObject:array];
    
    // flip image on y-axis to match coordinate system used by core image
    [image setTransform:CGAffineTransformMakeScale(1, -1)];
    
    // flip the entire window to make everything right side up
    [self.window setTransform:CGAffineTransformMakeScale(1, -1)];
    
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [self faceDetector]; // execute the faceDetector code
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
