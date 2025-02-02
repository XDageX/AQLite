package net.spider.modules{
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.text.TextFormat;
    import net.spider.main;
	import net.spider.handlers.ClientEvent;
	import net.spider.handlers.optionHandler;
	
	public class chatfilter extends MovieClip{

		public static var events:EventDispatcher = new EventDispatcher();

		public static function onCreate():void{
			chatfilter.events.addEventListener(ClientEvent.onToggle, onToggle);
		}

		public static function onToggle(e:Event):void{
			if(!optionHandler.chatFilter){
				clog = main.Game.ui.mcInterface.t1;
				for(var i:uint = 0; i < clog.numChildren; i++){
					if(!clog.getChildAt(i).getChildAt(0).ti)
						continue;
					if(!clog.getChildAt(i).getChildAt(0).visible)
						clog.getChildAt(i).getChildAt(0).visible = true;
				}
			}
		}

		private static var clog:*;
		private static var txt:*;
        public static function onFrameUpdate():void{
			if(!optionHandler.chatFilter || !main.Game.sfc.isConnected)
				return;
			//main.Game.ui.mcInterface.t1.visible = false;
			clog = main.Game.ui.mcInterface.t1;
			for(var i:uint = 0; i < clog.numChildren; i++){
				if(!clog.getChildAt(i).getChildAt(0).ti)
					continue;
				txt = clog.getChildAt(i).getChildAt(0).ti.htmlText;
				switch(true){
					case (optionHandler.filterChecks["chkRed"] && txt.indexOf('COLOR="#FF0000"') > -1):
					case (optionHandler.filterChecks["chkBlue"] && txt.indexOf('COLOR="#00FFFF"') > -1):
							if(txt.indexOf("Server shutdown") > -1)
									continue;
							clog.getChildAt(i).getChildAt(0).visible = false;
						break;
				}
			}
		}
	}
	
}
