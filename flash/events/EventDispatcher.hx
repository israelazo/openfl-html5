package flash.events;


import flash.events.EventPhase;
import flash.events.IEventDispatcher;


@:access(flash.events.Event)
class EventDispatcher implements IEventDispatcher {
	
	
	private var __targetDispatcher:IEventDispatcher;
	private var __eventMap:Map<String, Array<Listener>>;
	
	
	public function new (target:IEventDispatcher = null):Void {
		
		if (target != null) {
			
			__targetDispatcher = target;
			
		}
		
	}
	
	
	public function addEventListener <T:Event>(type:String, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		
		if (__eventMap == null) {
			
			__eventMap = new Map<String, Array<Listener>> ();
			
		}
		
		if (!__eventMap.exists (type)) {
			
			var list = new Array<Listener> ();
			list.push (new Listener (listener, useCapture, priority));
			__eventMap.set (type, list);
			
		} else {
			
			var list = __eventMap.get (type);
			list.push (new Listener (listener, useCapture, priority));
			list.sort (__sortByPriority);
			
		}
		
	}
	
	
	public function dispatchEvent (event:Event):Bool {
		
		if (__eventMap == null || event == null) return false;
		
		var list = __eventMap.get (event.type);
		
		if (list == null) return false;
		
		if (event.target == null) {
			
			if (__targetDispatcher != null) {
				
				event.target = __targetDispatcher;
				
			} else {
				
				event.target = this;
				
			}
			
		}
		
		var capture = (event.eventPhase == EventPhase.CAPTURING_PHASE);
		var index = 0;
		var listener;
		
		while (index < list.length) {
			
			listener = list[index];
			
			if (listener.useCapture == capture) {
				
				listener.callback (event);
				
				if (event.__isCancelledNow) {
					
					return true;
					
				}
				
			}
			
			if (listener == list[index]) {
				
				index++;
				
			}
			
		}
		
		return true;
		
	}
	
	
	public function hasEventListener (type:String):Bool {
		
		if (__eventMap == null) return false;
		return __eventMap.exists (type);
		
	}
	
	
	public function removeEventListener <T:Event>(type:String, listener:T->Void, capture:Bool = false):Void {
		
		if (__eventMap == null) return;
		
		var list = __eventMap.get (type);
		
		if (list == null) return;
		
		for (i in 0...list.length) {
			
			if (list[i].match (listener, capture)) {
				
				list.splice (i, 1);
				break;
				
			}
			
		}
		
		if (list.length == 0) {
			
			__eventMap.remove (type);
			
		}
		
		if (!__eventMap.iterator ().hasNext ()) {
			
			__eventMap = null;
			
		}
		
	}
	
	
	public function toString ():String { 
		
		return untyped "[ " +  this.__name__ + " ]";
		
	}
	
	
	public function willTrigger (type:String):Bool {
		
		return hasEventListener (type);
		
	}
	
	
	private static function __sortByPriority (l1:Listener, l2:Listener):Int {
		
		return l1.priority == l2.priority ? 0 : (l1.priority > l2.priority ? -1 : 1);
		
	}
	
	
}


private class Listener {
	
	
	public var callback:Dynamic->Void;
	public var priority:Int;
	public var useCapture:Bool;
	
	
	public function new <T:Event>(callback:T->Void, useCapture:Bool, priority:Int) {
		
		this.callback = callback;
		this.useCapture = useCapture;
		this.priority = priority;
		
	}
	
	
	public function match <T:Event>(callback:T->Void, useCapture:Bool) {
		
		return (this.callback == callback && this.useCapture == useCapture);
		
	}
	
	
}