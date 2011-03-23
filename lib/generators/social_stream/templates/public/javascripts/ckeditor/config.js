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
	['Cut','Copy','Paste'],
	['Undo','Redo'],
	['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
	['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],	
	'/',
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
	['Link','Unlink'],
	['Image','Smiley','SpecialChar'],
	'/',
	['Styles','Format','Font','FontSize'],
	['TextColor','BGColor'],
	];
};
