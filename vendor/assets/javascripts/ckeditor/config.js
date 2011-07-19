/*
 Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
 For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	config.uiColor = '#DEEFF8';

	config.toolbar = 'SocialStream';

	config.toolbar_SocialStream =
	[
	['Bold','Italic','Underline','Strike'],
	['Undo','Redo'],
	['NumberedList','BulletedList','Blockquote'],	
	['Link','Unlink'],
	['Image','Smiley']
	];
};
