/*
 * gameQuery rev. 0.5.1
 *
 * Copyright (c) 2008 Selim Arsever (gamequery.onaluf.org)
 * licensed under the MIT (MIT-LICENSE.txt)
 */
// this allow to used the convenient $ notation in  a plugins 
(function($) {
    
    $.extend({ gameQuery: {
        /**
         * This is the Animation Object
         */
        Animation: function (options) {
            // private default values
            var defaults = {
                imageURL:		"",
                numberOfFrame:	1,
                delta:			0,
                rate: 			30,
                type:			0,
                distance:		0,
                offsetx:        0,
                offsety:        0
            };
            
            // options extends defaults
            options = $.extend(defaults, options);

            //"public" attributes:
            this.imageURL		= options.imageURL;		// The url of the image to be used as an animation or sprite 
            this.numberOfFrame	= options.numberOfFrame;// The number of frame to be displayed when playing the animation
            this.delta			= options.delta;		// The the distance in pixels between two frame
            this.rate			= options.rate;			// The rate at which the frame must be played in miliseconds
            this.type			= options.type;			// The type of the animation.This is bitwise OR of the properties.
            this.distance		= options.distance;		// The the distance in pixels between two animation
            this.offsetx        = options.offsetx;      // The x coordinate where the first sprite begin
            this.offsety        = options.offsety;      // The y coordinate where the first sprite begin
            
            //Whenever a new animation is created we add it to the ResourceManager animation list
            $.gameQuery.resourceManager.addAnimation(this);
            
            return true;
        },
        
        // "constants" for the different type of an animation
        ANIMATION_VERTICAL:   1,  // genertated by a verical offset of the background
        ANIMATION_HORIZONTAL: 2,  // genertated by a horizontal offset of the background
        ANIMATION_ONCE:       4,  // played only once (else looping indefinitly)
        ANIMATION_CALLBACK:   8,  // A callack is exectued at the end of a cycle 
        ANIMATION_MULTI:      16, // The image file contains many animations
        
        // "constants" for the different type of geometry for a sprite
        GEOMETRY_RECTANGLE:   1,
        GEOMETRY_DISC:        2, 
        
        // basic values
		refreshRate: 		  30,
        
        /**
         * An object to manages the resources loading
         **/
		resourceManager: {
            animations: [],    // List of animation / images used in the game
            sounds:     [],    // List of sounds used in the game
            callbacks:  [],    // List of the functions called at each refresh
            running:    false, // State of the game,
            
            /**
             * This function the covers things to load befor to start the game.
             **/
            preload: function() {
                //Start loading the images
                for (var i = this.animations.length-1 ; i >= 0; i --){
                    this.animations[i].domO = new Image();
                    this.animations[i].domO.src = this.animations[i].imageURL;
                }
                
                //Start loading the sounds
                for (var i = this.sounds.length-1 ; i >= 0; i --){
                    this.sounds[i].load();
                }
                 
                $.gameQuery.resourceManager.waitForResources();
            },
            
            /**
             * This function the waits for all the resources called for in preload() to finish loading.
             **/
            waitForResources: function() {
                var loadbarEnabled = ($.gameQuery.loadbar != undefined);
                if(loadbarEnabled){
                    $($.gameQuery.loadbar.id).width(0); 
                    var loadBarIncremant = $.gameQuery.loadbar.width / (this.animations.length + this.sounds.length);
                }
                //check the images
                var imageCount = 0; 
                for(var i=0; i < this.animations.length; i++){
                    if(this.animations[i].domO.complete){
                        imageCount++;
                    }
                }
                //check the sounds 
                var soundCount = 0; 
                for(var i=0; i < this.sounds.length; i++){
                    var temp = this.sounds[i].ready();
                    if(temp){
                        soundCount++;
                    }
                }
                //update the loading bar
                if(loadbarEnabled){
                    $("#"+$.gameQuery.loadbar.id).width((imageCount+soundCount)*loadBarIncremant); 
                    if($.gameQuery.loadbar.callback){
                        $.gameQuery.loadbar.callback((imageCount+soundCount)/(this.animations.length + this.sounds.length)*100);
                    }
                }
                if($.gameQuery.resourceManager.loadCallback){
                    var percent = (imageCount+soundCount)/(this.animations.length + this.sounds.length)*100;
                    $.gameQuery.resourceManager.loadCallback(percent); 
                }
                if(imageCount + soundCount < (this.animations.length + this.sounds.length)){
                    imgWait=setTimeout(function () {
                        $.gameQuery.resourceManager.waitForResources();
                    }, 100);
                } else {
                    // all the resources are loaded!
                    // We can associate the animation's images to their coresponding sprites
                    $.gameQuery.sceengraph.children().each(function(){
                        // recursive call on the children:
                        $(this).children().each(arguments.callee);
                        // add the image as a background
                        if(this.gameQuery && this.gameQuery.animation){
                            $(this).css("background-image", "url("+this.gameQuery.animation.imageURL+")");
                            // we set the correct kind of repeat
                            if(this.gameQuery.animation.type & $.gameQuery.ANIMATION_VERTICAL) {
                                $(this).css("background-repeat", "repeat-x");
                            } else if(this.gameQuery.animation.type & $.gameQuery.ANIMATION_HORIZONTAL) {
                                $(this).css("background-repeat", "repeat-y");
                            } else {
                                $(this).css("background-repeat", "no-repeat");
                            }
                        }
                    });
                    
                    // And launch the refresh loop
                    $.gameQuery.resourceManager.running = true;
                    setInterval(function () {
                        $.gameQuery.resourceManager.refresh();
                    },($.gameQuery.refreshRate));
                    if($.gameQuery.startCallback){
                        $.gameQuery.startCallback();
                    }
                    //make the sceengraph visible
                    $.gameQuery.sceengraph.css("visibility","visible");
                }
            },
            
            /**
             * This function refresh a unique sprite here 'this' represent a dom object
             **/
            refreshSprite: function() {
                //Call this function on all the children:
                // is 'this' a sprite ? 
                if(this.gameQuery != undefined){
                    var gameQuery = this.gameQuery;
                    // does 'this' has an animation ?
                    if(gameQuery.animation){
                        //Do we have anything to do?
                        if(gameQuery.idleCounter == gameQuery.animation.rate-1){
                            // does 'this' loops?
                            if(gameQuery.animation.type & $.gameQuery.ANIMATION_ONCE){
                                if(gameQuery.currentFrame < gameQuery.animation.numberOfFrame-2){
                                    gameQuery.currentFrame++;
                                } else if(gameQuery.currentFrame == gameQuery.animation.numberOfFrame-2) {
                                    gameQuery.currentFrame++;
                                    // does 'this' has a callback ?
                                    if(gameQuery.animation.type & $.gameQuery.ANIMATION_CALLBACK){
                                        if($.isFunction(gameQuery.callback)){
                                            gameQuery.callback(this);
                                        }
                                    }
                                }
                            } else {
                                gameQuery.currentFrame = (gameQuery.currentFrame+1)%gameQuery.animation.numberOfFrame;
                                if(gameQuery.currentFrame == 0){
                                    // does 'this' has a callback ?
                                    if(gameQuery.animation.type & $.gameQuery.ANIMATION_CALLBACK){
                                        if($.isFunction(gameQuery.callback)){
                                            gameQuery.callback(this);
                                        }
                                    }
                                }
                            }
                            // update the background:
                            if(gameQuery.animation.type & $.gameQuery.ANIMATION_VERTICAL){
                                if(gameQuery.multi){
                                    $(this).css("background-position",""+(-gameQuery.animation.offsetx-gameQuery.multi)+"px "+(-gameQuery.animation.offsety-gameQuery.animation.delta*gameQuery.currentFrame)+"px");
                                } else {
                                    $(this).css("background-position",""+(-gameQuery.animation.offsetx)+"px "+(-gameQuery.animation.offsety-gameQuery.animation.delta*gameQuery.currentFrame)+"px");
                                }
                            } else if(gameQuery.animation.type & $.gameQuery.ANIMATION_HORIZONTAL) {
                                if(gameQuery.multi){
                                    $(this).css("background-position",""+(-gameQuery.animation.offsetx-gameQuery.animation.delta*gameQuery.currentFrame)+"px "+(-gameQuery.animation.offsety-gameQuery.multi)+"px");
                                } else {
                                    $(this).css("background-position",""+(-gameQuery.animation.offsetx-gameQuery.animation.delta*gameQuery.currentFrame)+"px "+(-gameQuery.animation.offsety)+"px");
                                }
                            }
                        }
                        gameQuery.idleCounter = (gameQuery.idleCounter+1)%gameQuery.animation.rate;
                    }
                }
                return true;
            },
            
            /**
             * This function refresh a unique tile-map here 'this' represent a dom object
             **/
            refreshTilemap: function() {
                //Call this function on all the children:
                // is 'this' a sprite ? 
                if(this.gameQuery != undefined){
                    var gameQuery = this.gameQuery;
                    if($.isArray(gameQuery.frameTracker)){
                        for(var i=0; i<gameQuery.frameTracker.length; i++){
                            //Do we have anything to do?
                            if(gameQuery.idleCounter[i] == gameQuery.animations[i].rate-1){
                                // does 'this' loops?
                                if(gameQuery.animations[i].type & $.gameQuery.ANIMATION_ONCE){
                                    if(gameQuery.frameTracker[i] < gameQuery.animations[i].numberOfFrame-1){
                                        gameQuery.frameTracker[i]++;
                                    }
                                } else {
                                    gameQuery.frameTracker[i] = (gameQuery.frameTracker[i]+1)%gameQuery.animations[i].numberOfFrame;
                                }
                            }
                            gameQuery.idleCounter[i] = (gameQuery.idleCounter[i]+1)%gameQuery.animations[i].rate;
                        }
                    } else {
                        //Do we have anything to do?
                        if(gameQuery.idleCounter == gameQuery.animations.rate-1){
                            // does 'this' loops?
                            if(gameQuery.animations.type & $.gameQuery.ANIMATION_ONCE){
                                if(gameQuery.frameTracker < gameQuery.animations.numberOfFrame-1){
                                    gameQuery.frameTracker++;
                                }
                            } else {
                                gameQuery.frameTracker = (gameQuery.frameTracker+1)%gameQuery.animations.numberOfFrame;
                            }
                        }
                        gameQuery.idleCounter = (gameQuery.idleCounter+1)%gameQuery.animations.rate;
                    }


                    // update the background of all active tiles:
                    $(this).find(".active").each(function(){
                        if($.isArray(gameQuery.frameTracker)){
                            var animationNumber = this.gameQuery.animationNumber
                            if(gameQuery.animations[animationNumber].type & $.gameQuery.ANIMATION_VERTICAL){
                                $(this).css("background-position",""+(-gameQuery.animations[animationNumber].offsetx)+"px "+(-gameQuery.animations[animationNumber].offsety-gameQuery.animations[animationNumber].delta*gameQuery.frameTracker[animationNumber])+"px");
                            } else if(gameQuery.animations[animationNumber].type & $.gameQuery.ANIMATION_HORIZONTAL) {
                                $(this).css("background-position",""+(-gameQuery.animations[animationNumber].offsetx-gameQuery.animations[animationNumber].delta*gameQuery.frameTracker[animationNumber])+"px "+(-gameQuery.animations[animationNumber].offsety)+"px");
                            }
                        } else {
                            if(gameQuery.animations.type & $.gameQuery.ANIMATION_VERTICAL){
                                $(this).css("background-position",""+(-gameQuery.animations.offsetx-this.gameQuery.multi)+"px "+(-gameQuery.animations.offsety-gameQuery.animations.delta*gameQuery.frameTracker)+"px");
                            } else if(gameQuery.animations.type & $.gameQuery.ANIMATION_HORIZONTAL) {
                                $(this).css("background-position",""+(-gameQuery.animations.offsetx-gameQuery.animations.delta*gameQuery.frameTracker)+"px "+(-gameQuery.animations.offsety-this.gameQuery.multi)+"px");
                            }
                        }
                    });
                }
                return true;
            },
            
            /**
             * This function is called periodically to refresh the state of the game.
             **/
            refresh: function() {
                $.gameQuery.playground.find(".sprite").each(this.refreshSprite);
                $.gameQuery.playground.find(".tileSet").each(this.refreshTilemap);
                var deadCallback= new Array();
                for (var i = this.callbacks.length-1; i >= 0; i--){
                    if(this.callbacks[i].idleCounter == this.callbacks[i].rate-1){
                        var returnedValue = this.callbacks[i].fn();
                        if(typeof returnedValue == 'boolean'){
                            // if we have a boolean: 'true' means 'no more execution', 'false' means 'execute once more'
                            if(returnedValue){
                                deadCallback.push(i);
                            }
                        } else if(typeof returnedValue == 'number') {
                            // if we have a number it re-defines the time to the nex call
                            this.callbacks[i].rate = Math.round(returnedValue/$.gameQuery.refreshRate);
                            this.callbacks[i].idleCounter = 0;
                        }
                    }
                    this.callbacks[i].idleCounter = (this.callbacks[i].idleCounter+1)%this.callbacks[i].rate;
                }
                for(var i = deadCallback.length-1; i >= 0; i--){
                    this.callbacks.splice(deadCallback[i],1);
                }
            },
            
            addAnimation: function(animation) {
                if($.inArray(animation,this.animations)<0){
                    //normalize the animationRate:
                    animation.rate = Math.round(animation.rate/$.gameQuery.refreshRate);
                    if(animation.rate==0){
                        animation.rate = 1;
                    }
                    this.animations.push(animation);
                }
            },
            
            addSound: function(sound){
                if($.inArray(sound,this.sounds)<0){
                    this.sounds.push(sound);
                }
            },

            
            registerCallback: function(fn, rate){
                rate  = Math.round(rate/$.gameQuery.refreshRate);
                if(rate==0){
                    rate = 1;
                }
                this.callbacks.push({fn: fn, rate: rate, idleCounter: 0});
            }
        },
        
        // This is a single place to update the underlying data of sprites/groups/tiles
        update: function(descriptor, transformation) {
            // Did we really recieve a descriptor or a jQuery object instead?
            if(!$.isPlainObject(descriptor)){
                // Then we must get real descriptor
                if(descriptor.length > 0){
                    var gameQuery = descriptor[0].gameQuery;
                } else {
                    var gameQuery = descriptor.gameQuery;
                }
            } else {
                var gameQuery = descriptor;
            }
            // If we couldn't find one we return
            if(!gameQuery) return;
            if(gameQuery.tileSet === true){
                //then we have a tilemap!
                descriptor = $(descriptor);
                // find the tilemap offset relatif to the playground:
                var playgroundOffset = $.gameQuery.playground.offset();
                var tileSetOffset = descriptor.offset();
                tileSetOffset = {top: tileSetOffset.top - playgroundOffset.top, left: tileSetOffset.left - playgroundOffset.left};
                // test what kind of transformation we have and react accordingly:
                // Update the descriptor
                for(property in transformation){
                    switch(property){
                        case "left":
                            //Do we need to activate/desactive the first/last column
                            var left = parseFloat(transformation.left);
                            //Get the tileSet offset (relatif to the playground)
                            var playgroundOffset = $.gameQuery.playground.offset();
                            var tileSetOffset = descriptor.parent().offset();
                            tileSetOffset = {top: tileSetOffset.top - playgroundOffset.top, left: tileSetOffset.left + left - playgroundOffset.left};
                            
                            //actvates the visible tiles
                            var firstColumn = Math.max(Math.min(Math.floor(-tileSetOffset.left/gameQuery.width), gameQuery.sizex),0);
                            var lastColumn = Math.max(Math.min(Math.ceil(($.gameQuery.playground[0].width-tileSetOffset.left)/gameQuery.width), gameQuery.sizex),0);
                            
                            for(var i = gameQuery.firstRow; i < gameQuery.lastRow; i++){
                                // if old first col < new first col
                                // deactivate the newly invisible tiles
                                for(var j = gameQuery.firstColumn; j < firstColumn ; j++) {
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).removeClass("active");
                                }
                                //and activate the newly visible tiles
                                for(var j = gameQuery.lastColumn; j < lastColumn ; j++) {
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).addClass("active");
                                }
                                
                                // if old first col > new first col
                                // deactivate the newly invisible tiles
                                for(var j = lastColumn; j < gameQuery.lastColumn ; j++) {
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).removeClass("active");
                                }
                                //activate the newly visible tiles
                                for(var j = firstColumn; j < gameQuery.firstColumn ; j++) {
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).addClass("active");
                                }
                            }
                            
                            gameQuery.firstColumn = firstColumn;
                            gameQuery.lastColumn = lastColumn;
                            break;
                        case "top":
                            //Do we need to activate/desactive the first/last row
                            var top = parseFloat(transformation.top);
                            //Get the tileSet offset (relatif to the playground)
                            var playgroundOffset = $.gameQuery.playground.offset();
                            var tileSetOffset = descriptor.parent().offset();
                            tileSetOffset = {top: tileSetOffset.top + top - playgroundOffset.top, left: tileSetOffset.left - playgroundOffset.left};
                            
                            //actvates the visible tiles
                            var firstRow = Math.max(Math.min(Math.floor(-tileSetOffset.top/gameQuery.height), gameQuery.sizey), 0);
                            var lastRow = Math.max(Math.min(Math.ceil(($.gameQuery.playground[0].height-tileSetOffset.top)/gameQuery.height), gameQuery.sizey), 0);
                            
                            
                            for(var j = gameQuery.firstColumn; j < gameQuery.lastColumn ; j++) {
                                 // if old first row < new first row
                                // deactivate the newly invisible tiles
                                for(var i = gameQuery.firstRow; i < firstRow; i++){
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).removeClass("active");
                                }
                                //and activate the newly visible tiles
                                for(var i = gameQuery.lastRow; i < lastRow; i++){
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).addClass("active");
                                }
                                
                                // if old first row < new first row
                                // deactivate the newly invisible tiles
                                for(var i = lastRow; i < gameQuery.lastRow; i++){
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).removeClass("active");
                                }
                                //and activate the newly visible tiles
                                for(var i = firstRow; i < gameQuery.firstRow; i++){
                                    $("#tile_"+descriptor.attr("id")+"_"+i+"_"+j).addClass("active");
                                }
                            }
                            
                            gameQuery.firstRow = firstRow;
                            gameQuery.lastRow = lastRow;
                            
                            break;
                        case "angle": //(in degree)
                            //TODO
                            break;
                        case "factor":
                            //TODO
                            break;
                    }
                }
                
            } else {
                var refreshBoundingCircle = $.gameQuery.playground && !$.gameQuery.playground.disableCollision;
                
                // Update the descriptor
                for(property in transformation){
                    switch(property){
                        case "left":
                            gameQuery.posx = parseFloat(transformation.left);
                            if(refreshBoundingCircle){
                                gameQuery.boundingCircle.x = gameQuery.posx+gameQuery.width/2;
                            }
                            break;
                        case "top":
                            gameQuery.posy = parseFloat(transformation.top);
                            if(refreshBoundingCircle){
                                gameQuery.boundingCircle.y = gameQuery.posy+gameQuery.height/2;
                            }
                            break;
                        case "width":
                            gameQuery.width = parseFloat(transformation.width);
                            break;
                        case "height":
                            gameQuery.height = parseFloat(transformation.height);
                            break;
                        case "angle": //(in degree)
                            gameQuery.angle = parseFloat(transformation.angle);
                            break;
                        case "factor":
                            gameQuery.factor = parseFloat(transformation.factor);
                            if(refreshBoundingCircle){
                                gameQuery.boundingCircle.radius = gameQuery.factor*gameQuery.boundingCircle.originalRadius;
                            }
                            break;
                    }
                }
            }
        },
        
        // This is a utility function that returns the radius for a geometry
        proj: function (elem, angle) {
            switch (elem.geometry){
                case $.gameQuery.GEOMETRY_RECTANGLE :
                    var b = angle*Math.PI*2/360;
                    var Rx = Math.abs(Math.cos(b)*elem.width/2*elem.factor)+Math.abs(Math.sin(b)*elem.height/2*elem.factor);
                    var Ry = Math.abs(Math.cos(b)*elem.height/2*elem.factor)+Math.abs(Math.sin(b)*elem.width/2*elem.factor);
                    
                    return {x: Rx, y: Ry};
            }
        },
        
        // This is a utility function for collision of two object 
        collide: function(elem1, offset1, elem2, offset2) {
            // test real collision (only for two rectangle...)
            if((elem1.geometry == $.gameQuery.GEOMETRY_RECTANGLE && elem2.geometry == $.gameQuery.GEOMETRY_RECTANGLE)){
                
                var dx = offset2.x + elem2.boundingCircle.x - elem1.boundingCircle.x - offset1.x;
                var dy = offset2.y + elem2.boundingCircle.y - elem1.boundingCircle.y - offset1.y;
                var a  = Math.atan(dy/dx);

                var Dx = Math.abs(Math.cos(a-elem1.angle*Math.PI*2/360)/Math.cos(a)*dx);
                var Dy = Math.abs(Math.sin(a-elem1.angle*Math.PI*2/360)/Math.sin(a)*dy);
                
                var R = $.gameQuery.proj(elem2, elem2.angle-elem1.angle);
                
                if((elem1.width/2*elem1.factor+R.x <= Dx) || (elem1.height/2*elem1.factor+R.y <= Dy)) {
                    return false;
                } else {                  
                    var Dx = Math.abs(Math.cos(a-elem2.angle*Math.PI*2/360)/Math.cos(a)*-dx);
                    var Dy = Math.abs(Math.sin(a-elem2.angle*Math.PI*2/360)/Math.sin(a)*-dy);
                    
                    var R = $.gameQuery.proj(elem1, elem1.angle-elem2.angle);
                    
                    if((elem2.width/2*elem2.factor+R.x <= Dx) || (elem2.height/2*elem2.factor+R.y <= Dy)) {
                        return false;
                    } else {  
                        return true;
                    }
                }
            } else {
                return false;
            }
        }
    // This function mute (or unmute) all the sounds. 
    }, muteSound: function(muted){
        for (var i = $.gameQuery.resourceManager.sounds.length-1 ; i >= 0; i --) {
            $.gameQuery.resourceManager.sounds[i].muted(muted);
        }
    }, playground: function() { 
        return $.gameQuery.playground
    // This function define a callback that will be called upon during the 
    // loading of the game's resources. The function will recieve as unique
    // parameter a number representing the progess percentage.
    }, loadCallback: function(callback){
        $.gameQuery.resourceManager.loadCallback = callback;
    }});
    
    $.fn.extend({	
        /**
         * Define the div to use for the display the game and initailize it.
         * This could be called on any node it doesn't matter.
         * The returned node is the playground node.
         * This IS a desrtuctive call
         **/
        playground: function(options) {
            if(this.length == 1){
                if(this[0] == document){ // Old usage check
                    throw "Old playground usage, use $.playground() to retreive the playground and $('mydiv').playground(options) to set the div!";
                }
                options = $.extend({
                    height:		320,
                    width:		480,
                    refreshRate: 30,
                    position:	"absolute",
                    keyTracker:	false,
                    disableCollision: false
                }, options);
                //We save the playground node and set some variable for this node:
                $.gameQuery.playground = this;
                $.gameQuery.refreshRate = options.refreshRate;
                $.gameQuery.playground[0].height = options.height;
                $.gameQuery.playground[0].width = options.width;

                // We initialize the apearance of the div
                $.gameQuery.playground.css({
                        position: options.position,
                        display:  "block",
                        overflow: "hidden",
                        height:   options.height+"px",
                        width:    options.width+"px"
                    })
                    .append("<div id='sceengraph' style='visibility: hidden'/>");
                    
                $.gameQuery.sceengraph = $("#sceengraph");
                
                //Add the keyTracker to the gameQuery object:
                $.gameQuery.keyTracker = {};
                // we only enable the real tracking if the users wants it
                if(options.keyTracker){
                    $(document).keydown(function(event){
                        $.gameQuery.keyTracker[event.keyCode] = true;
                    });
                    $(document).keyup(function(event){
                        $.gameQuery.keyTracker[event.keyCode] = false;
                    });
                }
            }
            return this;
        },
        
        /**
        * Starts the game. The resources from the resource manager are preloaded if necesary 
        * Works only for the playgroung node.
        * This is a non-desrtuctive call
        **/
        startGame: function(callback) {
            //if the element is the playground we start the game:
            $.gameQuery.startCallback = callback;
            $.gameQuery.resourceManager.preload();
            return this;
        },
        
        /**
        * Add a group to the sceen graph
        * works only on the sceengraph root or on another group
        * This IS a desrtuctive call and should be terminated with end() to go back one level up in the chaining
        **/
        addGroup: function(group, options) {
            options = $.extend({
                width:		32,
                height:		32,
                posx:		0,
                posy:		0,
                overflow: 	"visible",
                geometry:   $.gameQuery.GEOMETRY_RECTANGLE,
                angle:          0,
                factor:         1
            }, options);
            
            var newGroupElement = "<div id='"+group+"' class='group' style='position: absolute; display: block; overflow: "+options.overflow+"; top: "+options.posy+"px; left: "+options.posx+"px; height: "+options.height+"px; width: "+options.width+"px;' />";
            if(this == $.gameQuery.playground){
                $.gameQuery.sceengraph.append(newGroupElement);
            } else if ((this == $.gameQuery.sceengraph)||(this.hasClass("group"))){
                this.append(newGroupElement);
            }
            var newGroup = $("#"+group);
            newGroup[0].gameQuery = options;
            newGroup[0].gameQuery.boundingCircle = {x: options.posx + options.width/2,
                                                    y: options.posy + options.height/0,
                                                    originalRadius: Math.sqrt(Math.pow(options.width,2) + Math.pow(options.height,2))/2};
            newGroup[0].gameQuery.boundingCircle.radius = newGroup[0].gameQuery.boundingCircle.originalRadius;
            newGroup[0].gameQuery.group = true;
            return this.pushStack(newGroup);
        },
        
        /**
        * Add a sprite to the current node.
        * Works only on the playground, the sceengraph root or a sceengraph group
        * This is a non-desrtuctive call
        **/
        addSprite: function(sprite, options) {
            options = $.extend({
                width:			32,
                height:			32,
                posx:			0,
                posy:			0,
                idleCounter:	0,
                currentFrame:	0,
                geometry:       $.gameQuery.GEOMETRY_RECTANGLE,
                angle:          0,
                factor:         1
            }, options);
            
            var newSpriteElem = "<div id='"+sprite+"' class='sprite' style='position: absolute; display: block; overflow: hidden; height: "+options.height+"px; width: "+options.width+"px; left: "+options.posx+"px; top: "+options.posy+"px; background-position: "+((options.animation)? -options.animation.offsetx : 0)+"px "+((options.animation)? -options.animation.offsety : 0)+"px;' />";
            if(this == $.gameQuery.playground){
                $.gameQuery.sceengraph.append(newSpriteElem);
            } else {
                this.append(newSpriteElem);
            }
            
            //if the game has already started we want to add the animation's image as a background now:
            if(options.animation){
                if($.gameQuery.resourceManager.running){
                    $("#"+sprite).css("background-image", "url("+options.animation.imageURL+")");
                }
                if(options.animation.type & $.gameQuery.ANIMATION_VERTICAL) {
                    $("#"+sprite).css("background-repeat", "repeat-x");
                } else if(options.animation.type & $.gameQuery.ANIMATION_HORIZONTAL) {
                    $("#"+sprite).css("background-repeat", "repeat-y");
                } else {
                    $("#"+sprite).css("background-repeat", "no-repeat");
                }
            }
            
            
            var spriteDOMObject = $("#"+sprite)[0];
            if(spriteDOMObject != undefined){
                spriteDOMObject.gameQuery = options;
                //Compute bounding Cirlce:
                spriteDOMObject.gameQuery.boundingCircle = {x: options.posx + options.width/2,
                                                            y: options.posy + options.height/2,
                                                            originalRadius: Math.sqrt(Math.pow(options.width,2) + Math.pow(options.height,2))/2};
                spriteDOMObject.gameQuery.boundingCircle.radius = spriteDOMObject.gameQuery.boundingCircle.originalRadius;
            }
            return this;
        },
        
        /**
        * Remove the sprite  on which it is called. This is here for backward compatibility  but it doesn't
        * do anything more than simply calling .remove()
        * This is a non-desrtuctive call.
        **/
        removeSprite: function() {
            this.remove();
            return this;
        },
        
        /**
        * Add a Tile Map to the selected element. 
        * This is a non-destructive call.
        **/
        addTilemap: function(name, tileDescription, animationList, options){
        	options = $.extend({
                width:			32,
                height:			32,
                sizex:          32,
                sizey:          32,
                posx:			0,
                posy:			0
            }, options);
            
            //var newSpriteElem = "<div id='"+sprite+"' style='position: absolute; display: block; overflow: hidden; height: "+options.height+"px; width: "+options.width+"px; left: "+options.posx+"px; top: "+options.posy+"px; background-position: 0px 0px;' />";
            
            var tileSet = $("<div class='tileSet' style='position: absolute; display: block; overflow: hidden;' />");
            tileSet.css({top: options.posy, left: options.posx, height: options.height*options.sizey, width: options.width*options.sizex}).attr("id",name);
            if(this == $.gameQuery.playground){
                $.gameQuery.sceengraph.append(tileSet);
            } else {
                this.append(tileSet);
            }
            
            if($.isArray(animationList)){
                var frameTracker = [];
                var idleCounter = [];
                for(var i=0; i<animationList.length; i++){
                    frameTracker[i] = 0;
                    idleCounter[i] = 0;
                }
                tileSet[0].gameQuery = options
                tileSet[0].gameQuery.frameTracker = frameTracker; 
                tileSet[0].gameQuery.animations = animationList; 
                tileSet[0].gameQuery.idleCounter =  idleCounter; 
                tileSet[0].gameQuery.tileSet = true;
            } else {
                tileSet[0].gameQuery = options
                tileSet[0].gameQuery.frameTracker = 0; 
                tileSet[0].gameQuery.animations = animationList; 
                tileSet[0].gameQuery.idleCounter =  0; 
                tileSet[0].gameQuery.tileSet = true;
            }
            
            if(typeof tileDescription == "function"){
				for(var i=0; i<options.sizey; i++){
            		for(var j=0; j<options.sizex; j++){
                        if(tileDescription(i,j) != 0){
                            if($.isArray(animationList)){
                                // for many simple animation:
                                tileSet.addSprite("tile_"+name+"_"+i+"_"+j, 
                                                      {width: options.width, 
                                                       height: options.height, 
                                                       posx: j*options.width, 
                                                       posy: i*options.height, 
                                                       animation: animationList[tileDescription(i,j)-1]});
                                var newTile = $("#tile_"+name+"_"+i+"_"+j);
                                newTile.removeClass("sprite");
                                newTile.addClass("tileType_"+(tileDescription(i,j)-1));
                                newTile[0].gameQuery.animationNumber = tileDescription(i,j)-1;
                            } else {
                                // for multi-animation:
                                tileSet.addSprite("tile_"+name+"_"+i+"_"+j, 
                                                      {width: options.width, 
                                                       height: options.height, 
                                                       posx: j*options.width, 
                                                       posy: i*options.height, 
                                                       animation: animationList});
                                var newTile = $("#tile_"+name+"_"+i+"_"+j);
                                newTile.setAnimation(tileDescription(i,j)-1);
                                newTile.removeClass("sprite");
                                newTile.addClass("tileType_"+(tileDescription(i,j)-1));
                            }
                        }
            		}	
            	}
            } else if(typeof tileDescription == "object") {
            	for(var i=0; i<tileDescription.length; i++){
            		for(var j=0; j<tileDescription[0].length; j++){
                        if(tileDescription[i][j] != 0){
                            if($.isArray(animationList)){
                                // for many simple animation:
                                tileSet.addSprite("tile_"+name+"_"+i+"_"+j, 
                                                      {width: options.width, 
                                                       height: options.height, 
                                                       posx: j*options.width, 
                                                       posy: i*options.height, 
                                                       animation: animationList[tileDescription[i][j]-1]});
                                var newTile = $("#tile_"+name+"_"+i+"_"+j);
                                newTile.removeClass("sprite");
                                newTile.addClass("tileType_"+(tileDescription[i][j]-1));
                                newTile[0].gameQuery.animationNumber = tileDescription[i][j]-1;
                            } else {
                                // for multi-animation:
                                tileSet.addSprite("tile_"+name+"_"+i+"_"+j, 
                                                      {width: options.width, 
                                                       height: options.height, 
                                                       posx: j*options.width, 
                                                       posy: i*options.height, 
                                                       animation: animationList});
                                var newTile = $("#tile_"+name+"_"+i+"_"+j);
                                newTile.setAnimation(tileDescription[i][j]-1);
                                newTile.removeClass("active");
                                newTile.addClass("tileType_"+(tileDescription[i][j]-1));
                            }
                        }
            		}	
            	}
            }
            //Get the tileSet offset (relatif to the playground)
            var playgroundOffset = $.gameQuery.playground.offset();
            var tileSetOffset = tileSet.offset();
            tileSetOffset = {top: tileSetOffset.top - playgroundOffset.top, left: tileSetOffset.left - playgroundOffset.left};
            
            //actvates the visible tiles
            var firstRow = Math.max(Math.min(Math.floor(-tileSetOffset.top/options.height), options.sizey), 0);
            var lastRow = Math.max(Math.min(Math.ceil(($.gameQuery.playground[0].height-tileSetOffset.top)/options.height), options.sizey), 0);
            var firstColumn = Math.max(Math.min(Math.floor(-tileSetOffset.left/options.width), options.sizex), 0);
            var lastColumn = Math.max(Math.min(Math.ceil(($.gameQuery.playground[0].width-tileSetOffset.left)/options.width), options.sizex), 0);
            
            tileSet[0].gameQuery.firstRow = firstRow;
            tileSet[0].gameQuery.lastRow = lastRow;
            tileSet[0].gameQuery.firstColumn = firstColumn;
            tileSet[0].gameQuery.lastColumn = lastColumn;
            
            for(var i = firstRow; i < lastRow; i++){
                for(var j = firstColumn; j < lastColumn ; j++) {
                    $("#tile_"+name+"_"+i+"_"+j).toggleClass("active");
                }
            }
            return this.pushStack(tileSet);
        },
        
        /**
        * Changes the animation associated with a sprite.
        * WARNING: no check are made to ensure that the object is really a sprite
        * This is a non-desrtuctive call
        **/
        setAnimation: function(animation, callback) {
            var gameQuery = this[0].gameQuery;
            if(typeof animation == "number"){
                if(gameQuery.animation.type & $.gameQuery.ANIMATION_MULTI){
                    var distance = gameQuery.animation.distance * animation;
                    gameQuery.multi = distance;
                    if(gameQuery.animation.type & $.gameQuery.ANIMATION_VERTICAL) {
                       gameQuery.currentFrame = 0;
                        this.css("background-position",""+(-distance-gameQuery.animation.offsetx)+"px "+(-gameQuery.animation.offsety)+"px");
                    } else if(gameQuery.animation.type & $.gameQuery.ANIMATION_HORIZONTAL) {
                        gameQuery.currentFrame = 0;
                        this.css("background-position",""+(-gameQuery.animation.offsetx)+"px "+(-distance-gameQuery.animation.offsety)+"px");
                    }
                }
            } else {
                if(animation){
                    gameQuery.animation = animation;
                    gameQuery.currentFrame = 0;
                    this.css({"background-image": "url("+animation.imageURL+")", "background-position": ""+(-animation.offsetx)+"px "+(-animation.offsety)+"px"});
                    
                    if(gameQuery.animation.type & $.gameQuery.ANIMATION_VERTICAL) {
                        this.css("background-repeat", "repeat-x");
                    } else if(gameQuery.animation.type & $.gameQuery.ANIMATION_HORIZONTAL) {
                        this.css("background-repeat", "repeat-y");
                    } else {
                        this.css("background-repeat", "no-repeat");
                    }
                } else {
                    this.css("background-image", "");
                }
            }
            
            if(callback != undefined){
                this[0].gameQuery.callback = callback;	
            }
            
            return this;
        },
        
        /**
        * This function add the sound to the resourceManger for later use and associate it to the selected dom element(s).
        * This is a non-desrtuctive call
        **/
        addSound: function(sound, add) {
            // Does a SoundWrapper exists
            if($.gameQuery.SoundWrapper) {
                var gameQuery = this[0].gameQuery;
                // should we add to existing sounds ?
                if(add) {
                    // we do, have we some sound associated with 'this'?
                    var sounds = gameQuery.sounds;
                    if(sounds) {
                        // yes, we add it
                        sounds.push(sound);
                    } else {
                        // no, we create a new sound array
                        gameQuery.sounds = [sound];
                    }
                } else {
                    // no, we replace all sounds with this one
                    gameQuery.sounds = [sound];
                }
            }
            return this;
        },
        
        /**
        * This function plays the sound(s) associated with the selected dom element(s)
        * This is a non-desrtuctive call
        **/
        playSound: function() {
            $(this).each(function(){
                var gameQuery = this.gameQuery;
                if(gameQuery.sounds) {
                    for(var i = gameQuery.sounds.length-1 ; i >= 0; i --) {
                        gameQuery.sounds[i].play();
                    }
                }
            });
            
            return this;
        },
        
        /**
        * This function stops the sound(s) associated with the selected dom element(s) and rewind them
        * This is a non-desrtuctive call
        **/
        stopSound: function() {
            $(this).each(function(){
                var gameQuery = this.gameQuery;
                if(gameQuery.sounds) {
                    for(var i = gameQuery.sounds.length-1 ; i >= 0; i --) {
                        gameQuery.sounds[i].stop();
                    }
                }
            });
            return this;
        },
        
        /**
        * This function pauses the sound(s) associated with the selected dom element(s)
        * This is a non-desrtuctive call
        **/
        pauseSound: function() {
            $(this).each(function(){
                var gameQuery = this.gameQuery;
                if(gameQuery.sounds) {
                    for(var i = gameQuery.sounds.length-1 ; i >= 0; i --) {
                        gameQuery.sounds[i].pause();
                    }
                }
            });
            return this;
        },
        
        /**
        * this function mute or unmute the selected sound or all the sounds if none is specified
        **/
        muteSound: function(muted) {
            $(this).each(function(){
                var gameQuery = this.gameQuery;
                if(gameQuery.sounds) {
                    for(var i = gameQuery.sounds.length-1 ; i >= 0; i --) {
                        gameQuery.sounds[i].muted(muted);
                    }
                }
            });
            return this;
        },
        
        /**
        * Register a callback to be trigered every "rate"
        * This is a non-desrtuctive call
        **/
        registerCallback: function(fn, rate) {
            $.gameQuery.resourceManager.registerCallback(fn, rate);
            return this;
        },
        
        /**
        * @DEPRECATED: use loadCallback() instead 
        * Set the id of the div to use as a loading bar while the games media are loaded during the preload.
        * If a callback function is given it will be called each time the loading progression changes with 
        * the precentage passed as unique argument.
        * This is a non-desrtuctive call
        **/
        setLoadBar: function(elementId, finalwidth, callback) {
            $.gameQuery.loadbar = {id: elementId, width: finalwidth, callback: callback};
            return this;
        },
        
        /**
         * This function retreive a list of object in collision with the subject:
         * - if 'this' is a sprite or a group, the function will retrieve the list of sprites (not groups) that touch it
         * - if 'this' is the playground, the function will return a list of all pair of collisioning elements. They are represented 
         *    by a jQuery object containing a series of paire. Each paire represents two object colliding.(not yet implemented)
         * For now all abject are considered to be boxes.
         * This IS a desrtuctive call and should be terminated with end() to go back one level up in the chaining
         **/
        collision: function(filter){
            var resultList = [];
            
            //retrieve 'this' offset by looking at the parents
            var itsParent = this[0].parentNode, offsetX = 0, offsetY = 0;
            while (itsParent != $.gameQuery.playground[0]){
                    if(itsParent.gameQuery){
                    offsetX += itsParent.gameQuery.posx;
                    offsetY += itsParent.gameQuery.posy;
                }
                itsParent = itsParent.parentNode;
            }
            
            // retrieve the gameQuery object
            var gameQuery = this[0].gameQuery;
            
            
            // retrieve the playground's absolute position and size information
            var pgdGeom = {top: 0, left: 0, bottom: $.playground().height(), right: $.playground().width()};
            
            // Does 'this' is inside the playground ?
            if( (gameQuery.boundingCircle.y + gameQuery.boundingCircle.radius + offsetY < pgdGeom.top)    || 
                (gameQuery.boundingCircle.x + gameQuery.boundingCircle.radius + offsetX < pgdGeom.left)   || 
                (gameQuery.boundingCircle.y - gameQuery.boundingCircle.radius + offsetY > pgdGeom.bottom) || 
                (gameQuery.boundingCircle.x - gameQuery.boundingCircle.radius + offsetX > pgdGeom.right)){
                return this.pushStack(new $([]));
            }
            
            if(this == $.gameQuery.playground){ 
                //TODO Code the "all against all" collision detection and find a nice way to return a list of pairs of elements
            } else {
                // we must find all the element that touches 'this'
                var elementsToCheck = new Array();
                elementsToCheck.push($.gameQuery.sceengraph.children(filter).get());
                elementsToCheck[0].offsetX = 0;
                elementsToCheck[0].offsetY = 0;
                
                for(var i = 0, len = elementsToCheck.length; i < len; i++) {
                    var subLen = elementsToCheck[i].length;
                    while(subLen--){
                        var elementToCheck = elementsToCheck[i][subLen];
                        // is it a gameQuery generated element?
                        if(elementToCheck.gameQuery){
                            // we don't want to check groups
                            if(!elementToCheck.gameQuery.group && !elementToCheck.gameQuery.tileSet){
                                // does it touches the selection?
                                if(this[0]!=elementToCheck){
                                    // check bounding circle collision
                                    // 1) distance between center:
                                    var distance = Math.sqrt(Math.pow(offsetY + gameQuery.boundingCircle.y - elementsToCheck[i].offsetY - elementToCheck.gameQuery.boundingCircle.y, 2) + Math.pow(offsetX + gameQuery.boundingCircle.x - elementsToCheck[i].offsetX - elementToCheck.gameQuery.boundingCircle.x, 2));
                                    if(distance - gameQuery.boundingCircle.radius - elementToCheck.gameQuery.boundingCircle.radius <= 0){
                                        // check real collision
                                        if($.gameQuery.collide(gameQuery, {x: offsetX, y: offsetY}, elementToCheck.gameQuery, {x: elementsToCheck[i].offsetX, y: elementsToCheck[i].offsetY})) {
                                            // add to the result list if collision detected
                                            resultList.push(elementsToCheck[i][subLen]);
                                        }
                                    }
                                }
                            }
                            // Add the children nodes to the list
                            var eleChildren = $(elementToCheck).children(filter);
                            if(eleChildren.length){
                                elementsToCheck.push(eleChildren.get());
                                elementsToCheck[len].offsetX = elementToCheck.gameQuery.posx + elementsToCheck[i].offsetX;
                                elementsToCheck[len].offsetY = elementToCheck.gameQuery.posy + elementsToCheck[i].offsetY;
                                len++;
                            }
                        }
                    }
                }
                return this.pushStack($(resultList));
            }
        },
        
        /**
         * This is an internal function doing the combine action of rotate and scale
         * Both argument are mandatory. To get the values back use .rotate() or 
         * .scale()
         **/
        transform: function(angle, factor) {
            var gameQuery = this[0].gameQuery;
            // Mark transformed and compute bounding box
            $.gameQuery.update(gameQuery,{angle: angle, factor: factor});
            
            if(this.css("MozTransform")) {
                // For firefox from 3.5
                var transform = "rotate("+angle+"deg) scale("+factor+")";
                this.css("MozTransform",transform);
            } else if(this.css("WebkitTransform")!==null && this.css("WebkitTransform")!==undefined) {
                // For safari from 3.1 (and chrome)
                var transform = "rotate("+angle+"deg) scale("+factor+")";
                this.css("WebkitTransform",transform);
            } else if(this.css("filter")!==undefined){
                var angle_rad = Math.PI * 2 / 360 * angle;
                // For ie from 5.5
                var cos = Math.cos(angle_rad) * factor;
                var sin = Math.sin(angle_rad) * factor;
                var previousWidth = this.width();
                var previousHeight = this.height();
                this.css("filter","progid:DXImageTransform.Microsoft.Matrix(M11="+cos+",M12="+(-sin)+",M21="+sin+",M22="+cos+",SizingMethod='auto expand',FilterType='nearest neighbor')");
                var newWidth = this.width();
                var newHeight = this.height();
                this.css("left", ""+(gameQuery.posx-(newWidth-previousWidth)/2)+"px");
                this.css("top", ""+(gameQuery.posy-(newHeight-previousHeight)/2)+"px");
            }
            return this;
        },
        
        /**
         * This function rotates the selected element(s) clock-wise. The argument is a degree.
         **/
        rotate: function(angle){
            var gameQuery = this[0].gameQuery;
            
            if(angle !== undefined) {
                return this.transform(angle % 360, this.scale());
            } else {
                var ang = gameQuery.angle;
                return ang ? ang : 0;
            }
        },
        
        /**
         * This function change the scale of the selected element(s). The passed argument is a ratio: 
         * 1.0 = original size
         * 0.5 = half the original size
         * 2.0 = twice the original size
         **/
        scale: function(factor){
            var gameQuery = this[0].gameQuery;
            
            if(factor !== undefined) {
                return this.transform(this.rotate(), factor);
            } else {
                var fac = gameQuery.factor;
                return fac ? fac : 1;
            }
        }
	});
    
    
    // cssHooks to track changes to sprites
	$.cssHooks["left"] = {
		set: function(elem, value) {
			$.gameQuery.update(elem, {left: value});
			return value;
		}
	}
	
	$.cssHooks["top"] = {
		set: function(elem, value) {
			$.gameQuery.update(elem, {top: value});
			return value;
		}
	}
	
	$.cssHooks["width"] = {
		set: function(elem, value) {
			$.gameQuery.update(elem, {width: value});
			return value;
		}
	}
	
	$.cssHooks["height"] = {
		set: function(elem, value) {
			$.gameQuery.update(elem, {height: value});
			return value;
		}
	}
})(jQuery);