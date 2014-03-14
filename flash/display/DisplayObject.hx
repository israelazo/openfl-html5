package flash.display;


import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;


@:access(flash.display.Stage)
class DisplayObject extends EventDispatcher implements IBitmapDrawable {
	
	
	public var alpha:Float;
	public var blendMode:BlendMode;
	public var cacheAsBitmap:Bool;
	public var filters (get, set):Array<BitmapFilter>;
	public var height (get, set):Float;
	public var loaderInfo:LoaderInfo;
	public var mask:DisplayObject;
	public var mouseX (get, null):Float;
	public var mouseY (get, null):Float;
	public var name:String;
	public var parent (default, null):DisplayObjectContainer;
	public var rotation:Float;
	public var scale9Grid:Rectangle;
	public var scaleX:Float;
	public var scaleY:Float;
	public var scrollRect:Rectangle;
	public var stage (default, null):Stage;
	public var transform (get, set):Transform;
	public var visible:Bool;
	public var width (get, set):Float;
	public var x:Float;
	public var y:Float;
	
	public var __worldTransform:Matrix;
	
	private var __filters:Array<BitmapFilter>;
	private var __interactive:Bool;
	private var __renderable:Bool;
	private var __rotationCache:Float;
	private var __rotationCosine:Float;
	private var __rotationSine:Float;
	private var __worldAlpha:Float;
	
	
	public function new () {
		
		super ();
		
		alpha = 1;
		rotation = 0;
		scaleX = 1;
		scaleY = 1;
		visible = true;
		x = 0;
		y = 0;
		
		__worldAlpha = 1;
		__worldTransform = new Matrix ();
		
	}
	
	
	public function getBounds (targetCoordinateSpace:DisplayObject):Rectangle {
		
		/*if (_matrixInvalid || _matrixChainInvalid) __validateMatrix ();
		if (_boundsInvalid) validateBounds ();
		
		var m = __getFullMatrix ();
		
		// perhaps inverse should be stored and updated lazily?
		if (targetCoordinateSpace != null) {
			
			// will be null when target space is stage and this is not on stage
			m.concat(targetCoordinateSpace.__getFullMatrix ().invert ());
			
		}
		
		var rect = __boundsRect.transform (m);	// transform does cloning
		return rect;*/
		return null;
		
	}
	
	
	public function getRect (targetCoordinateSpace:DisplayObject):Rectangle {
		
		// should not account for stroke widths, but is that possible?
		return getBounds (targetCoordinateSpace);
		
	}
	
	
	public function globalToLocal (pos:Point):Point {
		
		return __worldTransform.clone ().invert ().transformPoint (pos);
		
	}
	
	
	public function hitTestObject (obj:DisplayObject):Bool {
		
		/*if (obj != null && obj.parent != null && parent != null) {
			
			var currentBounds = getBounds (this);
			var targetBounds = obj.getBounds (this);
			
			return currentBounds.intersects (targetBounds);
			
		}*/
		
		return false;
		
	}
	
	
	public function hitTestPoint (x:Float, y:Float, shapeFlag:Bool = false):Bool {
		
		/*var boundingBox = (shapeFlag == null ? true : !shapeFlag);
		
		if (!boundingBox) {
			
			return __getObjectUnderPoint (new Point (x, y)) != null;
			
		} else {
			
			var gfx = __getGraphics ();
			
			if (gfx != null) {
				
				var extX = gfx.__extent.x;
				var extY = gfx.__extent.y;
				var local = globalToLocal (new Point (x, y));
				
				if (local.x - extX < 0 || local.y - extY < 0 || (local.x - extX) * scaleX > width || (local.y - extY) * scaleY > height) {
					
					return false;
					
				} else {
					
					return true;
					
				}
				
			}
			
			return false;
			
		}*/
		
		return false;
		
	}
	
	
	public function localToGlobal (point:Point):Point {
		
		return __worldTransform.transformPoint (point);
		//if (_matrixInvalid || _matrixChainInvalid) __validateMatrix ();
		//return __getFullMatrix ().transformPoint (point);
		
	}
	
	
	private function __broadcast (event:Event):Void {
		
		if (__eventMap != null && hasEventListener (event.type)) {
			
			if (event.target == null) {
				
				event.target = this;
				
			}
			
			event.currentTarget = this;
			dispatchEvent (event);
			
		}
		
	}
	
	
	private function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		
		
	}
	
	
	private function __getLocalBounds (rect:Rectangle):Void {
		
		
		
	}
	
	
	private function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool):Bool {
		
		return false;
		
	}
	
	
	public function __renderCanvas (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	public function __renderWebGL (renderSession:RenderSession):Void {
		
		
		
	}
	
	
	private function __setStageReference (stage:Stage):Void {
		
		if (this.stage != stage) {
			
			this.stage = stage;
			
			if (stage != null) {
				
				var evt = new Event (Event.ADDED_TO_STAGE, false, false);
				dispatchEvent (evt);
				
			}
			
		}
		
	}
	
	
	public function __update ():Void {
		
		__renderable = (visible && alpha > 0 && scaleX != 0 && scaleY != 0);
		if (!__renderable) return;
		
		if (rotation != __rotationCache) {
			
			__rotationCache = rotation;
			var radians = rotation * (Math.PI / 180);
			__rotationSine = Math.sin (radians);
			__rotationCosine = Math.cos (radians);
			
		}
		
		if (parent != null) {
			
			var parentTransform = parent.__worldTransform;
			var worldTransform = __worldTransform;
			
			//var px = 0;
			//var py = 0;
			
			var a00 = __rotationCosine * scaleX,
			a01 = __rotationSine * scaleX,
			a10 = -__rotationSine * scaleY,
			a11 = __rotationCosine * scaleY,
			//a02 = x - a00 * px - py * a01,
			//a12 = y - a11 * py - px * a10,
			a02 = x,
			a12 = y,
			b00 = parentTransform.a, b01 = parentTransform.b,
			b10 = parentTransform.c, b11 = parentTransform.d;
			
			worldTransform.a = a00 * b00 + a01 * b10;
			worldTransform.b = a00 * b01 + a01 * b11;
			worldTransform.c = a10 * b00 + a11 * b10;
			worldTransform.d = a10 * b01 + a11 * b11;
			worldTransform.tx = a02 * b00 + a12 * b10 + parentTransform.tx;
			worldTransform.ty = a02 * b01 + a12 * b11 + parentTransform.ty;
			
			__worldAlpha = alpha * parent.__worldAlpha;
			
		} else {
			
			__worldTransform.a = __rotationCosine * scaleX;
			__worldTransform.c = -__rotationSine * scaleY;
			__worldTransform.tx = x;
			__worldTransform.b = __rotationSine * scaleX;
			__worldTransform.d = __rotationCosine * scaleY;
			__worldTransform.ty = y;
			
			__worldAlpha = alpha;
			
		}
		
	}
	
	
	public function __updateChildren ():Void {
		
		
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_filters ():Array<BitmapFilter> {
		
		if (__filters == null) {
			
			return new Array ();
			
		} else {
			
			return __filters.copy ();
			
		}
		
	}
	
	
	private function set_filters (value:Array<BitmapFilter>):Array<BitmapFilter> {
		
		// set
		
		return value;
		
	}
	
	
	private function get_height ():Float {
		
		return 0;
		
	}
	
	
	private function set_height (value:Float):Float {
		
		return 0;
		
	}
	
	
	private function get_mouseX ():Float {
		
		return globalToLocal (new Point (stage.__mouseX, 0)).x;
		
	}
	
	
	private function get_mouseY ():Float {
		
		return globalToLocal (new Point (0, stage.__mouseY)).y;
		
	}
	
	
	private function get_transform ():Transform {
		
		return new Transform (this);
		
	}
	
	
	private function set_transform (value:Transform):Transform {
		
		return value;
		
	}
	
	
	private function get_width ():Float {
		
		return 0;
		
	}
	
	
	private function set_width (value:Float):Float {
		
		return 0;
		
	}
	
	
}