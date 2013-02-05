# ShareBuy iOS SDK

This SDK enables you to easily add Chat, VideoCall and product sharing functionalities to your existing iOS app. For a more comprehensive guide of all the functionalities Share&Buy offers, please visit [Oonair's](http://oonair.com/) website.

The SDK is written entirely using modern Objective-C technologies like GCD and ARC guaranteeing that your app won't see a performance hit when used and offers a block-based API in order to write more efficient and more readable controller code. 

## Installing

In order to install the SDK, first create an account and a Mobile App in our website, after this add the files inside the "ShareBuy" folder in your Xcode project.

In order to be this awesome, the SDK relies in two very common iOS Libraries as  [SBJson](http://superloopy.io/json-framework/)  and the [Facebook iOS SDK v3.1](https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/3.1/)  . Please follow the instructions in the linked websites to correctly install them.

Also, add the following Apple frameworks in the 'Linked Frameworks and Libraries' section of the target's Summary pane

* `AudioToolbox`
* `AVFoundation`
* `CoreMedia`
* `CoreGraphics`
* `CoreVideo`
* `CFNetwork`
* `libxml2`
* `libz`
* `libresolv`
* `SystemConfiguration`

And finally, add the following flag in 'Other Linker Flags' in your Target's 'Build Settings' pane:

* `-ObjC`
* `-lstdc++`

# Basic functionality

Follow this steps to build a basic app that uses ShareBuy SDK. Most of the SDK's features are shown in the "eshop" demo app shipped with the SDK, so any questions you have, make sure to look at this code first.


##  Login process

In order to start the ShareBuy library, make sure you import `ShareBuy.h` and register to the following notifications:

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBStatus:)
                                                 name:SBStatusNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBError:)
                                                 name:SBErrorNotification
                                               object:nil];

and then send this message to the ShareBuy singleton:

    [[ShareBuy sharedInstance] startWithAccountID:@"yourAccountID"
                                      mobileAppID:@"yourMobileAppID"];

When the `SBStatusNotification` is sent, make sure to present the correct View to the user according to the ShareBuy instance's state. For example, if the state is `ESBStateWaitingFBLogin` it means that the SDK is waiting for user input to start the Facebook login process, so make sure to present a `UIViewController` with a button that allows to prompt the user to start a Facebook session. For example, a sample implementation could be:

    - (IBAction)onFacebookLogin:(id)sender
    {
        [[ShareBuy sharedInstance] loginFacebook];
    }

After the user logs in using Facebook, you should receive `ESBStateAuthenticating` and eventually `ESBStateOnline` indicating that the login process is done!

## Starting a Chat Room

In order to start a Chat Room with a user, you have to options:

1. Invite a friend via email
2. Invite a friend via Facebook

In this example we'll be using an example email address. To start a conversation with a friend via email, send this message to the `ShareBuy`:

     SBRoom *newRoom = [[ShareBuy sharedInstance] createRoomInviteUserWithMail:@"john@oonair.com"
                                                               completionBlock:^(id response, NSError *error){
                                                                   if (error) {
                                                                      //Handle Error
                                                                      return;
                                                                   }
                                                                   SBContact *invitedContact = response;
                                                                   NSLog(@"Contact %@ invited", [invitedContact getFullName]);
                                                               }];

In this method, a new `SBRoom` instance will be returned immediately and a completion block will be executed when the invitation is sent. A new `SBContact` instance representing the invited contact is passed in the completion block if no error occurs. For more information regarding this method and the `SBContact` and `SBRoom` classes, make sure to read the respective headers and check the sample code in the "eshop" sample.

## Sending and receiving messages

To send a message to in a Chat Room, make sure you import `SBRoom.h` send the following message to a `SBRoom` instance:

    SBRoom *room = ...
    [room sendMessage:@"Test Message"
      completionBlock:^(id response, NSError *error){
          if (error) {
              return;
          }
          
          SBEventMessage *message = response;
		  //Do something with the message
      }];

In this method the completion block will be executed when the message is sent. A new `SBEventMessage` instance representing the sent message is passed in the completion block if no error occurs. For more information regarding this method and the `SBEventMessage`, make sure to read the respective headers and check the sample code in the "eshop" sample.

In order to receive messages from other users in a chat room, you have to register to the `SBRoomMessageNotification` like this:

    SBRoom *room = ...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewMessage:)
                                                 name:SBRoomMessageNotification
                                               object:room];

and in the `onNewMessage` selector retrieve the message like this:

    - (void) onNewMessage:(NSNotification *)notification
    {          
    	SBRoom *room = …
    	SBEventMessage *message = [room lastMessage];
    	// Do something with the message
    }
            
## Sharing and receiving products

One of the core functionalities of this product is that it enables you to share products in a chat, making this a killer feature for catalog based applications. To do this, import `SBProduct.h` and create an instance of the `SBProduct` class like this:

    + (SBProduct *) productFromDictionary:(NSDictionary *)dictionary
    {
        NSString *ID = [[dictionary objectForKey:@"id"] stringValue];
        
        SBProduct *product = [SBProduct productWithID:ID];
        product.name = [dictionary objectForKey:@"name"];
        [product setThumbnailURL:[NSURL URLWithString:[dictionary objectForKey:@"snapshot"]]];
        
        NSURL *imageURL = [NSURL URLWithString:[dictionary objectForKey:@"large_image"]];
        
        [product addImageURL:imageURL forSize:CGSizeMake(395, 507)];
        product.userMetadata = dictionary;
        
        return product;
    }

This utility method creates a `SBProduct` from a `NSDictionary` using information like the ProductID, the name of the product, a thumbnail URL and a large image URL. Make sure to add a method to your code that translates your product's model class into an `SBProduct` instance.

After this is done, sharing a product is as easy as sending a message:

      SBRoom *room = …

      [room shareProduct:product
         completionBlock:^(id response, NSError *error){
                   
             if (error) {
                 return;
             }

              SBProduct *sharedProduct = response;
		      //Do something with the product
         }];

In this method the completion block will be executed when the product is shared. A new `SBProduct ` instance representing the shared product is passed in the completion block if no error occurs.

In order to receive new products that are shared from other users in a chat room, you have to register to the `SBRoomProductNotification` like this:

    SBRoom *room = ...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBRoomProduct:)
                                                 name:SBRoomProductNotification
                                               object:room];

and in the `onNewMessage` selector retrieve the message like this:

    - (void)onSBRoomProduct:(NSNotification *)notification
    {
        	SBRoom *room = …
        	SBProduct *product = [room lastSharedProduct];
        	// Do something with the product
    }

## Video Call

Starting video calls in a chat room is incredibly easy. Just import `SBCall.h` and add the following code to start a call:

	SBRoom *room = …
    [room startCallWithVideoEnabled:YES
                       audioEnabled:YES
                    completionBlock:^(id response, NSError *error){
                             
                          if (error) {
                              //Handle error
                              return;
                          }
                      
                          SBCall *call = response;
                          [call setObserver:self]; //Make sure to implement SBCallObserverProtocol
                          //Do something with the call
                     }];

Make sure to read the `SBCallObserverProtocol` in order to understand how to implement the Call ViewController.

To listen to incoming calls, just add an observer to `SBRoomCallNotification` and the new SBCall object will be passed on the callback, like this:

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBCall:)
                                                     name:SBRoomCallNotification
                                                   object:nil];

    - (void) onSBCall:(NSNotification *)notification
    {
        SBCall *call = notification.object;
		[call setObserver:self]; //Make sure to implement SBCallObserverProtocol
    	//Handle the call
    }

Make sure to read the `SBCall.h` file in order to understand what actions can be performed on a call. Also, take a look on how the "eshop" App handles it.

# Questions

Any questions, feature requests or other inquiries, don't hesitate to contact us at [mobiledev@oonair.com](mailto:mobiledev@oonair.com) 
