//
//  FKFlickrGroupsDiscussTopicsGetInfo.h
//  FlickrKit
//
//  Generated by FKAPIBuilder on 12 Jun, 2013 at 17:19.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrAPIMethod.h"

typedef enum {
	FKFlickrGroupsDiscussTopicsGetInfoError_TopicNotFound = 1,		 /* The topic_id is invalid */
	FKFlickrGroupsDiscussTopicsGetInfoError_InvalidAPIKey = 100,		 /* The API key passed was not valid or has expired. */
	FKFlickrGroupsDiscussTopicsGetInfoError_ServiceCurrentlyUnavailable = 105,		 /* The requested service is temporarily unavailable. */
	FKFlickrGroupsDiscussTopicsGetInfoError_FormatXXXNotFound = 111,		 /* The requested response format was not found. */
	FKFlickrGroupsDiscussTopicsGetInfoError_MethodXXXNotFound = 112,		 /* The requested method was not found. */
	FKFlickrGroupsDiscussTopicsGetInfoError_InvalidSOAPEnvelope = 114,		 /* The SOAP envelope send in the request could not be parsed. */
	FKFlickrGroupsDiscussTopicsGetInfoError_InvalidXMLRPCMethodCall = 115,		 /* The XML-RPC request document could not be parsed. */
	FKFlickrGroupsDiscussTopicsGetInfoError_BadURLFound = 116,		 /* One or more arguments contained a URL that has been used for abuse on Flickr. */

} FKFlickrGroupsDiscussTopicsGetInfoError;

/*

Get information about a group discussion topic.


Response:

<?xml version="1.0" encoding="utf-8" ?>
<rsp stat="ok">
  <topic id="72157607082559966" subject="Who's still around?" author="30134652@N05" authorname="JAMAL'S ACCOUNT" is_pro="0" role="admin" iconserver="0" iconfarm="0" count_replies="1" can_edit="1" can_delete="0" can_reply="0" is_sticky="0" is_locked="0" datecreate="1337975869" datelastpost="1337975921" last_reply="72157607082559968">
    <message>Is anyone still around in this group?</message>
  </topic>
</rsp>

*/
@interface FKFlickrGroupsDiscussTopicsGetInfo : NSObject <FKFlickrAPIMethod>

/* The ID for the topic to edit. */
@property (nonatomic, strong) NSString *topic_id; /* (Required) */


@end