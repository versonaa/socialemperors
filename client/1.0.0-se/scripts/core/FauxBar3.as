package core
{
   import core.isoengine.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.text.*;
   import flash.utils.*;
   import utils.TextFieldUtil;
   
   public class FauxBar3 extends FauxBarMC
   {
      
      private var strText:String;
      
      private var barTimer:Timer;
      
      private var percent:Number = 0;
      
      private var eElement:IsoElement;
      
      private var uiTime:uint;
      
      private var type:int = 1;
      
      private var callback:Function = null;
      
      private var step:Number;
      
      private var startTime:uint;
      
      public var suffix:String = "";
      
      public function FauxBar3(param1:IsoElement, param2:String, param3:uint, param4:Number, param5:Number, param6:int, param7:Function, param8:uint = 0)
      {
         super();
         this.x = param4;
         this.y = param5;
         this.type = param6;
         this.callback = param7;
         this.eElement = param1;
         this.strText = param2;
         this.uiTime = param3;
         this.barTimer = new Timer(50);
         percentMask.scaleX = Math.min(this.percent,1);
         TextFieldUtil.setHTML(percentText,Math.min(int(this.percent * 100),100) + "%");
         this.barTimer.start();
         this.barTimer.addEventListener(TimerEvent.TIMER,this.update);
         this.startTime = param8;
         if(this.startTime == 0)
         {
            this.startTime = Base.Main.lastServerTimestamp + getTimer() / 1000;
         }
         if(this.type == 2)
         {
            barBack.visible = false;
            percentMask.scaleX = 0;
            percentText.filters = new Array(new GlowFilter(16777215,1,3,3,50,3));
         }
         if(Base.Main.tutorialMode)
         {
            param3 /= 3;
         }
      }
      
      public function update(... rest) : *
      {
         var _loc2_:Number = Base.Main.lastServerTimestamp + getTimer() / 1000 - this.startTime;
         this.percent = _loc2_ / this.uiTime;
         if(this.type != 2)
         {
            percentMask.scaleX = Math.min(this.percent,1);
         }
         TextFieldUtil.setHTML(percentText,Math.min(int(this.percent * 100),100) + "%" + this.suffix);
         if(this.eElement is IsoInteractiveElement && Base.Main.selectedItem == this.eElement.buildingReference)
         {
            Base.Gui.recuadroInfo.refreshLoadBar(this.percent,this.uiTime - _loc2_);
         }
         if(this.percent >= 1)
         {
            this.eElement.fauxBar = null;
            this.destroy();
            if(this.callback != null)
            {
               this.callback();
               this.callback = null;
            }
         }
      }
      
      public function destroy() : *
      {
         this.barTimer.stop();
         this.barTimer.removeEventListener(TimerEvent.TIMER,this.update);
         parent.removeChild(this);
      }
      
      public function reposition(param1:Number, param2:Number, param3:Number) : *
      {
         x = param1;
         y = param2;
      }
   }
}

