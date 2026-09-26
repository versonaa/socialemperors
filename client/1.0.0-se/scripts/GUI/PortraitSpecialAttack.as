package GUI
{
   import caurina.transitions.*;
   import core.*;
   import core.isoengine.*;
   import core.statics.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.net.*;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import managers.ImageManager;
   import managers.images.ImageManagerResource;
   import utils.TextFieldUtil;
   
   public class PortraitSpecialAttack extends Portrait
   {
      
      protected var counterMc:*;
      
      public var castingMask:*;
      
      protected var numAttacks:int;
      
      protected var tTimer:Timer;
      
      protected var oAttack:SpecialUnitAttack;
      
      protected var bEnabled:Boolean;
      
      // Overlays: the keyboard shortcut (bottom left) and the seconds left until the skill is ready
      protected var keyLabel:TextField;
      
      protected var cooldownLabel:TextField;
      
      protected var labelTimer:Timer;
      
      public function PortraitSpecialAttack(param1:SpecialUnitAttack, param2:IsoSpecialUnit, param3:PortraitMC = null)
      {
         super();
         this.eElement = param2;
         this.oAttack = param1;
         this.counterMc = this.portraitMC.addChild(new GiftCounter());
         if(this.oAttack.numAttacks == -1)
         {
            this.counterMc.visible = false;
         }
         this.counterMc.x = 43;
         this.counterMc.y = 0;
         this.castingMask = this.portraitMC.addChild(new PortraitCastingMaskMC());
         this.castingMask.x = 0;
         this.castingMask.y = 45;
         this.castingMask.scaleY = 0;
         this.castingMask.alpha = 0.9;
         this.numAttacks = this.oAttack.numAttacks;
         this.bEnabled = true;
         this.keyLabel = this.portraitMC.addChild(this.makeLabel(13)) as TextField;
         this.cooldownLabel = this.portraitMC.addChild(this.makeLabel(18)) as TextField;
         this.cooldownLabel.visible = false;
         this.labelTimer = new Timer(250);
         this.labelTimer.addEventListener(TimerEvent.TIMER,this.updateCooldownLabel);
         addEventListener(Event.ADDED_TO_STAGE,this.onLabelsAdded);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onLabelsRemoved);
         this.updateAttacks();
         if(this.eElement is IsoSpecialUnit && IsoSpecialUnit(this.eElement).spState != IsoSpecialUnit.SU_STATE_IDLE)
         {
            switch(IsoSpecialUnit(this.eElement).spState)
            {
               case IsoSpecialUnit.SU_STATE_CASTING:
                  this.setStateCasting();
                  break;
               case IsoSpecialUnit.SU_STATE_COOLDOWN:
                  this.setStateCooldown();
            }
         }
      }
      
      override public function clickItem(param1:MouseEvent) : void
      {
         if(IsoSpecialUnit(this.eElement).spState == IsoSpecialUnit.SU_STATE_IDLE || this.oAttack.id == 4)
         {
            if(this.oAttack.numAttacks == -1 || this.oAttack.numAttacks > 0)
            {
               if(IsoSpecialUnit(this.eElement).doAttack(this.oAttack.id))
               {
                  Base.Gui.recuadroInfo.castSpecialAttacks(this.oAttack.castTime,this.oAttack.coolDown);
                  this.updateAttacks();
                  Base.Main.ps.addParticle(new NumberParticle(this.eElement.x * Base.Main.currentZoom + this.eElement.parent.x,this.eElement.y * Base.Main.currentZoom + this.eElement.parent.y,[this.oAttack.attackName],[Constants.TEXT_BLACK],1,this.oAttack.castTime * 30));
               }
               else
               {
                  Base.Main.ps.addParticle(new NumberParticle(this.eElement.x * Base.Main.currentZoom + this.eElement.parent.x,this.eElement.y * Base.Main.currentZoom + this.eElement.parent.y,[this.oAttack.cantMessage],[Constants.TEXT_RED]));
               }
            }
            return;
         }
         Base.Main.ps.addParticle(new NumberParticle(this.eElement.x * Base.Main.currentZoom + this.eElement.parent.x,this.eElement.y * Base.Main.currentZoom + this.eElement.parent.y,[Language.getLiteral(Language.AUX_NO_ESTA_LISTO)],[Constants.TEXT_RED]));
      }
      
      override public function GetElement() : IsoInteractiveElement
      {
         return this.eElement;
      }
      
      private function makeLabel(param1:int) : TextField
      {
         var _loc2_:TextField = new TextField();
         _loc2_.defaultTextFormat = new TextFormat("Arial",param1,16777215,true);
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.selectable = false;
         _loc2_.mouseEnabled = false;
         _loc2_.filters = [new GlowFilter(0,1,3,3,6)];
         return _loc2_;
      }
      
      private function frameWidth() : Number
      {
         return this.portraitMC.marco != null ? Number(this.portraitMC.marco.width) : 52;
      }
      
      private function frameHeight() : Number
      {
         return this.portraitMC.marco != null ? Number(this.portraitMC.marco.height) : 52;
      }
      
      public function setKeyLabel(param1:String) : void
      {
         this.keyLabel.text = param1;
         this.keyLabel.x = 1;
         this.keyLabel.y = this.frameHeight() - this.keyLabel.height;
      }
      
      private function onLabelsAdded(param1:Event) : void
      {
         this.labelTimer.start();
         this.updateCooldownLabel();
      }
      
      private function onLabelsRemoved(param1:Event) : void
      {
         this.labelTimer.stop();
      }
      
      // Seconds until the unit can use a skill again: casting time left plus the cooldown, or the cooldown left
      private function updateCooldownLabel(param1:TimerEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IsoSpecialUnit = this.eElement as IsoSpecialUnit;
         if(_loc3_ != null && !(this is PortraitLimitAttack))
         {
            if(_loc3_.spState == IsoSpecialUnit.SU_STATE_CASTING && _loc3_.spActAttack != null)
            {
               _loc2_ = _loc3_.spTimer + int(_loc3_.spActAttack.coolDown);
            }
            else if(_loc3_.spState == IsoSpecialUnit.SU_STATE_COOLDOWN)
            {
               _loc2_ = _loc3_.spTimer;
            }
         }
         this.cooldownLabel.visible = _loc2_ > 0;
         if(_loc2_ > 0)
         {
            this.cooldownLabel.text = _loc2_ >= 60 ? int(_loc2_ / 60) + ":" + (_loc2_ % 60 < 10 ? "0" : "") + _loc2_ % 60 : String(_loc2_);
            this.cooldownLabel.x = (this.frameWidth() - this.cooldownLabel.width) / 2;
            this.cooldownLabel.y = (this.frameHeight() - this.cooldownLabel.height) / 2;
         }
      }
      
      public function startCastingMask(param1:int, param2:int) : void
      {
         if(Tweener.getTweenCount(this.castingMask) > 0)
         {
            Tweener.removeTweens(this.castingMask);
         }
         Tweener.addTween(this.castingMask,{
            "scaleY":1,
            "time":param1,
            "transition":"linear",
            "onComplete":this.startCoolDown,
            "onCompleteParams":[param2]
         });
      }
      
      private function startCoolDown(param1:int) : void
      {
         if(Tweener.getTweenCount(this.castingMask) > 0)
         {
            Tweener.removeTweens(this.castingMask);
         }
         Tweener.addTween(this.castingMask,{
            "scaleY":0,
            "time":param1,
            "transition":"linear",
            "onComplete":this.setStateIdle
         });
      }
      
      public function updateState() : void
      {
         if(this.eElement is IsoSpecialUnit && IsoSpecialUnit(this.eElement).spState != IsoSpecialUnit.SU_STATE_IDLE)
         {
            switch(IsoSpecialUnit(this.eElement).spState)
            {
               case IsoSpecialUnit.SU_STATE_CASTING:
                  this.setStateCasting();
                  break;
               case IsoSpecialUnit.SU_STATE_COOLDOWN:
                  this.setStateCooldown();
            }
         }
      }
      
      private function setStateCasting() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:int = IsoSpecialUnit(this.eElement).spTimer;
         var _loc2_:Object = IsoSpecialUnit(this.eElement).spActAttack;
         _loc3_ = _loc1_ / _loc2_.castTime;
         this.castingMask.scaleY = _loc3_;
         if(Tweener.getTweenCount(this.castingMask) > 0)
         {
            Tweener.removeTweens(this.castingMask);
         }
         Tweener.addTween(this.castingMask,{
            "scaleY":0,
            "time":_loc1_,
            "transition":"linear",
            "onComplete":this.startCoolDown,
            "onCompleteParams":[_loc2_.coolDown]
         });
      }
      
      private function setStateCooldown() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:int = IsoSpecialUnit(this.eElement).spTimer;
         var _loc2_:Object = IsoSpecialUnit(this.eElement).spActAttack;
         _loc3_ = _loc1_ / _loc2_.coolDown;
         this.castingMask.scaleY = _loc3_;
         if(Tweener.getTweenCount(this.castingMask) > 0)
         {
            Tweener.removeTweens(this.castingMask);
         }
         Tweener.addTween(this.castingMask,{
            "scaleY":0,
            "time":_loc1_,
            "transition":"linear",
            "onComplete":this.setStateIdle
         });
      }
      
      private function setStateIdle() : void
      {
         if(Tweener.getTweenCount(this.castingMask) > 0)
         {
            Tweener.removeTweens(this.castingMask);
         }
         this.castingMask.scaleY = 0;
      }
      
      private function updateAttacks() : void
      {
         this.oAttack = IsoSpecialUnit(this.eElement).getAttack(this.oAttack.id);
         if(this.oAttack.numAttacks != -1)
         {
            TextFieldUtil.setHTML(this.counterMc.count,this.oAttack.numAttacks);
         }
         else
         {
            TextFieldUtil.setHTML(this.counterMc.count,"u");
         }
      }
      
      override public function UpdateImage() : void
      {
         if(this.portraitMC.image.numChildren <= 0)
         {
            if(this.eElement != null && this.eElement.buildingReference != null)
            {
               this.loadImage(this.oAttack.imgThumb);
            }
         }
      }
      
      override public function loadImage(param1:String) : void
      {
         this.portraitMC.image.addChild(ImageManager.instance.getThumbImage(param1 + ".jpg").getBitmap(52,52,1,ImageManagerResource.ONLY_ADJUST_SIZE));
      }
   }
}

