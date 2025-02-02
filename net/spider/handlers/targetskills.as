package net.spider.handlers{
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	import flash.utils.*;
    import net.spider.main;
    import net.spider.modules.*;
    import net.spider.handlers.ClientEvent;
	import net.spider.handlers.SFSEvent;
	import fl.motion.Color;
	import flash.geom.*;
	import net.spider.draw.ToolTipMC;
	import flash.text.*;
	import net.spider.handlers.optionHandler;
	
	public class targetskills extends MovieClip {
		
        public static var events:EventDispatcher = new EventDispatcher();
        private static var skillTimer:Timer;

		public function targetskills() {
			this.visible = false;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onHold, false);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseRelease, false);
            targetskills.events.addEventListener(ClientEvent.onToggle, onToggle);
		}

		public var toolTip:ToolTipMC;
        public function onToggle(e:Event):void{
			if(toolTip == null){
				toolTip = new ToolTipMC();
				main._stage.addChild(toolTip);
			}
            this.visible = optionHandler.skill;
            if(optionHandler.skill){
				if(main.Game.ui){
					for(var i:* = 2; i < 6; i++){
						main.Game.ui.mcInterface.actBar.getChildByName("i" + i).addEventListener(MouseEvent.CLICK, actIconClick, false, 0, true);
					}
				}
				stage.addEventListener(KeyboardEvent.KEY_UP, key_actBar);
				main.Game.sfc.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler);
				auras = new Object();
			}else{
				stage.removeEventListener(KeyboardEvent.KEY_UP, key_actBar);
				main.Game.sfc.removeEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler);
				for(var j:* = 2; j < 6; j++){
					main.Game.ui.mcInterface.actBar.getChildByName("i" + j).removeEventListener(MouseEvent.CLICK, actIconClick);
				}
				auras = null;
				toolTip.close();
			}
        }

		public var lastSkill:Object;
		public function actIconClick(e:*):void{
			lastSkill = MovieClip(e.currentTarget).actObj;
		}

		public function key_actBar(param1:KeyboardEvent) : *
		{
			if(stage.focus == null || stage.focus != null && !("text" in stage.focus))
			{
				if(param1.charCode > 49 && param1.charCode < 55)
				{
					switch(param1.charCode){
						case 50:
							lastSkill = main.Game.world.actions.active[1];
							break;
						case 51:
							lastSkill = main.Game.world.actions.active[2];
							break;
						case 52:
							lastSkill = main.Game.world.actions.active[3];
							break;
						case 53:
							lastSkill = main.Game.world.actions.active[4];
							break;
					}
				}
			}
		}

		public var icons:Object;
		public var scalar:Number = .6;
		public function createIconMC(auraName:String, auraStacks:Number, isEnemy:Boolean):void{
			if(icons == null)
				icons = new Object();
			if(!icons.hasOwnProperty(auraName)){
				var icon:Class;
				if(!isEnemy){
					if(lastSkill.icon.indexOf(",") > -1){
						icon = main.Game.world.getClass(lastSkill.icon.split(",")[(lastSkill.icon.split(",")).length-1]) as Class;
					}else{
						icon = main.Game.world.getClass(lastSkill.icon) as Class;
					}
				}else{
					icon = main.Game.world.getClass("isp2") as Class;
				}
				var ico:MovieClip = new icon();
				var skillIcon:Class = main.gameDomain.getDefinition("ib2") as Class;
				var base:MovieClip = new skillIcon();

				icons[auraName] = this.addChild(base);
				icons[auraName].auraName = auraName;
				icons[auraName].width = 42;
				icons[auraName].height = 39;
				icons[auraName].icon2 = null;
				icons[auraName].cnt.removeChildAt(0);
				icons[auraName].scaleX = scalar;
				icons[auraName].scaleY = scalar;
				icons[auraName].tQty.visible = false;
				var visual:MovieClip = icons[auraName].cnt.addChild(ico);
				if (visual.width > visual.height)
				{
					visual.scaleX = visual.scaleY = 34 / visual.width;
				}
				else
				{
					visual.scaleX = visual.scaleY = 31 / visual.height;
				}
				visual.x = ((icons[auraName].bg.width / 2) - (visual.width / 2));
                visual.y = ((icons[auraName].bg.height / 2) - (visual.height / 2));
				icons[auraName].mouseChildren = false;
				icons[auraName].addEventListener(MouseEvent.MOUSE_OVER, onOver, false, 0, true);
				icons[auraName].addEventListener(MouseEvent.MOUSE_OUT, onOut, false, 0, true);
			}
			icons[auraName].auraStacks = auraStacks;
		}

		public function onOver(e:MouseEvent):void{
			toolTip.openWith({str:e.target.auraName + " (" + e.target.auraStacks + ")"});
		}

		public function onOut(e:MouseEvent){
            toolTip.close();
        }

		public function rearrangeIconMC():void{
			var a:Array = new Array();
			for each(var s:* in icons)
			{
				trace(s.auraName);
				a.push(s);
			}

			a.reverse();

			var nextRow:Number = 0;
			var rowCtr:Number = 0;
			for (var i:int = 0; i < (a.length); i++)
			{
				if((i != 0) && (i % 8 == 0)){ //after the 8th item, next row
					nextRow += (28);
					rowCtr++;
				}
				a[i].x = ((32)*(i-(8*rowCtr))) + 3;
				a[i].y = nextRow;
			}
			a = null;
		}

		public function clearMCs():void{
			while(this.numChildren > 0){
				this.removeChildAt(0);
			}
			icons = new Object();
		}

		public var auras:Object;
		public var dateObj:Date;
		public function onExtensionResponseHandler(e:*):void{
			var aura:*;
            var protocol:* = e.params.type;
            if (protocol == "json")
                {
                    var resObj:* = e.params.dataObj;
                    var cmd:* = resObj.cmd;
                    switch (cmd)
                    {
                        case "ct":
							if (resObj.a == null)
								return;
							for each(var i:* in resObj.a){
								if(main.Game.world.myAvatar.target)
									if(main.Game.world.myAvatar.target.dataLeaf.MonID)
										if(i.tInf != "m:" + main.Game.world.myAvatar.target.dataLeaf.MonMapID.toString())
											continue;
								if(i.auras){
									for each(var j:* in i.auras){
										if (i.cmd.indexOf("+") > -1)
										{
											if(!auras.hasOwnProperty(j.nam)){
												auras[j.nam] = 1;
												createIconMC(j.nam, 1, (i.cInf.substring(2) != main.Game.sfc.myUserId));
												coolDownAct(icons[j.nam], j.dur * 1000, new Date().getTime());
											}else{
												auras[j.nam] += 1;
												if(!main.Game.world.myAvatar.target){
													auras = new Object();
													clearMCs();
												}
												for each(var a:* in main.Game.world.myAvatar.target.dataLeaf.auras){
													if(a.nam == j.nam){
														a.ts = j.ts;
														createIconMC(j.nam, auras[j.nam], (i.cInf.substring(2) != main.Game.sfc.myUserId));
														coolDownAct(icons[j.nam], j.dur * 1000, a.ts);
														break;
													}
												}
											}
										}else if(i.cmd.indexOf("-") > -1) {
											auras[j.nam] = null;
										}
									}
								}else{
									if (i.cmd.indexOf("+") > -1)
									{
										if(!auras.hasOwnProperty(i.aura.nam)){
											auras[i.aura.nam] = 1;
											createIconMC(i.aura.nam, 1, (i.cInf.substring(2) != main.Game.sfc.myUserId));
											coolDownAct(icons[i.aura.nam], i.aura.dur * 1000, new Date().getTime());
										}else{
											auras[i.aura.nam] += 1;
											if(!main.Game.world.myAvatar.target){
												auras = new Object();
												clearMCs();
											}
											for each(var b:* in main.Game.world.myAvatar.target.dataLeaf.auras){
												if(b.nam == i.aura.nam){
													b.ts = i.aura.ts;
													auras[i.aura.nam] = 1;
													createIconMC(i.aura.nam, auras[i.aura.nam], (i.cInf.substring(2) != main.Game.sfc.myUserId));
													coolDownAct(icons[i.aura.nam], i.aura.dur * 1000, b.ts);
													break;
												}
											}
										}
									}else if(i.cmd.indexOf("-") > -1) {
										auras[i.aura.nam] = null;
									}
								}
							}
							lastSkill = main.Game.world.actions.active[0];
                            break;
						case "sAct":
							for(var k:* = 2; k < 6; k++){
								main.Game.ui.mcInterface.actBar.getChildByName("i" + k).addEventListener(MouseEvent.CLICK, actIconClick, false, 0, true);
							}
							break;
                    }
                }
        }

		public function coolDownAct(actIcon:*, cd:int=-1, ts:Number=127){
			var ActMask:Class = main.gameDomain.getDefinition("ActMask") as Class;
			var iconCT:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, -50, -50, -50, 0);
			var icon1:MovieClip;
			var j:int;
			var icon2:*;
			var iMask:MovieClip;
			var bmd:*;
			var bm:*;
			var k:int;
			var iconF:DisplayObject;
			icon1 = actIcon;
			icon2 = null;
			iMask = null;
			if (icon1.icon2 == null)
			{
				bmd = new BitmapData(50, 50, true, 0);
				bmd.draw(icon1, null, iconCT);
				bm = new Bitmap(bmd);
				icon2 = actIcon.addChild(bm);
				icon1.icon2 = icon2;
				icon2.transform = icon1.transform;
				icon2.scaleX = 1;
				icon2.scaleY = 1;
				icon1.ts = ts;
				icon1.cd = cd;
				icon1.auraName = icon1.auraName;
				iMask = (actIcon.addChild(new ActMask()) as MovieClip);
				iMask.scaleX = .33;
				iMask.scaleY = .33;
				iMask.x = int(((icon2.x + (icon2.width / 2)) - (iMask.width / 2)));
				iMask.y = int(((icon2.y + (icon2.height / 2)) - (iMask.height / 2)));
				k = 0;
				while (k < 4)
				{
					iMask[(("e" + k) + "oy")] = iMask[("e" + k)].y;
					k++;
				}
				icon2.mask = iMask;
				var stackQty:TextField = new TextField();
				var tf:TextFormat = new TextFormat();
				tf.size = 12;
				tf.bold = true;
				tf.font = "Arial"
				tf.color = 0xFFFFFF;
				stackQty.defaultTextFormat = tf;
				icon1.stacks = icon1.addChild(stackQty);
				icon1.stacks.x = 32;
				icon1.stacks.y = 27;
			}
			else
			{
				icon2 = icon1.icon2;
				iMask = icon2.mask;
				icon1.ts = ts;
				icon1.cd = cd;
				icon1.auraName = icon1.auraName;
			}
			icon1.stacks.text = icon1.auraStacks;
			iMask.e0.stop();
			iMask.e1.stop();
			iMask.e2.stop();
			iMask.e3.stop();
			icon1.removeEventListener(Event.ENTER_FRAME, countDownAct);
			icon1.addEventListener(Event.ENTER_FRAME, countDownAct, false, 0, true);
			rearrangeIconMC();
        }

		public function countDownAct(e:Event):void{
			if(!main.Game.world.myAvatar.target){
				auras = new Object();
				clearMCs();
				return;
			}
            var dat:*;
            var ti:*;
            var ct1:*;
            var ct2:*;
            var cd:*;
            var tp:*;
            var mc:*;
            var fr:*;
            var i:*;
            var iMask:*;
            dat = new Date();
            ti = dat.getTime();
            ct1 = MovieClip(e.target);
            ct2 = ct1.icon2;
            //cd = Math.round((ct1.cd * (1 - Math.min(Math.max(main.Game.world.myAvatar.dataLeaf.sta.$tha, -1), 0.5))));
            cd = ct1.cd + 350;
			tp = ((ti - ct1.ts) / cd);
            mc = Math.floor((tp * 4));
            fr = (int(((tp * 360) % 90)) + 1);
			if(auras[ct1.auraName] == null){
				tp = 1;
			}
			if (tp < 0.99)
			{
				i = 0;
				while (i < 4)
				{
					if (i < mc)
					{
						ct2.mask[("e" + i)].y = -300;
					}
					else
					{
						ct2.mask[("e" + i)].y = ct2.mask[(("e" + i) + "oy")];
						if (i > mc)
						{
							ct2.mask[("e" + i)].gotoAndStop(0);
						}
					}
					i++;
				}
				MovieClip(ct2.mask[("e" + mc)]).gotoAndStop(fr);
			}
			else
			{
				iMask = ct2.mask;
				ct2.mask = null;
				ct2.parent.removeChild(iMask);
				ct1.removeEventListener(Event.ENTER_FRAME, countDownAct);
				icons[ct1.auraName].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
				icons[ct1.auraName].removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				this.stopDrag();
				toolTip.close();
				ct2.parent.removeChild(ct2);
				ct2.bitmapData.dispose();
				ct1.icon2 = null;
				this.removeChild(icons[ct1.auraName]);
				delete icons[ct1.auraName];
				rearrangeIconMC();
			}
        }
		
		private function onHold(e:MouseEvent):void{
			this.startDrag();
		}
		
		private function onMouseRelease(e:MouseEvent):void{
			this.stopDrag();
		}
	}
	
}
