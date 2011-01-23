/*
 iMedia Browser Framework <http://karelia.com/imedia/>
 
 Copyright (c) 2005-2011 by Karelia Software et al.
 
 iMedia Browser is based on code originally developed by Jason Terhorst,
 further developed for Sandvox by Greg Hulands, Dan Wood, and Terrence Talbot.
 The new architecture for version 2.0 was developed by Peter Baumgartner.
 Contributions have also been made by Matt Gough, Martin Wennerberg and others
 as indicated in source files.
 
 The iMedia Browser Framework is licensed under the following terms:
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in all or substantial portions of the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following
 conditions:
 
	Redistributions of source code must retain the original terms stated here,
	including this list of conditions, the disclaimer noted below, and the
	following copyright notice: Copyright (c) 2005-2011 by Karelia Software et al.
 
	Redistributions in binary form must include, in an end-user-visible manner,
	e.g., About window, Acknowledgments window, or similar, either a) the original
	terms stated here, including this list of conditions, the disclaimer noted
	below, and the aforementioned copyright notice, or b) the aforementioned
	copyright notice and a link to karelia.com/imedia.
 
	Neither the name of Karelia Software, nor Sandvox, nor the names of
	contributors to iMedia Browser may be used to endorse or promote products
	derived from the Software without prior and express written permission from
	Karelia Software or individual contributors, as appropriate.
 
 Disclaimer: THE SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS
 "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH, THE
 SOFTWARE OR THE USE OF, OR OTHER DEALINGS IN, THE SOFTWARE.
 */


// Author: Peter Baumgartner


//----------------------------------------------------------------------------------------------------------------------


#pragma mark HEADERS

#import "IMBObject.h"
#import "IMBObjectsPromise.h"
#import "IMBParser.h"
#import "IMBCommon.h"
#import "IMBOperationQueue.h"
#import "IMBObjectThumbnailLoadOperation.h"
#import "IMBObjectFifoCache.h"
#import "NSString+iMedia.h"
#import "NSFileManager+iMedia.h"
#import "NSWorkspace+iMedia.h"
#import "NSImage+iMedia.h"
#import "IMBSmartFolderNodeObject.h"


//----------------------------------------------------------------------------------------------------------------------


#pragma mark 

@implementation IMBObject

@synthesize location = _location;
@synthesize name = _name;
@synthesize preliminaryMetadata = _preliminaryMetadata;
@synthesize metadata = _metadata;
@synthesize parser = _parser;
@synthesize index = _index;
@synthesize shouldDrawAdornments = _shouldDrawAdornments;
@synthesize shouldDisableTitle = _shouldDisableTitle;

@synthesize imageLocation = _imageLocation;
@synthesize imageRepresentationType = _imageRepresentationType;
@synthesize needsImageRepresentation = _needsImageRepresentation;
@synthesize imageVersion = _imageVersion;
@synthesize isLoadingThumbnail = _isLoadingThumbnail;

@synthesize metadataDescription = _metadataDescription;
/*
 DISCUSSION: METADATA DESCRIPTION
 
 Metadata descripton is built up on a per-parser basis; see imb_imageMetadataDescriptionForMetadata
 and metadataDescriptionForMetadata for most implementations.
 
 When an attribute is available and appropriate, it is shown; otherwise it is not shown.
 We don't show a "Label: " for the attribute if its context is obvious.
 
 In order to be consistent, this is the expected order that items are shown.  If we wanted to change
 this, we would have to change a bunch of code.
 
 No-Download indicator (Flickr)
 Owner (Flickr)
 Type (Images except for Flickr, Video, not Audio)
 Artist (Audio)
 Album (Audio)
 Width x Height (Image, Video)
 Duration (Audio, Video)
 Date -- NOTE -- THERE ARE PROBABLY SOME PARSERS WHERE I STILL NEED TO INCLUDE THIS
 Comment (when available; file-based parsers should get from Finder comments)
 Tags (Flickr) --  CAN WE GET THESE FOR IPHOTO, OTHERS TOO?
 
 Maybe add License for Flickr, perhaps others from EXIF data?
 */

//----------------------------------------------------------------------------------------------------------------------


- (id) init
{
	if (self = [super init])
	{
		self.index = NSNotFound;
		self.shouldDrawAdornments = YES;
		self.needsImageRepresentation = YES;
		self.shouldDisableTitle = NO;
	}
	
	return self;
}


- (id) initWithCoder:(NSCoder*)inCoder
{
	if (self = [super init])
	{
		self.location = [inCoder decodeObjectForKey:@"location"];
		self.name = [inCoder decodeObjectForKey:@"name"];
		self.preliminaryMetadata = [inCoder decodeObjectForKey:@"preliminaryMetadata"];
		self.metadata = [inCoder decodeObjectForKey:@"metadata"];
		self.metadataDescription = [inCoder decodeObjectForKey:@"metadataDescription"];
		self.index = [inCoder decodeIntegerForKey:@"index"];
		self.shouldDrawAdornments = [inCoder decodeBoolForKey:@"shouldDrawAdornments"];
		self.shouldDisableTitle = [inCoder decodeBoolForKey:@"shouldDisableTitle"];
		self.needsImageRepresentation = YES;
	}
	
	return self;
}


- (void) encodeWithCoder:(NSCoder*)inCoder
{
	[inCoder encodeObject:self.location forKey:@"location"];
	[inCoder encodeObject:self.name forKey:@"name"];
	[inCoder encodeObject:self.preliminaryMetadata forKey:@"preliminaryMetadata"];
	[inCoder encodeObject:self.metadata forKey:@"metadata"];
	[inCoder encodeObject:self.metadataDescription forKey:@"metadataDescription"];
	[inCoder encodeInteger:self.index forKey:@"index"];
	[inCoder encodeBool:self.shouldDrawAdornments forKey:@"shouldDrawAdornments"];
	[inCoder encodeBool:self.shouldDisableTitle forKey:@"shouldDisableTitle"];
}


- (id) copyWithZone:(NSZone*)inZone
{
	IMBObject* copy = [[[self class] allocWithZone:inZone] init];
	
	copy.location = self.location;
	copy.name = self.name;
	copy.preliminaryMetadata = self.preliminaryMetadata;
	copy.metadata = self.metadata;
	copy.metadataDescription = self.metadataDescription;
	copy.parser = self.parser;
	copy.index = self.index;
	copy.shouldDrawAdornments = self.shouldDrawAdornments;
	copy.shouldDisableTitle = self.shouldDisableTitle;

	copy.imageLocation = self.imageLocation;
	copy.imageRepresentation = self.imageRepresentation;
	copy.imageRepresentationType = self.imageRepresentationType;
	copy.needsImageRepresentation = self.needsImageRepresentation;
	copy.imageVersion = self.imageVersion;
	
	return copy;
}


- (void) dealloc
{
	IMBRelease(_location);
	IMBRelease(_name);
	IMBRelease(_preliminaryMetadata);
	IMBRelease(_metadata);
	IMBRelease(_metadataDescription);
	IMBRelease(_parser);
	IMBRelease(_imageLocation);
	IMBRelease(_imageRepresentation);
	IMBRelease(_imageRepresentationType);

	[super dealloc];
}


//----------------------------------------------------------------------------------------------------------------------


#pragma mark 
#pragma mark IKImageBrowserItem Protocol


// Use the path or URL as the unique identifier...

- (NSString*) imageUID
{
	if (_imageLocation)
	{
		return _imageLocation;
	}
		
	return _location;
}


// The name of the object will be used as the title in IKImageBrowserView and tables.

- (NSString*) imageTitle
{
	NSString *name = self.name;
	if (!name || [name isEqualToString:@""])
	{
		name = NSLocalizedStringWithDefaultValue(
												 @"IMBObject.untitled",
												 nil,IMBBundle(),
												 @"untitled",
												 @"placeholder for untitled image");
	}
	return name;
}


// When this method is called we assume that the object is about to be displayed. So this could be a 
// possible hook for lazily loading thumbnail and metadata...

- (id) imageRepresentation
{
	if (self.needsImageRepresentation)
	{
		// we may have logging down in this method of IMBObject
		[self loadThumbnail];
	}
	
	return [[_imageRepresentation retain] autorelease];
}


- (BOOL) isSelectable 
{
	return YES;
}


- (BOOL) isDraggable
{
	return YES;
}


- (BOOL) needsImageRepresentation	// Override simple accessor - also return YES if no actual image rep data.
{
	return _needsImageRepresentation || (_imageRepresentation == nil);
}


//----------------------------------------------------------------------------------------------------------------------


#pragma mark 
#pragma mark QLPreviewItem Protocol 


- (NSURL*) previewItemURL
{
	return self.URL;
}


- (NSString*) previewItemTitle
{
	return self.name;
}


//----------------------------------------------------------------------------------------------------------------------


#pragma mark 
#pragma mark Asynchronous Loading


// If the image representation isn't available yet, then trigger an asynchronous loading operation...

- (void) loadMetadata
{
	if (!self.metadata)
	{
		IMBObjectThumbnailLoadOperation* operation = [[[IMBObjectThumbnailLoadOperation alloc] initWithObject:self] autorelease];
		operation.options = kIMBLoadMetadata;
		
		[[IMBOperationQueue sharedQueue] addOperation:operation];			
		
	}
}
- (void) loadThumbnail
{
	if (self.needsImageRepresentation && !self.isLoadingThumbnail)
	{
		self.isLoadingThumbnail = YES;
		// NSLog(@"Queueing load of %@", self.name);
		
		IMBObjectThumbnailLoadOperation* operation = [[[IMBObjectThumbnailLoadOperation alloc] initWithObject:self] autorelease];
		operation.options = kIMBLoadMetadata | kIMBLoadThumbnail;		// get metadata if needed also.
		
		[[IMBOperationQueue sharedQueue] addOperation:operation];			
	}
}


// Store the imageRepresentation and add this object to the fifo cache. Older objects get bumped out of the   
// cache and are thus unloaded...

- (void) setImageRepresentation:(id)inImageRepresentation
{
	id old = _imageRepresentation;
	_imageRepresentation = [inImageRepresentation retain];
	[old release];
	
	self.imageVersion = _imageVersion + 1;
	self.isLoadingThumbnail = NO;
	
	if (inImageRepresentation)
	{
		self.needsImageRepresentation = NO;
		[IMBObjectFifoCache addObject:self];
		
//		NSUInteger n = [IMBObjectFifoCache count];
//		NSLog(@"%s = %p (%d)",__FUNCTION__,inImageRepresentation,(int)n);
	}
}


// Unload the imageRepresentation to save some memory, if it's something that can be rebuilt.

- (BOOL) unloadThumbnail
{
	BOOL unloaded = NO;
	
	static NSSet *sTypesThatCanBeUnloaded = nil;
	if (!sTypesThatCanBeUnloaded)
	{
		sTypesThatCanBeUnloaded = [[NSSet alloc] initWithObjects:
			IKImageBrowserPathRepresentationType,				/* NSString */
			IKImageBrowserNSURLRepresentationType,				/* NSURL */
			IKImageBrowserQTMoviePathRepresentationType,		/* NSString or NSURL */
			IKImageBrowserQCCompositionPathRepresentationType,	/* NSString or NSURL */
			IKImageBrowserQuickLookPathRepresentationType,		/* NSString or NSURL*/
			IKImageBrowserIconRefPathRepresentationType,		/* NSString */
								   nil];
	}

	
	
	if ([sTypesThatCanBeUnloaded containsObject:self.imageRepresentationType])
	{
		self.imageRepresentation = nil;
		unloaded = YES;
	}
	return unloaded;
}


- (void) postProcessLocalURL:(NSURL*)localURL
{
	// For overriding by subclass
}


//----------------------------------------------------------------------------------------------------------------------


#pragma mark 
#pragma mark Pasteboard Writing


// For when we target 10.6, IMBObjects should really implement NSPasteboardWriting as it's a near perfect fit. Until then, its methods are still highly useful for support...

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard;
{
    // Try declaring promise AFTER the other types
    return [NSArray arrayWithObjects:kIMBPasteboardTypeObjectsPromise,NSFilesPromisePboardType,
            ([self isLocalFile] ? kUTTypeFileURL : kUTTypeURL), 
                     
                     // Also our own special metadata types that clients can make use of
            //kIMBPublicTitleListPasteboardType, kIMBPublicMetadataListPasteboardType,
                     
                     nil]; 
    // Used to be this. Any advantage to having both?  [NSArray arrayWithObjects:kIMBPasteboardTypeObjectsPromise,NSFilenamesPboardType,nil]
    
    
}

- (id)pasteboardPropertyListForType:(NSString *)type;
{
    if ([type isEqualToString:(NSString *)kUTTypeURL] ||
        [type isEqualToString:(NSString *)kUTTypeFileURL] ||
        [type isEqualToString:NSURLPboardType] ||
        [type isEqualToString:@"CorePasteboardFlavorType 0x6675726C"])
    {
        return [[self URL] absoluteString];
    }
    else if ([type isEqualToString:NSFilenamesPboardType])
    {
        return [NSArray arrayWithObject:[self path]];
    }
    
    return nil;
}

/*  This ought to be implemented at some point
- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard;
{
    
}*/


//----------------------------------------------------------------------------------------------------------------------


// Convert location to path...

- (NSString*) path
{
	NSString* path = nil;
	
	if ([_location isKindOfClass:[NSURL class]])
	{
		path = [(NSURL*)_location path];
	}
	else if ([_location isKindOfClass:[NSString class]])
	{
		path = (NSString*)_location;
	}
	
	return path;
}


// Convert location to url...

- (NSURL*) URL
{
	NSURL* url = nil;
	
	if ([_location isKindOfClass:[NSURL class]])
	{
		url = (NSURL*)_location;
	}
	else if ([_location isKindOfClass:[NSString class]])
	{
		url = [NSURL fileURLWithPath:(NSString*)_location];
	}
	
	return url;
}


//----------------------------------------------------------------------------------------------------------------------


- (BOOL) isLocalFile
{
	if ([_location isKindOfClass:[NSURL class]])
	{
		return [(NSURL*)_location isFileURL];
	}
	else if ([_location isKindOfClass:[NSString class]])
	{
		NSString* path = (NSString*)_location;
		return [[NSFileManager imb_threadSafeManager] fileExistsAtPath:path];
	}
	
	return NO;
}


//----------------------------------------------------------------------------------------------------------------------


// Since an object may or may not point to a local file we have to assume that we are dealing with a remote file. 
// For this reason we may have to use the file extension to guess the uti of the object. Obviously this can fail 
// if we do not have an extension, or if we are not dealing with files or urls at all, e.g. with image capture 
// objects...

- (NSString*) type
{
	NSString* uti = nil;
	NSString* path = [self path];
	NSString* extension = [path pathExtension];
		
	if ([self isLocalFile])
	{
		uti = [NSString imb_UTIForFileAtPath:path];
	}
	else if (extension != nil)
	{
		uti = [NSString imb_UTIForFilenameExtension:extension];
	}

	if (uti != nil && [NSString imb_doesUTI:uti conformsToUTI:(NSString*)kUTTypeAliasFile])
	{
		path = [path imb_resolvedPath];
		uti = [NSString imb_UTIForFileAtPath:path];
	}
	
	return uti;
}


//----------------------------------------------------------------------------------------------------------------------


// Return a small generic icon for this file. Is the icon cached by NSWorkspace, or should be provide some 
// caching ourself?

- (NSImage*) icon
{
	static NSImage *sJavaScriptIcon = nil;
	static NSImage *sURLIcon = nil;
	
	if (!sJavaScriptIcon)
	{
		NSBundle* ourBundle = [NSBundle bundleForClass:[self class]];
		NSString* pathToImage = [ourBundle pathForResource:@"js" ofType:@"tiff"];
		sJavaScriptIcon = [[NSImage alloc] initWithContentsOfFile:pathToImage];
		
		pathToImage = [ourBundle pathForResource:@"url_icon" ofType:@"tiff"];
		sURLIcon = [[NSImage alloc] initWithContentsOfFile:pathToImage];
	}

	NSImage *result = nil;
	if (IKImageBrowserNSImageRepresentationType == self.imageRepresentationType)
	{
		result = self.imageRepresentation;
	}
	else
	{
		if ([[[self location] description] hasPrefix:@"javascript:"])	// special icon for JavaScript bookmarklets
		{
			result = sJavaScriptIcon;
		}
		else if ([[[self location] description] hasPrefix:@"place:"])	// special icon for Firefox bookmarklets, so they match look
		{
			result = [IMBSmartFolderNodeObject icon];
		}
		else if ([self isLocalFile])
		{
			NSString *type = [self type];
			result = [[NSWorkspace imb_threadSafeWorkspace] iconForFileType:type];
		}
		else
		{
			result = sURLIcon;
			// WebIconDatabase is not app-store friendly, and it doesn't actually work!
//			result = [[WebIconDatabase sharedIconDatabase] 
//					iconForURL:[self.URL absoluteString]
//					withSize:NSMakeSize(16,16)
//					cache:YES];	// Strangely, cache isn't even used in the webkit implementation
			
			/*
			 We are never getting anything other than the default globe for remote URLs.
			 We know that iconForURL: is getting past the enabled check becuase it does return a file URL.
			 So either iconForPageURL or webGetNSImage is failing in this source code of webkit.
			 
			 if (Image* image = iconDatabase()->iconForPageURL(URL, IntSize(size)))
				if (NSImage *icon = webGetNSImage(image, size))
					return icon;
			*/
			
			// NSLog(@"%p icon for %@", result, [self.URL absoluteString]);
		}
	}
	return result;
}


//----------------------------------------------------------------------------------------------------------------------


- (NSString*) description
{
	return [NSString stringWithFormat:@"%@ %@",
			[super description],
			// NSStringFromClass([self class]),
		self.location
			// ,
		//self.name, 
		//self.metadata
			];
}


//----------------------------------------------------------------------------------------------------------------------


- (NSString*) tooltipString
{
	NSString* name = [self name];
	NSString* description = [self metadataDescription];
	
	NSMutableString* tooltip = [NSMutableString string];
	
	if (name && ![name isEqualToString:@""])
	{
		if (tooltip.length > 0) [tooltip imb_appendNewline];
		[tooltip appendFormat:@"%@",name];
	}
	
	if (description && ![description isEqualToString:@""])
	{
		if (tooltip.length > 0) [tooltip imb_appendNewline];
		[tooltip appendFormat:@"%@",description];
	}
	
	return tooltip;
}


- (NSString*) view:(NSView*)inView stringForToolTip:(NSToolTipTag)inTag point:(NSPoint)inPoint userData:(void*)inUserData
{
	return [self tooltipString];
}


//----------------------------------------------------------------------------------------------------------------------


@end
