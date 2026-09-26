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

