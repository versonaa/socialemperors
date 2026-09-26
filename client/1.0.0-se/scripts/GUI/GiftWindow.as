package GUI
{
   import core.*;
   import core.statics.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import utils.TextFieldUtil;
   
   public class GiftWindow extends MenuTabMC
   {
      
      private static const SUBCAT_MAIN:int = 1;
      
      private static const SUBCAT_IPHONE:int = 2;
      
      Security.allowDomain("*");
      
      public var buttons:Array;
      
      private var buildingArray:Array;
      
      private var sortedGifts:Array;
      
      private var startItem:int = 0;
      
      private var subButtons:Array;
      
      private var subNames:Array;
      
      public var popupWindow:* = null;
      
      private var currentItem:Object;
      
      public var maxButtons:int = 8;
      
      public var buttonsOffsetX:int = 144;
      
      public var buttonsOffsetY:int = 180;
      
      public var numCols:int = 4;
      
      public var numRows:int = 2;
      
      private var subcategory:int;
      
      private var arrowMC:ArrowMC;
      
      private var infoMC:StoreInfoBoxMC;
      
      public function GiftWindow(param1:*, param2:*, param3:int = 0, param4:int = -10)
      {
         super();
         this.buttons = new Array(0);
         this.currentItem = {"fid":0};
         this.subButtons = [];
         this.sortedGifts = new Array(0);
         this.buildingArray = Base.Main.gifts;
         this.subNames = [Language.getLiteral(Language.STORAGE_SUB_MAIN),Language.getLiteral(Language.STORAGE_SUB_IPHONE)];
         this.subcategory = SUBCAT_MAIN;
         x = param3;
         y = param4;
         if(Base.Main.hasIphoneStorage)
         {
            this.subcategory = SUBCAT_IPHONE;
            this.createSubMenus();
            if(!Base.Player.isInfoShowed(Constants.SHOWED_MOBILE_STORAGE_ARROW))
            {
               this.showMobileInfo();
               this.showArrow();
            }
         }
         this.createButtons();
      }
      
      private function showArrow() : void
      {
         var _loc1_:SubCategory = null;
         _loc1_ = this.subButtons[1] as SubCategory;
         this.arrowMC = new ArrowMC();
         this.arrowMC.marcaBuild.visible = false;
         this.arrowMC.marcaSuelo.visible = false;
         this.arrowMC.mouseEnabled = false;
         this.arrowMC.mouseChildren = false;
         this.arrowMC.rotation = 180;
         this.arrowMC.scaleX = this.arrowMC.scaleY = 0.6;
         this.arrowMC.x = _loc1_.x + _loc1_.width - 10;
         this.arrowMC.y = _loc1_.y + 11;
         addChild(this.arrowMC);
      }
      
      private function hideArrow() : void
      {
         if(this.arrowMC != null)
         {
            removeChild(this.arrowMC);
            this.arrowMC = null;
         }
      }
      
      private function showMobileInfo() : void
      {
         this.infoMC = new StoreInfoBoxMC();
         this.infoMC.x = -x;
         this.infoMC.y = -y;
         var _loc1_:Array = Language.getLiteral(Language.STORAGE_IPHONE_ITEMS).split("<br>");
         TextFieldUtil.setHTML(this.infoMC.text,_loc1_[0]);
         TextFieldUtil.setHTML(this.infoMC.text2,_loc1_[1]);
         GameStatic.buttonize(this.infoMC.btnOk,Language.AUX_OK);
         this.infoMC.btnOk.addEventListener(MouseEvent.CLICK,this.hideMobileInfo);
         addChild(this.infoMC);
      }
      
      private function hideMobileInfo(param1:MouseEvent) : void
      {
         if(this.infoMC != null)
         {
            removeChild(this.infoMC);
            this.infoMC = null;
            Base.Player.setInfoShowed(Constants.SHOWED_MOBILE_STORAGE_ARROW);
         }
      }
      
      private function startTimer() : *
      {
      }
      
      private function closeOptions(... rest) : *
      {
      }
      
      public function closePopup() : *
      {
         if(this.popupWindow != null)
         {
            this.popupWindow.closeWindow();
         }
      }
      
      private function rightShiftItems(... rest) : *
      {
         this.startItem += this.maxButtons;
         if(this.startItem >= this.sortedGifts.length - this.maxButtons)
         {
            this.startItem = this.sortedGifts.length - this.maxButtons;
            this.disableButton2(shiftRight);
         }
         this.enableButton(shiftLeft,this.leftShiftItems,false);
         this.setButtons();
      }
      
      public function setItem(param1:*) : *
      {
         this.currentItem = param1;
      }
      
      public function resetWindow() : void
      {
         this.createButtons();
      }
      
      private function enableButton(param1:*, param2:Function, param3:Boolean = true) : *
      {
         param1.hitZone.mouseEnabled = true;
         param1.alpha = 1;
         param1.hitZone.buttonMode = true;
         param1.hitZone.addEventListener(MouseEvent.MOUSE_DOWN,param2);
         param1.hitZone.addEventListener(MouseEvent.ROLL_OVER,GameStatic.turnWhite);
         param1.hitZone.addEventListener(MouseEvent.ROLL_OUT,GameStatic.turnNormal);
      }
      
      private function clickRemove(... rest) : *
      {
         Base.PopUp.confirm(Language.getLiteral(Language.MISC_SEGURO),this.removeItem,null);
      }
      
      private function gotoOtherMap(... rest) : *
      {
      }
      
      private function makeButtons() : *
      {
         if(!this.sortedGifts.length)
         {
            this.buttons.push(this.addChild(new NoGifts(Base.Main,this,40,8)));
         }
         if(this.sortedGifts.length <= this.maxButtons)
         {
            this.disableButton2(shiftRight);
         }
         if(this.startItem + this.maxButtons >= this.sortedGifts.length)
         {
            this.startItem = Math.max(0,this.sortedGifts.length - this.maxButtons);
         }
         var _loc1_:* = this.startItem;
         var _loc2_:int = 0;
         while(_loc1_ < this.startItem + this.maxButtons && _loc1_ < this.sortedGifts.length)
         {
            this.buttons.push(this.addChild(new GiftButtonLarge(this,this.sortedGifts[_loc1_][0],30 + this.buttonsOffsetX * (_loc1_ % this.numCols),-20 + Math.floor(_loc2_ / this.numCols) * this.buttonsOffsetY,this.sortedGifts[_loc1_].length,this.sortedGifts[_loc1_])));
            _loc1_++;
            _loc2_++;
         }
         this.enableButton(shiftRight,this.rightShiftItems,false);
         this.enableButton(shiftLeft,this.leftShiftItems,false);
         if(this.startItem == 0)
         {
            this.disableButton2(shiftLeft);
         }
         if(this.sortedGifts.length <= this.maxButtons)
         {
            this.disableButton2(shiftRight);
         }
      }
      
      private function removeItem(... rest) : *
      {
      }
      
      private function disableButton(param1:*, param2:Function, param3:Boolean = true) : *
      {
         param1.hitZone.mouseEnabled = false;
         param1.alpha = 0.5;
         param1.hitZone.buttonMode = false;
         param1.hitZone.removeEventListener(MouseEvent.MOUSE_DOWN,param2);
         param1.hitZone.removeEventListener(MouseEvent.ROLL_OVER,GameStatic.turnWhite);
         param1.hitZone.removeEventListener(MouseEvent.ROLL_OUT,GameStatic.turnNormal);
      }
      
      private function disableButton2(param1:*) : *
      {
         param1.hitZone.mouseEnabled = false;
         param1.alpha = 0.5;
         param1.hitZone.buttonMode = false;
      }
      
      private function setButtons() : *
      {
         var _loc1_:* = 0;
         while(_loc1_ < this.maxButtons)
         {
            this.buttons[_loc1_].setItem(_loc1_ + this.startItem < this.sortedGifts.length ? this.sortedGifts[_loc1_ + this.startItem][0] : {"fid":0},this.sortedGifts[_loc1_ + this.startItem].length);
            this.buttons[_loc1_].formatSellUseBtns();
            _loc1_++;
         }
      }
      
      private function leftShiftItems(... rest) : *
      {
         this.startItem -= this.maxButtons;
         if(this.startItem <= 0)
         {
            this.startItem = 0;
            this.disableButton2(shiftLeft);
         }
         this.enableButton(shiftRight,this.rightShiftItems,false);
         this.setButtons();
      }
      
      private function gotoProfile(... rest) : *
      {
      }
      
      public function selectGift(param1:Object) : *
      {
         this.disableButtons();
         while(this.buttons.length)
         {
            this.buttons.pop().destroy();
         }
         var _loc2_:* = 0;
         while(_loc2_ < this.buildingArray.length)
         {
            if(this.buildingArray[_loc2_].staticData.id == param1.id && this.buildingArray[_loc2_].giftId == param1.gid)
            {
               this.buildingArray.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         this.makeButtons();
      }
      
      private function stopTimer() : *
      {
      }
      
      private function createButtons(param1:MouseEvent = null) : void
      {
         var _loc5_:StoreObject = null;
         var _loc2_:int = 0;
         if(param1 != null)
         {
            this.subcategory = param1.currentTarget.subID;
            this.hideArrow();
         }
         while(_loc2_ < this.subButtons.length)
         {
            if(this.subButtons[_loc2_].subID != this.subcategory)
            {
               this.subButtons[_loc2_].setTextColor(10060899);
            }
            else
            {
               this.subButtons[_loc2_].setTextColor(2434341);
            }
            _loc2_++;
         }
         while(this.buttons.length)
         {
            this.buttons.pop().destroy();
         }
         this.sortedGifts = [];
         var _loc3_:Boolean = false;
         this.buildingArray.sortOn("name",Array.CASEINSENSITIVE);
         var _loc4_:int = 0;
         while(_loc4_ < this.buildingArray.length)
         {
            _loc5_ = this.buildingArray[_loc4_];
            if(this.subcategory == SUBCAT_MAIN && _loc5_.iphoneId == null || Boolean(this.subcategory == SUBCAT_IPHONE) && Boolean(_loc5_.iphoneId))
            {
               _loc3_ = false;
               _loc2_ = 0;
               while(_loc2_ < this.sortedGifts.length)
               {
                  if(this.sortedGifts[_loc2_][0].staticData.id == _loc5_.staticData.id)
                  {
                     _loc3_ = true;
                     this.sortedGifts[_loc2_].push(_loc5_);
                     break;
                  }
                  _loc2_++;
               }
               if(!_loc3_)
               {
                  this.sortedGifts.push([_loc5_]);
               }
            }
            _loc4_++;
         }
         this.makeButtons();
      }
      
      private function createSubMenus() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:SubCategory = null;
         var _loc2_:int = 0;
         if(this.subNames.length)
         {
            _loc2_ = 0;
            _loc3_ = 92;
            while(_loc2_ < this.subNames.length)
            {
               _loc1_ = new SubCategory();
               _loc1_.x = _loc3_;
               _loc1_.y = -44;
               _loc1_.setText(this.subNames[_loc2_]);
               _loc1_.subID = _loc2_ == 0 ? SUBCAT_MAIN : SUBCAT_IPHONE;
               _loc1_.addEventListener(MouseEvent.MOUSE_DOWN,this.createButtons);
               addChild(_loc1_);
               this.subButtons.push(_loc1_);
               _loc3_ += _loc1_.width + 4;
               _loc2_++;
            }
         }
      }
      
      public function ioErrorHandler(param1:*) : *
      {
         this.enableButtons();
      }
      
      private function disableButtons() : *
      {
      }
      
      public function destroy(... rest) : *
      {
         this.disableButtons();
         var _loc2_:* = 0;
         while(_loc2_ < this.buttons.length)
         {
            this.buttons[_loc2_].destroy();
            _loc2_++;
         }
         parent.removeChild(this);
      }
      
      private function enableButtons() : *
      {
      }
   }
}

