package GUI
{
   import core.*;
   import core.statics.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import managers.ImageManager;
   import managers.SoundManager;
   import managers.images.ImageManagerResource;
   import utils.TextFieldUtil;
   
   public class GiftButtonLarge extends GiftButtonMC
   {
      
      Security.allowDomain("*");
      
      public var buttons:Array = new Array(0);
      
      private var bmp:Sprite = null;
      
      private var item:StoreObject;
      
      private var group:Array;
      
      private var avatar:Loader = new Loader();
      
      private var itemWindow:*;
      
      private var currentSheet:* = null;
      
      private var mapMain:*;
      
      public var popupWindow:* = null;
      
      public function GiftButtonLarge(param1:*, param2:StoreObject, param3:int = 0, param4:int = 0, param5:int = 0, param6:Array = null)
      {
         super();
         // Every stored object this card stands for (the storage groups them by item id)
         this.group = param6 != null ? param6.concat() : [param2];
         this.itemWindow = param1;
         x = param3;
         y = param4;
         TextFieldUtil.setHTML(counter.count,String(param5));
         TextFieldUtil.setHTML(sell.getChildByName("lbl"),Language.getLiteral(Language.POPUP_STORAGE_SELL));
         TextFieldUtil.setHTML(useButton.getChildByName("lbl"),Language.getLiteral(Language.POPUP_STORAGE_USE));
         this.setItem(param2,param5);
         this.formatSellUseBtns();
      }
      
      public function formatSellUseBtns() : void
      {
         if(this.item == null)
         {
            return;
         }
         if(this.item.staticData.id == Constants.ID_BUILDING_BAHAMUT_HEART)
         {
            sell.visible = false;
            useButton.visible = false;
         }
         else if(this.item.staticData.subcat_functional == Constants.SUBCATFUNC_BUILDING_SPECIAL_COLLECTION)
         {
            sell.visible = false;
            useButton.visible = false;
         }
         else if(this.item.staticData.subcat_functional == Constants.SUBCATFUNC_BUILDING_TOWNHALL)
         {
            sell.visible = false;
            this.enableButton(useButton,this.mouseUsed);
         }
         else
         {
            sell.visible = true;
            useButton.visible = true;
            this.enableButton(sell,this.sellGift);
            this.enableButton(useButton,this.mouseUsed);
         }
      }
      
      private function disableButtons() : *
      {
      }
      
      public function closeWindow(... rest) : *
      {
         this.disableButtons();
         parent.removeChild(this);
      }
      
      private function mouseUsed(... rest) : *
      {
         if(this.item.staticData.race != Base.Player.currentRace && this.item.staticData.race != Constants.FACTION_NEUTRAL && this.item.staticData.race != Constants.FACTION_ALL)
         {
            Base.PopUp.alert(Language.getLiteral(Language.AVISO_REGALO_FACCION));
            return;
         }
         Base.Main.placingStoreObject = this.item;
         Base.Sound.playSfx(SoundManager.SFX_BUTTON_CLICK);
         Base.Main.setBuilding(this.item.staticData);
      }
      
      public function destroy() : *
      {
         holder.removeEventListener(MouseEvent.CLICK,this.mouseUsed);
         this.disableButton(useButton,this.mouseUsed);
         this.disableButton(sell,this.sellGift);
         parent.removeChild(this);
      }
      
      public function setItem(param1:StoreObject, param2:int = 0) : *
      {
         var _loc3_:TextFormat = null;
         if(param1.staticData.name.length > 11)
         {
            _loc3_ = new TextFormat(null,11);
         }
         this.item = param1;
         counter.visible = param2 > 1;
         TextFieldUtil.setHTML(counter.count,String(param2));
         TextFieldUtil.setHTML(itemName,this.item.staticData.name,"",_loc3_);
         this.setImage();
      }
      
      private function setOptions(... rest) : *
      {
         this.itemWindow.setItem(this.item);
         this.itemWindow.setOptions(this);
      }
      
      private function setImage() : *
      {
         if(this.bmp != null)
         {
            holder.removeChild(this.bmp);
            this.bmp = null;
         }
         this.bmp = new Sprite();
         this.bmp.addChild(ImageManager.instance.getThumbImage(this.item.staticData.img_name + ".jpg").getRealSizeBitmap(ImageManagerResource.ONLY_ADJUST_SIZE));
         holder.addChild(this.bmp);
         holder.buttonMode = true;
         holder.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseUsed);
      }
      
      private function sellGiftReally() : void
      {
         this.sellObject(this.item);
      }
      
      private function sellObject(param1:StoreObject) : void
      {
         if(param1.giftId)
         {
            Base.Commands.addCommand({
               "cmd":Constants.CMD_SELL_GIFT,
               "args":[param1.staticData.id,Base.Main.townID]
            });
         }
         else if(param1.iphoneId)
         {
            Base.Commands.addCommand({
               "cmd":Constants.CMD_SELL_IPHONE_ITEM,
               "args":[param1.staticData.id,Base.Main.townID]
            });
         }
         else
         {
            Base.Commands.addCommand({
               "cmd":Constants.CMD_SELL_STORED,
               "args":[param1.staticData.id,Base.Main.townID]
            });
         }
         Base.Main.removeGift(param1);
      }
      
      private function sellsForCash() : Boolean
      {
         return Config.SELL_FOR_ZERO_CASH && this.item.staticData.cost_type == CostType.CASH;
      }
      
      private function sellRefund() : int
      {
         if(this.sellsForCash() || this.item.staticData.id == Constants.ID_BUILDING_ZEPPELIN_TOWER || this.item.staticData.id == Constants.ID_BUILDING_DOCK)
         {
            return 0;
         }
         return Math.floor(this.item.staticData.cost / Config.DIVISOR_SELL);
      }
      
      private function sellAll() : void
      {
         if(this.sellsForCash())
         {
            Base.PopUp.confirm(Language.getLiteral(Language.INFO_CONFIRMAR_VENTA,[0,"cash"]),this.sellAllReally,null);
         }
         else
         {
            this.sellAllReally();
         }
      }
      
      private function sellAllReally() : void
      {
         var _loc1_:StoreObject = null;
         var _loc2_:int = this.sellRefund() * this.group.length;
         if(_loc2_ > 0)
         {
            Base.Player.adjustStatByType(_loc2_,this.item.staticData.cost_type,0);
            Base.Main.ps.addParticle(new NumberParticle(355,450,[_loc2_],[this.item.staticData.cost_type],2));
         }
         for each(_loc1_ in this.group)
         {
            this.sellObject(_loc1_);
         }
      }
      
      private function sellGift(... rest) : *
      {
         if(this.group.length > 1)
         {
            Base.PopUp.confirm("Sell all " + this.group.length + " " + this.item.staticData.name + "?<br>Yes: sell all<br>No: sell only 1",this.sellAll,this.sellOne);
         }
         else
         {
            this.sellOne();
         }
      }
      
      private function sellOne(... rest) : *
      {
         if(Config.SELL_FOR_ZERO_CASH && this.item.staticData.cost_type == CostType.CASH)
         {
            Base.PopUp.confirm(Language.getLiteral(Language.INFO_CONFIRMAR_VENTA,[0,"cash"]),this.sellGiftReally,null);
         }
         else
         {
            if(this.item.staticData.id != Constants.ID_BUILDING_ZEPPELIN_TOWER && this.item.staticData.id != Constants.ID_BUILDING_DOCK)
            {
               Base.Player.adjustStatByType(Math.floor(this.item.staticData.cost / Config.DIVISOR_SELL),this.item.staticData.cost_type,0);
               Base.Main.ps.addParticle(new NumberParticle(355,450,[Math.floor(this.item.staticData.cost / Config.DIVISOR_SELL)],[this.item.staticData.cost_type],2));
            }
            this.sellGiftReally();
         }
      }
      
      private function gotoInvite(... rest) : *
      {
      }
      
      public function closePopup() : *
      {
         if(this.popupWindow != null)
         {
            this.popupWindow.closeWindow();
         }
      }
      
      public function ioErrorHandler(param1:*) : *
      {
      }
      
      private function enableButton(param1:*, param2:Function) : *
      {
         param1.hitZone.buttonMode = true;
         param1.hitZone.addEventListener(MouseEvent.CLICK,param2);
         param1.hitZone.addEventListener(MouseEvent.ROLL_OVER,GameStatic.startFloat);
         param1.hitZone.addEventListener(MouseEvent.ROLL_OUT,GameStatic.stopFloat);
      }
      
      private function disableButton(param1:*, param2:Function) : *
      {
         param1.hitZone.buttonMode = false;
         param1.hitZone.removeEventListener(MouseEvent.CLICK,param2);
         param1.hitZone.removeEventListener(MouseEvent.ROLL_OVER,GameStatic.startFloat);
         param1.hitZone.removeEventListener(MouseEvent.ROLL_OUT,GameStatic.stopFloat);
      }
      
      private function enableButtons() : *
      {
      }
   }
}

