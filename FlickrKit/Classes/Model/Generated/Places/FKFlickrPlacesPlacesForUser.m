//
//  FKFlickrPlacesPlacesForUser.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 12 Jun, 2013 at 17:19.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrPlacesPlacesForUser.h" 

@implementation FKFlickrPlacesPlacesForUser

- (BOOL) needsLogin {
    return YES;
}

- (BOOL) needsSigning {
    return YES;
}

- (FKPermission) requiredPerms {
    return 0;
}

- (NSString *) name {
    return @"flickr.places.placesForUser";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.place_type_id) {
		[args setValue:self.place_type_id forKey:@"place_type_id"];
	}
	if(self.place_type) {
		[args setValue:self.place_type forKey:@"place_type"];
	}
	if(self.woe_id) {
		[args setValue:self.woe_id forKey:@"woe_id"];
	}
	if(self.place_id) {
		[args setValue:self.place_id forKey:@"place_id"];
	}
	if(self.threshold) {
		[args setValue:self.threshold forKey:@"threshold"];
	}
	if(self.min_upload_date) {
		[args setValue:self.min_upload_date forKey:@"min_upload_date"];
	}
	if(self.max_upload_date) {
		[args setValue:self.max_upload_date forKey:@"max_upload_date"];
	}
	if(self.min_taken_date) {
		[args setValue:self.min_taken_date forKey:@"min_taken_date"];
	}
	if(self.max_taken_date) {
		[args setValue:self.max_taken_date forKey:@"max_taken_date"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrPlacesPlacesForUserError_PlacesForUserAreNotAvailableAtThisTime:
			return @"Places for user are not available at this time";
		case FKFlickrPlacesPlacesForUserError_RequiredParameterMissing:
			return @"Required parameter missing";
		case FKFlickrPlacesPlacesForUserError_NotAValidPlaceType:
			return @"Not a valid place type";
		case FKFlickrPlacesPlacesForUserError_NotAValidPlaceID:
			return @"Not a valid Place ID";
		case FKFlickrPlacesPlacesForUserError_NotAValidThreshold:
			return @"Not a valid threshold";
		case FKFlickrPlacesPlacesForUserError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrPlacesPlacesForUserError_MissingSignature:
			return @"Missing signature";
		case FKFlickrPlacesPlacesForUserError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrPlacesPlacesForUserError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrPlacesPlacesForUserError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrPlacesPlacesForUserError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrPlacesPlacesForUserError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrPlacesPlacesForUserError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrPlacesPlacesForUserError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrPlacesPlacesForUserError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrPlacesPlacesForUserError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
