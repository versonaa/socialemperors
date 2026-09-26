package GUI
{
   import com.socialpoint.debug.Tracing;
   import core.*;
   import core.isoengine.*;
   import core.isoengine.delegates.FortressDelegate;
   import core.statics.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import managers.ImageManager;
   import managers.SoundManager;
   import managers.images.ImageManagerResource;
   import popups.PopupCollect;
   import popups.PopupQuestsManager;
   import utils.TextFieldUtil;
   
   public class RecuadroInfo extends MovieClip
   {
      
      public var vPortraits:Vector.<Portrait>;
      
      public var vPortraitSpecialUnits:Vector.<Portrait>;
      
      public var vUnitsContained:Vector.<IsoUnit>;
      
      public var vSelectedElements:Vector.<IsoInteractiveElement>;
      
      public var extendedPortrait:MovieClip;
      
      public static const LITERAL_TRAIN:int = 1649;
      
      public static const LITERAL_TRAIN_WITH_CASH:int = 3001;
      
      private var vQueueThumbs:Array = [];
      
      private var trainingPie:Sprite = null;
      
      public var mcInhibidorClicks:MovieClip;
      
      public var vSpecialAttacks:Vector.<PortraitSpecialAttack>;
      
      public var eElement:IsoInteractiveElement;
      
      public var tooltip:MovieClip;
      
      public var ri:RecuadroInfoMC;
      
      public function RecuadroInfo(param1:RecuadroInfoMC)
      {
         super();
         this.ri = param1;
         this.mcInhibidorClicks = null;
         this.vSpecialAttacks = null;
         this.initPortraits();
         if(this.ri.stage != null)
         {
            this.installShortcuts();
         }
         else
         {
            this.ri.addEventListener(Event.ADDED_TO_STAGE,this.installShortcuts);
         }
      }
      
      // Keyboard shortcuts: Tab / Shift+Tab cycle through the units shown above the
      // panel, 1-4 use the selected unit's skills and R its limit.
      private function installShortcuts(param1:Event = null) : void
      {
         this.ri.removeEventListener(Event.ADDED_TO_STAGE,this.installShortcuts);
         this.ri.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onShortcutKey);
         // Tab would otherwise move the focus through the buttons, like in a web page
         this.ri.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange);
      }
      
      private function onKeyFocusChange(param1:FocusEvent) : void
      {
         if(param1.keyCode == Keyboard.TAB && !this.isTyping())
         {
            param1.preventDefault();
         }
      }
      
      private function isTyping() : Boolean
      {
         var _loc1_:TextField = this.ri.stage.focus as TextField;
         return _loc1_ != null && _loc1_.type == TextFieldType.INPUT;
      }
      
      private function onShortcutKey(param1:KeyboardEvent) : void
      {
         if(this.isTyping() || Base.PopUp.confirmWindow != null)
         {
            return;
         }
         switch(param1.keyCode)
         {
            case Keyboard.TAB:
               this.focusNextSpecialUnit(param1.shiftKey ? -1 : 1);
               break;
            case 49:
            case 50:
            case 51:
            case 52:
               this.useSpecialAttack(param1.keyCode - 49);
               break;
            case 97:
            case 98:
            case 99:
            case 100:
               this.useSpecialAttack(param1.keyCode - 97);
               break;
            case 82:
               this.useLimitAttack();
         }
      }
      
      private function focusNextSpecialUnit(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = -1;
         if(this.vPortraitSpecialUnits == null || this.vPortraitSpecialUnits.length == 0)
         {
            return;
         }
         if(this.vSelectedElements != null && this.vSelectedElements.length == 1)
         {
            _loc2_ = 0;
            while(_loc2_ < this.vPortraitSpecialUnits.length)
            {
               if(this.vPortraitSpecialUnits[_loc2_].GetElement() == this.vSelectedElements[0])
               {
                  _loc3_ = _loc2_;
               }
               _loc2_++;
            }
         }
         if(_loc3_ == -1)
         {
            _loc3_ = param1 > 0 ? 0 : int(this.vPortraitSpecialUnits.length - 1);
         }
         else
         {
            _loc3_ = (_loc3_ + param1 + this.vPortraitSpecialUnits.length) % this.vPortraitSpecialUnits.length;
         }
         this.vPortraitSpecialUnits[_loc3_].clickItem(null);
      }
      
      // White border around the special unit that is selected
      public function updateSpecialUnitFocus() : void
      {
         var _loc1_:Portrait = null;
         var _loc2_:Shape = null;
         var _loc3_:IsoInteractiveElement = this.vSelectedElements != null && this.vSelectedElements.length == 1 ? this.vSelectedElements[0] : null;
         if(this.vPortraitSpecialUnits == null)
         {
            return;
         }
         for each(_loc1_ in this.vPortraitSpecialUnits)
         {
            _loc2_ = _loc1_.getChildByName("focusBorder") as Shape;
            if(_loc3_ != null && _loc1_.GetElement() == _loc3_)
            {
               if(_loc2_ == null)
               {
                  _loc2_ = new Shape();
                  _loc2_.name = "focusBorder";
                  _loc2_.graphics.lineStyle(3,16777215);
                  _loc2_.graphics.drawRoundRect(-1,-1,_loc1_.portraitMC.width + 2,_loc1_.portraitMC.height + 2,10,10);
                  _loc1_.addChild(_loc2_);
               }
            }
            else if(_loc2_ != null)
            {
               _loc1_.removeChild(_loc2_);
            }
         }
      }
      
      private function useSpecialAttack(param1:int) : void
      {
         if(this.vSpecialAttacks != null && param1 < this.vSpecialAttacks.length && this.vSpecialAttacks[param1] != null && !(this.vSpecialAttacks[param1] is PortraitLimitAttack))
         {
            this.vSpecialAttacks[param1].clickItem(null);
         }
      }
      
      private function useLimitAttack() : void
      {
         var _loc1_:PortraitSpecialAttack = null;
         if(this.vSpecialAttacks == null)
         {
            return;
         }
         for each(_loc1_ in this.vSpecialAttacks)
         {
            if(_loc1_ is PortraitLimitAttack)
            {
               _loc1_.clickItem(null);
               return;
            }
         }
      }
      
      public function refreshElementInRecuadro(param1:IsoInteractiveElement) : Boolean
      {
         if(this.vSelectedElements.indexOf(param1) != -1)
         {
            this.removeElementInRecuadro(param1);
            this.addElementInRecuadro(param1);
            return true;
         }
         return false;
      }
      
      public function addElementInRecuadro(param1:IsoInteractiveElement) : Boolean
      {
         if(this.vSelectedElements.length < Config.MAX_SELECTED_OBJECTS)
         {
            this.vSelectedElements.push(param1);
            if(param1 is IsoSpecialUnit)
            {
               this.addSpecialAttacksInRecuadro(IsoSpecialUnit(param1));
            }
            else
            {
               this.vSpecialAttacks = null;
            }
            this.refreshRecuadro();
            return true;
         }
         return false;
      }
      
      public function addSpecialAttacksInRecuadro(param1:IsoSpecialUnit, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:Array = IsoSpecialUnit(param1).getAttacks();
         this.vSpecialAttacks = new Vector.<PortraitSpecialAttack>(_loc4_.length);
         _loc3_ = int(_loc4_.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            if(_loc4_[_loc5_] != null)
            {
               if(_loc5_ >= 4)
               {
                  this.vSpecialAttacks[_loc5_] = new PortraitLimitAttack(SpecialUnitAttack(_loc4_[_loc5_]),param1);
                  this.vSpecialAttacks[_loc5_].setKeyLabel("R");
               }
               else
               {
                  this.vSpecialAttacks[_loc5_] = new PortraitSpecialAttack(SpecialUnitAttack(_loc4_[_loc5_]),param1);
                  this.vSpecialAttacks[_loc5_].setKeyLabel(String(_loc5_ + 1));
               }
            }
            else
            {
               this.vSpecialAttacks[_loc5_] = null;
            }
            _loc5_++;
         }
         if(param2)
         {
            if(this.extendedPortrait == null)
            {
               this.initializeExtendedPortrait(param1);
            }
            this.drawSpecialAttacks(this.extendedPortrait);
            if(this.vSpecialAttacks != null && this.vSpecialAttacks.length > 0)
            {
               _loc6_ = 0;
               while(_loc6_ < this.vSpecialAttacks.length)
               {
                  if(this.vSpecialAttacks[_loc6_] != null)
                  {
                     this.vSpecialAttacks[_loc6_].setElement(this.vSpecialAttacks[_loc6_].GetElement(),1);
                     this.vSpecialAttacks[_loc6_].UpdateImage();
                     this.vSpecialAttacks[_loc6_].Refresh();
                  }
                  _loc6_++;
               }
            }
         }
      }
      
      public function removeSpecialAttacksFromRecuadro(param1:IsoSpecialUnit) : void
      {
         var _loc4_:PortraitSpecialAttack = null;
         var _loc2_:MovieClip = this.extendedPortrait;
         var _loc3_:int = 0;
         while(_loc3_ < this.vSpecialAttacks.length)
         {
            _loc4_ = this.vSpecialAttacks[_loc3_];
            if(_loc2_.attacksMc.contains(_loc4_))
            {
               _loc2_.attacksMc.removeChild(_loc4_);
            }
            _loc3_++;
         }
         this.vSpecialAttacks = null;
      }
      
      public function castSpecialAttacks(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         if(this.vSpecialAttacks != null && this.vSpecialAttacks.length > 0)
         {
            _loc3_ = int(this.vSpecialAttacks.length);
            _loc4_ = int(_loc3_ - 1);
            while(_loc4_ >= 0)
            {
               if(this.vSpecialAttacks[_loc4_] != null)
               {
                  this.vSpecialAttacks[_loc4_].startCastingMask(param1,param2);
               }
               _loc4_--;
            }
         }
      }
      
      public function updateSpecialAttackCooldown() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         if(this.vSpecialAttacks != null && this.vSpecialAttacks.length > 0)
         {
            _loc1_ = int(this.vSpecialAttacks.length);
            _loc2_ = int(_loc1_ - 1);
            while(_loc2_ >= 0)
            {
               this.vSpecialAttacks[_loc2_].updateState();
               _loc2_--;
            }
         }
      }
      
      public function addSpecialUnitSelectorPortrait(param1:IsoInteractiveElement) : void
      {
         var _loc2_:Portrait = null;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:* = 0;
         if(this.vPortraitSpecialUnits == null)
         {
            this.vPortraitSpecialUnits = new Vector.<Portrait>();
         }
         if(this.vPortraitSpecialUnits != null && this.vPortraitSpecialUnits.length > 0)
         {
            _loc3_ = int(this.vPortraitSpecialUnits.length);
            _loc4_ = false;
            _loc5_ = int(_loc3_ - 1);
            while(_loc5_ >= 0 && _loc4_ == false)
            {
               if(Portrait(this.vPortraitSpecialUnits[_loc5_]).GetElement() == param1)
               {
                  _loc4_ = true;
               }
               _loc5_--;
            }
         }
         if(!_loc4_)
         {
            _loc2_ = new Portrait();
            _loc2_.setElement(param1,1);
            this.vPortraitSpecialUnits.push(_loc2_);
         }
         this.redrawSpecialUnitSelectorPortraits();
      }
      
      public function removeSpecialUnitSelectorPortrait(param1:IsoInteractiveElement) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         _loc2_ = int(this.vPortraitSpecialUnits.length);
         var _loc4_:* = int(_loc2_ - 1);
         while(_loc4_ >= 0 && _loc3_ == false)
         {
            if(this.vPortraitSpecialUnits[_loc4_].eElement == param1)
            {
               this.ri.removeChild(this.vPortraitSpecialUnits[_loc4_]);
               this.vPortraitSpecialUnits.splice(_loc4_,1);
               _loc3_ == true;
            }
            _loc4_--;
         }
         this.redrawSpecialUnitSelectorPortraits();
      }
      
      private function redrawSpecialUnitSelectorPortraits() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         if(Base.Gui.recuadroShowed)
         {
            _loc1_ = int(this.vPortraitSpecialUnits.length);
            _loc2_ = int(_loc1_ - 1);
            while(_loc2_ >= 0)
            {
               this.vPortraitSpecialUnits[_loc2_].x = 175 + _loc2_ * Portrait(this.vPortraitSpecialUnits[_loc2_]).portraitMC.width + (_loc2_ != 0 ? 5 : 0);
               this.vPortraitSpecialUnits[_loc2_].y = -Portrait(this.vPortraitSpecialUnits[_loc2_]).height;
               this.ri.addChild(this.vPortraitSpecialUnits[_loc2_]);
               _loc2_--;
            }
            this.updateSpecialUnitFocus();
         }
      }
      
      public function showSpecialUnitPortraits() : void
      {
         var _loc1_:* = 0;
         var _loc2_:int = 0;
         if(this.vPortraitSpecialUnits != null && this.vPortraitSpecialUnits.length > 0)
         {
            _loc2_ = int(this.vPortraitSpecialUnits.length);
            _loc1_ = int(_loc2_ - 1);
            while(_loc1_ >= 0)
            {
               this.vPortraitSpecialUnits[_loc1_].visible = true;
               _loc1_--;
            }
         }
      }
      
      public function hideSpecialUnitPortraits() : void
      {
         var _loc1_:* = 0;
         var _loc2_:int = 0;
         var _temp_1:* = this.vPortraitSpecialUnits != null;
         _temp_1; //unpopped
         if(_temp_1)
         {
            _loc2_ = int(this.vPortraitSpecialUnits.length);
            _loc1_ = int(_loc2_ - 1);
            while(_loc1_ >= 0)
            {
               this.vPortraitSpecialUnits[_loc1_].visible = false;
               _loc1_--;
            }
         }
      }
      
      private function drawSpecialAttacks(param1:MovieClip) : void
      {
         var _loc2_:PortraitSpecialAttack = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.vSpecialAttacks != null)
         {
            _loc5_ = 0;
            while(_loc5_ < this.vSpecialAttacks.length)
            {
               _loc2_ = this.vSpecialAttacks[_loc5_];
               if(_loc2_ != null)
               {
                  _loc2_.portraitMC.barraVida.visible = false;
                  _loc2_.portraitMC.marco.visible = false;
                  _loc2_.portraitMC.image.x = _loc2_.portraitMC.image.y = 0;
                  if(_loc5_ < 4)
                  {
                     _loc3_ = _loc5_ / 2;
                     _loc4_ = _loc5_ % 2;
                     _loc2_.x = _loc4_ * _loc2_.width + 2;
                     _loc2_.y = _loc3_ * Config.SPACEY_SELECTED_ELEMENTS + 4;
                  }
                  else
                  {
                     _loc2_.x = -60;
                     _loc2_.y = 4;
                     _loc2_.removeEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                     _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                     _loc2_.removeEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
                     _loc2_.addEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
                     _loc2_.name = Base.Iso.getLimitFromDragon(this.eElement);
                  }
                  _loc2_.buttonMode = true;
                  param1.attacksMc.addChild(_loc2_);
               }
               _loc5_++;
            }
         }
      }
      
      public function removeElementInRecuadro(param1:IsoInteractiveElement) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this.vSelectedElements.length)
         {
            if(this.vSelectedElements[_loc2_] == param1)
            {
               param1.pPortrait = null;
               this.vSelectedElements.splice(_loc2_,1);
               this.refreshRecuadro();
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function clearElementsInRecuadro() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IsoInteractiveElement = null;
         _loc1_ = 0;
         while(_loc1_ < this.vSelectedElements.length)
         {
            _loc2_ = this.vSelectedElements[_loc1_];
            _loc2_.pPortrait = null;
            _loc1_++;
         }
         this.vSelectedElements.splice(0,this.vSelectedElements.length);
         this.refreshRecuadro();
         Base.Gui.hideRecuadro();
      }
      
      public function clearSpecialUnitPortraits() : void
      {
         var _loc1_:int = 0;
         if(this.vPortraitSpecialUnits != null && this.vPortraitSpecialUnits.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.vPortraitSpecialUnits.length)
            {
               this.ri.removeChild(this.vPortraitSpecialUnits[_loc1_]);
               _loc1_++;
            }
            this.vPortraitSpecialUnits.splice(0,this.vPortraitSpecialUnits.length);
         }
      }
      
      public function refreshLoadBar(param1:Number, param2:uint = 0) : void
      {
         var _loc3_:MovieClip = null;
         if(this.extendedPortrait is EP_NewBarracksMC)
         {
            if(this.eElement is IsoBuilding && IsoBuilding(this.eElement).bTrainingUnit)
            {
               this.refreshTrainingTime(param1);
            }
            return;
         }
         if(this.extendedPortrait != null && this.extendedPortrait.timeBar != null)
         {
            _loc3_ = this.extendedPortrait.timeBar;
            _loc3_.percentMask.scaleX = Math.min(param1,1);
            TextFieldUtil.setHTML(_loc3_.percentText,Math.min(int(param1 * 100),100) + "%");
            if(param2 != 0)
            {
               this.extendedPortrait.timeBar.timeLeft.visible = true;
               TextFieldUtil.setHTML(this.extendedPortrait.timeBar.timeLeft,GameStatic.dhms(param2));
            }
            else
            {
               this.extendedPortrait.timeBar.timeLeft.visible = false;
            }
         }
      }
      
      public function refreshRecuadro() : void
      {
         var _loc1_:Portrait = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc3_ = int(this.vPortraits.length);
         if(this.vSpecialAttacks != null && this.vSpecialAttacks.length > 0)
         {
            _loc4_ = 0;
            while(_loc4_ < this.vSpecialAttacks.length)
            {
               if(this.vSpecialAttacks[_loc4_] != null)
               {
                  this.vSpecialAttacks[_loc4_].setElement(this.vSpecialAttacks[_loc4_].GetElement(),1);
                  this.vSpecialAttacks[_loc4_].UpdateImage();
                  this.vSpecialAttacks[_loc4_].Refresh();
               }
               _loc4_++;
            }
         }
         if(this.vPortraitSpecialUnits != null && this.vPortraitSpecialUnits.length > 0 && Base.Gui.recuadroShowed)
         {
            _loc2_ = 0;
            while(_loc2_ < this.vPortraitSpecialUnits.length)
            {
               this.vPortraitSpecialUnits[_loc2_].Refresh();
               _loc2_++;
            }
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(_loc2_ < this.vSelectedElements.length && this.vSelectedElements.length > 1)
            {
               this.vPortraits[_loc2_].setElement(this.vSelectedElements[_loc2_],1);
            }
            else
            {
               this.vPortraits[_loc2_].setElement(null);
            }
            this.vPortraits[_loc2_].ipos = _loc2_;
            this.vPortraits[_loc2_].Refresh();
            _loc2_++;
         }
         this.updateSpecialUnitFocus();
         if(this.vSelectedElements.length == 1)
         {
            Base.Main.selectedItem = this.vSelectedElements[0].buildingReference;
            this.initializeExtendedPortrait(this.vSelectedElements[0]);
         }
         else
         {
            this.removeExtendedPortrait();
         }
         if(Base.Main.gameMode == Constants.GAME_MODE_NEIGHBOUR || (Base.Main.gameMode == Constants.GAME_MODE_TOURNAMENT || Base.Main.gameMode == Constants.GAME_MODE_SURVIVAL || Base.Main.gameMode == Constants.GAME_MODE_ASSAULT || Base.Main.gameMode == Constants.GAME_MODE_NORMAL) && this.vSelectedElements.length == 1 && this.vSelectedElements[0].PlayerID != Constants.PLAYER_SELF && !Base.Main.isOffer(this.vSelectedElements[0].iID))
         {
            if(this.extendedPortrait != null)
            {
               this.mcInhibidorClicks = new InhibidorClicksMC();
               this.mcInhibidorClicks.mouseEnabled = true;
               this.mcInhibidorClicks.mouseChildren = true;
               this.extendedPortrait.addChild(this.mcInhibidorClicks);
            }
         }
         else if(this.extendedPortrait != null)
         {
            if(!Base.Main.gameMode == Constants.GAME_MODE_ASSAULT || this.vSelectedElements.length == 1 && this.vSelectedElements[0] is IsoUnit && this.vSelectedElements[0].PlayerID == Constants.PLAYER_SELF)
            {
               this.mcInhibidorClicks = null;
            }
         }
         if(this.eElement != null && this.eElement is IsoBuilding && this.eElement.buildingReference != null && this.eElement.buildingReference.building.unit_capacity > 0)
         {
            this.vUnitsContained = IsoBuilding(this.eElement).vUnitsContained;
         }
      }
      
      public function initPortraits() : void
      {
         var _loc1_:Portrait = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.vSelectedElements = new Vector.<IsoInteractiveElement>();
         this.vPortraits = new Vector.<Portrait>(Config.MAX_SELECTED_OBJECTS);
         _loc2_ = 0;
         while(_loc2_ < Config.MAX_SELECTED_OBJECTS)
         {
            _loc1_ = new Portrait();
            _loc3_ = _loc2_ / (Config.MAX_SELECTED_OBJECTS / 2);
            _loc4_ = _loc2_ % (Config.MAX_SELECTED_OBJECTS / 2);
            _loc1_.x = _loc4_ * Config.SPACE_SELECTED_ELEMENTS + Config.LEFT_MARGIN_SELECTED_ELEMENTS;
            _loc1_.y = Config.TOP_MARGIN_SELECTED_ELEMENTS + _loc3_ * Config.SPACEY_SELECTED_ELEMENTS;
            this.vPortraits[_loc2_] = _loc1_;
            this.ri.addChild(_loc1_);
            _loc2_++;
         }
         if(this.eElement != null && this.eElement is IsoBuilding && this.eElement.buildingReference != null && this.eElement.buildingReference.building.unit_capacity > 0)
         {
            this.vUnitsContained = IsoBuilding(this.eElement).vUnitsContained;
         }
      }
      
      public function removeExtendedPortrait() : void
      {
         if(this.extendedPortrait != null)
         {
            this.ri.removeChild(this.extendedPortrait);
            this.extendedPortrait = null;
            if(this.eElement != null)
            {
               this.eElement.pPortrait = null;
            }
         }
      }
      
      public function updateUnitPortraitData(param1:IsoInteractiveElement) : void
      {
         var _loc2_:StaticData = param1.buildingReference.building;
         this.actualizarBarraVida();
         TextFieldUtil.setHTML(this.extendedPortrait.txNombre,param1.sName);
         TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,_loc2_.attack);
         TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,_loc2_.attack_range);
         TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,_loc2_.attack_interval);
         TextFieldUtil.setHTML(this.extendedPortrait.mcSpeed.txSpeed,_loc2_.velocity);
      }
      
      public function initializeExtendedPortrait(param1:IsoInteractiveElement) : void
      {
         var elementInfo:StaticData = null;
         var cost:uint = 0;
         var iLife:int = 0;
         var ep:EP_WarehouseMC = null;
         var _eElement:IsoInteractiveElement = param1;
         this.eElement = _eElement;
         if(this.eElement != null)
         {
            this.eElement.pPortrait = this;
         }
         if(_eElement.buildingReference != null)
         {
            Base.Sound.playSfx(SoundManager.SFX_BUTTON_CLICK);
            elementInfo = _eElement.buildingReference.building;
            if(Base.Main.isOffer(_eElement.iID))
            {
               this.extendedPortrait = new EP_OfferBuilding_MC();
               this.ri.addChild(this.extendedPortrait);
               this.actualizarBarraVida();
               TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
               this.loadImage(elementInfo.img_name);
               TextFieldUtil.setHTML(this.extendedPortrait.txInfo,"");
               this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.onShowOffer);
            }
            else if(_eElement is IsoUnit)
            {
               if(_eElement is IsoSpecialUnit && IsoUnit(_eElement).PlayerID == Constants.PLAYER_SELF)
               {
                  this.extendedPortrait = new EP_SpecialUnitMc();
                  this.drawSpecialAttacks(this.extendedPortrait);
                  this.extendedPortrait.timeRemaining.visible = false;
               }
               else
               {
                  this.extendedPortrait = new EP_UnitMC();
               }
               this.ri.addChild(this.extendedPortrait);
               this.actualizarBarraVida();
               TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
               TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
               TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,elementInfo.attack_range);
               TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
               TextFieldUtil.setHTML(this.extendedPortrait.mcSpeed.txSpeed,elementInfo.velocity);
               this.loadImage(elementInfo.img_name);
            }
            else if(_eElement is IsoBuilding)
            {
               if(_eElement.inConstruction)
               {
                  this.extendedPortrait = new EP_Build_MC();
                  this.ri.addChild(this.extendedPortrait);
                  this.actualizarBarraVida();
                  TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                  this.loadImage(elementInfo.img_name);
                  cost = 10;
                  TextFieldUtil.setHTML(this.extendedPortrait.speedUpPane.lblCost,"Cost:");
                  this.extendedPortrait.speedUpPane.iconResources.gotoAndStop(1);
                  TextFieldUtil.setHTML(this.extendedPortrait.speedUpPane.lblPrice,String(cost));
                  if(elementInfo.build_time > 0)
                  {
                     this.extendedPortrait.speedUpPane.visible = true;
                     GameStatic.buttonize(this.extendedPortrait.speedUpPane.btnBuy);
                     this.extendedPortrait.speedUpPane.btnBuy.addEventListener(MouseEvent.CLICK,function(param1:Event):void
                     {
                        if(Base.Player.canAfford(cost,CostType.CASH))
                        {
                           Base.Player.adjustStatByType(-cost,CostType.CASH);
                           _eElement.endConstruction();
                           _eElement.fauxBar.destroy();
                           _eElement.fauxBar = null;
                           Base.Main.ps.addParticle(new NumberParticle(eElement.x * Base.Main.currentZoom + eElement.parent.x,eElement.y * Base.Main.currentZoom + eElement.parent.y + 50,[-cost],[CostType.CASH]));
                        }
                        else
                        {
                           Base.PopUp.moneyConfirm(cost,CostType.CASH);
                        }
                     });
                  }
                  else
                  {
                     this.extendedPortrait.speedUpPane.visible = false;
                  }
               }
               else
               {
                  switch(_eElement.buildingReference.building.subcat_functional)
                  {
                     case Constants.SUBCATFUNC_BUILDING_HOUSE:
                     case Constants.SUBCATFUNC_RELIC:
                        if(_eElement.buildingReference.building.id == Constants.ID_BUILDING_SUMMIT)
                        {
                           this.extendedPortrait = new EP_Allies_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,elementInfo.attack_range);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,function(param1:Event):void
                           {
                              openSocialBuilding(IsoBuilding(_eElement));
                           });
                           break;
                        }
                     case Constants.SUBCATFUNC_BUILDING_DOMES:
                     case Constants.SUBCATFUNC_BUILDING_DECO:
                        this.extendedPortrait = new EP_House_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcPop.txPop,elementInfo.population);
                        this.loadImage(elementInfo.img_name);
                        if(_eElement.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_DECO)
                        {
                           this.extendedPortrait.mcPop.visible = false;
                        }
                        break;
                     case Constants.SUBCATFUNC_RESOURCE_TREE:
                     case Constants.SUBCATFUNC_RESOURCE_STONE:
                        this.extendedPortrait = new EP_Resource_MC();
                        this.ri.addChild(this.extendedPortrait);
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.extendedPortrait.iconResources.gotoAndStop(GameStatic.typeCostToFrame(elementInfo.collect_type));
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_COSECHA));
                        TextFieldUtil.setHTML(this.extendedPortrait.earns,elementInfo.collect);
                        break;
                     case Constants.SUBCATFUNC_RESOURCE_GOLD:
                        this.extendedPortrait = new EP_Resource_MC();
                        this.ri.addChild(this.extendedPortrait);
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.extendedPortrait.iconResources.gotoAndStop(GameStatic.typeCostToFrame(elementInfo.collect_type));
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_COSECHA));
                        TextFieldUtil.setHTML(this.extendedPortrait.earns,"" + elementInfo.collect * Base.Iso.getResourceMultiplier());
                        break;
                     case Constants.SUBCATFUNC_RESOURCE_REGEN:
                        this.extendedPortrait = new EP_Resource_MC();
                        this.ri.addChild(this.extendedPortrait);
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.extendedPortrait.iconResources.gotoAndStop(GameStatic.typeCostToFrame(elementInfo.collect_type));
                        this.extendedPortrait.earns.visible = false;
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_REGENERACION));
                        break;
                     case Constants.SUBCATFUNC_TREASURE:
                        this.extendedPortrait = new EP_Resource_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.extendedPortrait.img.visible = false;
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.updateEarns();
                        this.extendedPortrait.earns.visible = true;
                        this.extendedPortrait.barraTiempo.visible = false;
                        if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CHEST)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_COFRE));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_PRISONER_PRINCESS)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_PRINCESA));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_PRISONER_VILLAGERS)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ALDEANOS));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_PRISONER_ARCHERS)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ARQUEROS));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_PRISONER_REBEL_TROLL)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_TROLL));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_PRISONER_KIDNAPPED_UNITS)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_SOLDADOS));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_PRISONER_ARTHUR)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ARTURO));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ1)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_EXTINGUIR));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ2)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_CURANDEROS));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ3)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,"");
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ4)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ALIADOS));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ5)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,"");
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ6)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ASEDIO));
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TREASURE_CQ7)
                        {
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ESTATUA_ESQUELETO));
                        }
                        break;
                     case Constants.SUBCATFUNC_ACTIVATOR:
                        this.extendedPortrait = new EP_Resource_MC();
                        this.ri.addChild(this.extendedPortrait);
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.extendedPortrait.img.visible = false;
                        this.extendedPortrait.iconResources.visible = false;
                        this.extendedPortrait.earns.visible = false;
                        this.extendedPortrait.barraTiempo.visible = false;
                        switch(elementInfo.id)
                        {
                           case Constants.ID_BUILDING_POWER_GEM:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_GEMA_PODER));
                              break;
                           case Constants.ID_BUILDING_KEY_PENGUINS:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_PINGUINOS));
                              break;
                           case Constants.ID_BUILDING_ACTIVATOR_CQ1:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_POZO));
                              break;
                           case Constants.ID_BUILDING_ACTIVATOR_CQ3:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_PIEDRA));
                              break;
                           case Constants.ID_BUILDING_ACTIVATOR_CQ5:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ANIMALES));
                              break;
                           case Constants.ID_BUILDING_ACTIVATOR_CQ7:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ESTATUA_MISTERIOSA));
                              break;
                           default:
                              Tracing.Trace("Unexpected elementInfo.id (" + elementInfo.id + "), tip text won\'t be updated");
                        }
                        break;
                     case Constants.SUBCATFUNC_STATUE_BOSS:
                        this.extendedPortrait = new EP_Resource_MC();
                        this.ri.addChild(this.extendedPortrait);
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.extendedPortrait.img.visible = false;
                        this.extendedPortrait.iconResources.visible = false;
                        this.extendedPortrait.earns.visible = false;
                        this.extendedPortrait.barraTiempo.visible = false;
                        switch(elementInfo.id)
                        {
                           case Constants.ID_BUILDING_STATUE_GOLEM:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_GEMAS_ALTAR));
                              break;
                           case Constants.ID_BUILDING_LOCKED_GATE:
                              TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_LLAVES));
                              break;
                           default:
                              Tracing.Trace("Unexpected elementInfo.id (" + elementInfo.id + "), tip text won\'t be updated");
                        }
                        break;
                     case Constants.SUBCATFUNC_BUILDING_EAGLE:
                        this.extendedPortrait = new EP_TEXT_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        this.loadImage(elementInfo.img_name);
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ESPIAR));
                        switch(elementInfo.id)
                        {
                           case Constants.ID_BUILDING_EAGLE_1:
                           case Constants.ID_BUILDING_TROLL_EAGLE_1:
                              iLife = int(Config.HEALTH_SPY_EAGLES[0]);
                              break;
                           case Constants.ID_BUILDING_EAGLE_2:
                           case Constants.ID_BUILDING_TROLL_EAGLE_2:
                              iLife = int(Config.HEALTH_SPY_EAGLES[1]);
                              break;
                           case Constants.ID_BUILDING_EAGLE_3:
                           case Constants.ID_BUILDING_TROLL_EAGLE_3:
                              iLife = int(Config.HEALTH_SPY_EAGLES[2]);
                              break;
                           case Constants.ID_BUILDING_EAGLE_4:
                              iLife = int(Config.HEALTH_SPY_EAGLES[3]);
                        }
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,this.extendedPortrait.tip.htmlText + Language.getLiteral(Language.INFO_ESPIAR_AGUILAS,[iLife]));
                        break;
                     case Constants.SUBCATFUNC_BUILDING_HEALING:
                        this.extendedPortrait = new EP_TEXT_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        this.loadImage(elementInfo.img_name);
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_HOSPITAL));
                        break;
                     case Constants.SUBCATFUNC_BUILDING_BLACKSMITH:
                        this.extendedPortrait = new EP_TEXT_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        this.loadImage(elementInfo.img_name);
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_HERRERO,[Math.round((1 - Config.REDUCTION_MULTIPLIER_BLACKSMITH) * 100)]));
                        break;
                     case Constants.SUBCATFUNC_BUILDING_UNIVERSITY:
                        this.extendedPortrait = new EP_TEXT_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        this.loadImage(elementInfo.img_name);
                        TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_UNIVERSIDAD,[Math.round((1 - Config.REDUCTION_MULTIPLIER_UNIVERSITY) * 100)]));
                        break;
                     case Constants.SUBCATFUNC_BUILDING_FEATURE:
                        if(elementInfo.id == Constants.ID_BUILDING_MARKET_ALLIES || elementInfo.id == Constants.ID_BUILDING_TROLL_MARKET_ALLIES)
                        {
                           this.extendedPortrait = new EP_Market_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btMarket.addEventListener(MouseEvent.CLICK,this.openAlliesMarket);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_WEATHER_MACHINE)
                        {
                           this.extendedPortrait = new EP_Weather_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,Base.PopUp.openPopupWeather);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_TIME_MACHINE)
                        {
                           this.extendedPortrait = new EP_TimeMachine_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,Base.PopUp.openPopupSelectTime);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_ALLIES_RECRUITMENT)
                        {
                           this.extendedPortrait = new EP_Allies_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openPopupRecruitment);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_ROUND_TABLE)
                        {
                           this.extendedPortrait = new EP_Allies_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openPopupSocialFeeds);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_WIZARDRY)
                        {
                           this.extendedPortrait = new EP_Magic_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           this.loadImage(elementInfo.img_name);
                           TextFieldUtil.setHTML(this.extendedPortrait.txInfo,Language.getLiteral(Language.INFO_HECHICERIA));
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openPopupWizardry);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_DOCK || elementInfo.id == Constants.ID_BUILDING_TROLL_HARBOUR)
                        {
                           this.extendedPortrait = new EP_Harbour_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           this.loadImage(elementInfo.img_name);
                           TextFieldUtil.setHTML(this.extendedPortrait.txInfo,Language.getLiteral(Language.INFO_MUELLE));
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.onSail);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_ZEPPELIN_TOWER || elementInfo.id == Constants.ID_BUILDING_TROLL_ZEPPELIN)
                        {
                           this.extendedPortrait = new EP_Zeppelin_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           this.loadImage(elementInfo.img_name);
                           TextFieldUtil.setHTML(this.extendedPortrait.txInfo,Language.getLiteral(Language.INFO_AERODROMO));
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.onFly);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_SURVIVAL_ARENA)
                        {
                           Base.Iso.eSurvivalArena = IsoBuilding(this.eElement);
                           this.extendedPortrait = new EP_Survival_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           this.loadImage(elementInfo.img_name);
                           TextFieldUtil.setHTML(this.extendedPortrait.txInfo,Language.getLiteral(Language.SURVIVAL_BUILDING_INFO));
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.onSurvival);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_WONDER_SOCIAL)
                        {
                           this.extendedPortrait = new EP_Allies_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openPopupRecruitmentPopulation);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_GRAVEYARD)
                        {
                           this.extendedPortrait = new EP_Graveyard_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,elementInfo.attack_range);
                           this.loadImage(elementInfo.img_name);
                           this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openGraveyard);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_DRAGON_NEST || elementInfo.id == Constants.ID_BUILDING_MONSTERS_NEST || elementInfo.id == Constants.ID_BUILDING_BAHAMUT_SUPREME_INVOCATION_TEMPLE)
                        {
                           if(elementInfo.id == Constants.ID_BUILDING_DRAGON_NEST)
                           {
                              Base.Iso.eDragonNest = IsoBuilding(this.eElement);
                           }
                           else if(elementInfo.id == Constants.ID_BUILDING_MONSTERS_NEST)
                           {
                              Base.Iso.eMonsterNest = IsoBuilding(this.eElement);
                           }
                           if(elementInfo.id == Constants.ID_BUILDING_DRAGON_NEST)
                           {
                              Base.Iso.eDragonNest = IsoBuilding(this.eElement);
                           }
                           else if(elementInfo.id == Constants.ID_BUILDING_MONSTERS_NEST)
                           {
                              Base.Iso.eMonsterNest = IsoBuilding(this.eElement);
                           }
                           else if(elementInfo.id == Constants.ID_BUILDING_BAHAMUT_SUPREME_INVOCATION_TEMPLE)
                           {
                              Base.Iso.eInvocationBahamutSupremeTemple = IsoBuilding(this.eElement);
                           }
                           this.extendedPortrait = new EP_DragonNest_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,elementInfo.attack_range);
                           this.loadImage(elementInfo.img_name);
                           if(elementInfo.id == Constants.ID_BUILDING_DRAGON_NEST)
                           {
                              this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openDragonNest);
                           }
                           else if(elementInfo.id == Constants.ID_BUILDING_MONSTERS_NEST)
                           {
                              this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openMonsterNest);
                           }
                           else if(elementInfo.id == Constants.ID_BUILDING_BAHAMUT_SUPREME_INVOCATION_TEMPLE)
                           {
                              this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openBahamutSupremeInvocationTemple);
                           }
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_UNIT_WAREHOUSE)
                        {
                           this.extendedPortrait = ep = new EP_WarehouseMC();
                           this.ri.addChild(this.extendedPortrait);
                           GameStatic.buttonize(ep.butOpenWarehouse);
                           ep.butOpenWarehouse.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
                           {
                              Base.PopUp.openPopupUnitWarehouse(IsoBuilding(_eElement));
                           });
                           TextFieldUtil.setHTML(ep.txNombre,_eElement.sName);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           this.loadImage(elementInfo.img_name);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_DRAGON_RIDER_TRAINING)
                        {
                           Base.Iso.eDragonRiderTraining = IsoBuilding(this.eElement);
                           this.extendedPortrait = new EP_DragonRiderTraining_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.extendedPortrait.btnOpen.addEventListener(MouseEvent.CLICK,this.openDragonRiders,false,0,true);
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           this.loadImage(elementInfo.img_name);
                        }
                        else if(elementInfo.id == Constants.ID_BUILDING_DRAGON_TAMING)
                        {
                           Base.Iso.eDragonTaming = IsoBuilding(this.eElement);
                           this.extendedPortrait = new EP_DragonTaming_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.extendedPortrait.btnOpen.addEventListener(MouseEvent.CLICK,this.openDragonTaming,false,0,true);
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           this.loadImage(elementInfo.img_name);
                        }
                        else
                        {
                           this.extendedPortrait = new EP_TEXT_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           switch(elementInfo.id)
                           {
                              case Constants.ID_BUILDING_FORESTRY:
                                 TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ASERRADERO));
                                 break;
                              case Constants.ID_BUILDING_MINERY:
                                 TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_MINEROS));
                                 break;
                              case Constants.ID_BUILDING_FITNESS:
                              case Constants.ID_BUILDING_TROLL_COLISEUM:
                                 TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ATLETAS,[Config.LIBRARY_MEMORY_INCREMENT]));
                                 break;
                              case Constants.ID_BUILDING_LEADERSHIPSTATUE:
                                 TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.INFO_ESTATUA_LIDERAZGO));
                           }
                        }
                        break;
                     case Constants.SUBCATFUNC_BUILDING_MILL:
                     case Constants.SUBCATFUNC_BUILDING_FARM:
                     case Constants.SUBCATFUNC_BUILDING_MINE:
                     case Constants.SUBCATFUNC_BUILDING_RANCH:
                     case Constants.SUBCATFUNC_BUILDING_COLLECT:
                        this.extendedPortrait = new EP_Farm_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initContainedPortraits();
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        this.loadImage(elementInfo.img_name);
                        this.actualizarBarraTiempo();
                        this.refreshContained();
                        this.updateEarns();
                        switch(_eElement.buildingReference.building.id)
                        {
                           case Constants.ID_BUILDING_RANCH_SHEEP:
                           case Constants.ID_BUILDING_RANCH_SHEEP_2:
                           case Constants.ID_BUILDING_RANCH_SHEEP_3:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_CORRAL_OVEJAS));
                              break;
                           case Constants.ID_BUILDING_RANCH_COW:
                           case Constants.ID_BUILDING_RANCH_COW_2:
                           case Constants.ID_BUILDING_RANCH_COW_3:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_CORRAL_VACAS));
                              break;
                           case Constants.ID_BUILDING_TROLL_RANCH_BOAR_1:
                           case Constants.ID_BUILDING_TROLL_RANCH_BOAR_2:
                           case Constants.ID_BUILDING_TROLL_RANCH_BOAR_3:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_CORRAL_JABALIS));
                              break;
                           case Constants.ID_BUILDING_STABLE_TRAINING:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_CORRAL_CABALLOS));
                              break;
                           case Constants.ID_BUILDING_VINEYARD:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_ALIMENTACION));
                              break;
                           case Constants.ID_BUILDING_BATHS:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_POBLACION));
                              break;
                           case Constants.ID_BUILDING_TAVERN:
                           case Constants.ID_BUILDING_RESTAURANT:
                           case Constants.ID_BUILDING_TEMPLE:
                           case Constants.ID_BUILDING_BAKERY:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_ALIMENTACION));
                              break;
                           case Constants.ID_BUILDING_MINE_TREASURE:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_COLECCIONABLE));
                              break;
                           case Constants.ID_BUILDING_SACRIFICE:
                              this.extendedPortrait.iconResources.visible = false;
                              this.extendedPortrait.earns.visible = false;
                              this.extendedPortrait.barraTiempo.visible = false;
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_MATADERO));
                              break;
                           case Constants.ID_BUILDING_HATCHERY:
                              TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_CRIADERO));
                        }
                        break;
                     case Constants.SUBCATFUNC_BUILDING_WALL:
                     case Constants.SUBCATFUNC_BUILDING_TOWER:
                     case Constants.SUBCATFUNC_BUILDING_DRAGONKILLER:
                     case Constants.SUBCATFUNC_BUILDING_DOOR:
                        if(_eElement.buildingReference.building.id == Constants.ID_BUILDING_FORTRESS_1)
                        {
                           this.extendedPortrait = new EP_REFUGE_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initContainedPortraits();
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           if(_eElement.buildingReference.building.id == Constants.ID_BUILDING_FORTRESS_1)
                           {
                              this.extendedPortrait.mcAttack.txAttack.text = elementInfo.attack + IsoBuilding(_eElement).vUnitsContained.length * FortressDelegate.DMG_ARROW;
                           }
                           else
                           {
                              TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           }
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.actualizarBarraTiempo();
                           this.refreshContained();
                           TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_BUNKER));
                        }
                        else
                        {
                           this.extendedPortrait = new EP_Wall_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,elementInfo.attack_range);
                           this.loadImage(elementInfo.img_name);
                           if(_eElement.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_DOOR && _eElement.PlayerID == Constants.PLAYER_SELF)
                           {
                              this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.abrirCerrarMuralla);
                              if(IsoBuilding(this.eElement).murallaAbierta)
                              {
                                 this.extendedPortrait.btnAbrir.gotoAndStop(2);
                              }
                              else
                              {
                                 this.extendedPortrait.btnAbrir.gotoAndStop(1);
                              }
                           }
                           else
                           {
                              this.extendedPortrait.btnAbrir.visible = false;
                           }
                        }
                        break;
                     case Constants.SUBCATFUNC_BUILDING_REFUGE:
                        if(IsoBuilding(_eElement).buildingReference.building.id != Constants.ID_BUILDING_UNIT_WAREHOUSE)
                        {
                           this.extendedPortrait = new EP_REFUGE_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initContainedPortraits();
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           if(_eElement.buildingReference.building.id == Constants.ID_BUILDING_FORTRESS_1)
                           {
                              this.extendedPortrait.mcAttack.txAttack.text = elementInfo.attack + IsoBuilding(_eElement).vUnitsContained.length * FortressDelegate.DMG_ARROW;
                           }
                           else
                           {
                              TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           }
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           this.loadImage(elementInfo.img_name);
                           this.actualizarBarraTiempo();
                           this.refreshContained();
                           TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,Language.getLiteral(Language.INFO_BUNKER));
                        }
                        break;
                     case Constants.SUBCATFUNC_BUILDING_WONDER:
                        if(elementInfo.population > 0)
                        {
                           this.extendedPortrait = new EP_House_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                           TextFieldUtil.setHTML(this.extendedPortrait.mcPop.txPop,elementInfo.population);
                           this.loadImage(elementInfo.img_name);
                           TextFieldUtil.setHTML(this.extendedPortrait.tip,Language.getLiteral(Language.STORE_EDIFICIO_MARAVILLA));
                        }
                        else
                        {
                           this.extendedPortrait = new EP_Farm_MC();
                           this.ri.addChild(this.extendedPortrait);
                           this.initBasicButtons();
                           this.actualizarBarraVida();
                           TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                           this.loadImage(elementInfo.img_name);
                           this.actualizarBarraTiempo();
                           TextFieldUtil.setHTML(this.extendedPortrait.txCapacity,"");
                           this.updateEarns();
                           this.extendedPortrait.mcContained.visible = false;
                        }
                        break;
                     case Constants.SUBCATFUNC_BUILDING_TOWNHALL:
                     case Constants.SUBCATFUNC_BUILDING_CASTLE:
                     case Constants.SUBCATFUNC_BUILDING_BARRACKS:
                     case Constants.SUBCATFUNC_BUILDING_ARCHERY:
                     case Constants.SUBCATFUNC_BUILDING_STABLE:
                     case Constants.SUBCATFUNC_BUILDING_WORKSHOP:
                     case Constants.SUBCATFUNC_BUILDING_CHURCH:
                        this.initTrainingPortrait(_eElement,elementInfo);
                        break;
                     case Constants.SUBCATFUNC_BUILDING_MARKET:
                        this.extendedPortrait = new EP_Market_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        this.extendedPortrait.btMarket.addEventListener(MouseEvent.CLICK,this.openMarket);
                        this.loadImage(elementInfo.img_name);
                        break;
                     case Constants.SUBCATFUNC_BUILDING_HEROES:
                        this.extendedPortrait = new EP_Altar_MC();
                        this.ri.addChild(this.extendedPortrait);
                        this.initBasicButtons();
                        this.actualizarBarraVida();
                        TextFieldUtil.setHTML(this.extendedPortrait.txNombre,_eElement.sName);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcAttack.txAttack,elementInfo.attack);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcDefense.txDefense,elementInfo.attack_interval);
                        TextFieldUtil.setHTML(this.extendedPortrait.mcRange.txRange,elementInfo.attack_range);
                        this.loadImage(elementInfo.img_name);
                        switch(_eElement.buildingReference.building.id)
                        {
                           case Constants.ID_BUILDING_HEROES_ALTAR:
                              this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openHeroes);
                              break;
                           case Constants.ID_BUILDING_HEROES_GRAVEYARD:
                              this.extendedPortrait.btnAbrir.addEventListener(MouseEvent.CLICK,this.openResHeroes);
                        }
                  }
               }
            }
            if(this.extendedPortrait != null)
            {
               if(this.extendedPortrait.mcAttack != null)
               {
                  this.extendedPortrait.mcAttack.buttonMode = true;
                  this.extendedPortrait.mcAttack.addEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                  this.extendedPortrait.mcAttack.addEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
               }
               if(this.extendedPortrait.mcDefense != null)
               {
                  this.extendedPortrait.mcDefense.buttonMode = true;
                  this.extendedPortrait.mcDefense.addEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                  this.extendedPortrait.mcDefense.addEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
               }
               if(this.extendedPortrait.mcRange != null)
               {
                  this.extendedPortrait.mcRange.buttonMode = true;
                  this.extendedPortrait.mcRange.addEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                  this.extendedPortrait.mcRange.addEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
               }
               if(this.extendedPortrait.mcSpeed != null)
               {
                  this.extendedPortrait.mcSpeed.buttonMode = true;
                  this.extendedPortrait.mcSpeed.addEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                  this.extendedPortrait.mcSpeed.addEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
               }
               if(this.extendedPortrait.mcPop != null)
               {
                  this.extendedPortrait.mcPop.buttonMode = true;
                  this.extendedPortrait.mcPop.addEventListener(MouseEvent.MOUSE_OVER,this.showTooltip);
                  this.extendedPortrait.mcPop.addEventListener(MouseEvent.MOUSE_OUT,this.removeTooltip);
               }
            }
            this.update();
         }
      }
      
      private function onSail(param1:Event) : void
      {
         PopupQuestsManager.loadWorldBarco(null);
      }
      
      private function onFly(param1:Event) : void
      {
         PopupQuestsManager.loadWorldZeppelin(null);
      }
      
      private function onSurvival(param1:MouseEvent) : void
      {
         Base.PopUp.openPopupSurvival(param1);
      }
      
      private function onShowOffer(param1:Event) : void
      {
         Base.Main.showOffer(this.eElement.buildingReference.building.id);
      }
      
      public function showTooltip(param1:Event) : void
      {
         var _loc2_:Point = null;
         if(this.ri != null && this.tooltip != null)
         {
            this.ri.removeChild(this.tooltip);
            this.tooltip = null;
         }
         _loc2_ = param1.currentTarget.parent.localToGlobal(new Point(param1.currentTarget.x,param1.currentTarget.y));
         _loc2_ = this.ri.globalToLocal(_loc2_);
         if(param1.currentTarget.name == "mcAttack")
         {
            this.tooltip = new TooltipSimbolosAtaqueMC();
            TextFieldUtil.setHTML(this.tooltip.tx,Language.getLiteral(Language.INFO_DANYO_ATAQUE));
         }
         else if(param1.currentTarget.name == "mcDefense")
         {
            this.tooltip = new TooltipSimbolosAtaqueMC();
            TextFieldUtil.setHTML(this.tooltip.tx,Language.getLiteral(Language.INFO_RETARDO_ATAQUE));
         }
         else if(param1.currentTarget.name == "mcRange")
         {
            this.tooltip = new TooltipSimbolosAtaqueMC();
            TextFieldUtil.setHTML(this.tooltip.tx,Language.getLiteral(Language.INFO_RANGO_ATAQUE));
         }
         else if(param1.currentTarget.name == "mcSpeed")
         {
            this.tooltip = new TooltipSimbolosAtaqueMC();
            TextFieldUtil.setHTML(this.tooltip.tx,Language.getLiteral(Language.INFO_VELOCIDAD_UNIDAD));
         }
         else if(param1.currentTarget.name == "mcPop")
         {
            this.tooltip = new TooltipSimbolosAtaqueMC();
            TextFieldUtil.setHTML(this.tooltip.tx,Language.getLiteral(Language.INFO_CAPACIDAD_POBLACION));
         }
         else if(param1.currentTarget.name == "limitDamage")
         {
            this.tooltip = new BufRemolinoMC();
            TextFieldUtil.setHTML(this.tooltip.txLock,Language.getLiteral(Language.LIMIT_DAMAGE));
         }
         else if(param1.currentTarget.name == "limitHeal")
         {
            this.tooltip = new BufRemolinoMC();
            TextFieldUtil.setHTML(this.tooltip.txLock,Language.getLiteral(Language.LIMIT_HEAL));
         }
         else if(param1.currentTarget.name == "limitStomp")
         {
            this.tooltip = new BufRemolinoMC();
            TextFieldUtil.setHTML(this.tooltip.txLock,Language.getLiteral(Language.LIMIT_STOMP));
         }
         if(this.tooltip != null)
         {
            this.tooltip.x = _loc2_.x;
            this.tooltip.y = _loc2_.y - 28;
            this.ri.addChild(this.tooltip);
         }
      }
      
      public function removeTooltip(param1:Event) : void
      {
         if(this.ri != null && this.tooltip != null)
         {
            if(this.ri.contains(this.tooltip))
            {
               this.ri.removeChild(this.tooltip);
            }
            this.tooltip = null;
         }
      }
      
      public function abrirCerrarMuralla(param1:Event) : void
      {
         if(this.extendedPortrait.btnAbrir.currentFrame == 1)
         {
            Tracing.Trace("abrirMuralla");
            this.extendedPortrait.btnAbrir.gotoAndStop(2);
            IsoBuilding(this.eElement).abrirCerrarMuralla(true);
            this.removeInitBasicButtons();
         }
         else
         {
            Tracing.Trace("cerrarMuralla");
            this.extendedPortrait.btnAbrir.gotoAndStop(1);
            IsoBuilding(this.eElement).abrirCerrarMuralla(false);
            this.initBasicButtons();
         }
      }
      
      public function openAlliesMarket(param1:Event) : void
      {
         var _loc2_:String = null;
         _loc2_ = String(Base.Main.resourceAlliesMarket);
         if(_loc2_ == "n")
         {
            Base.PopUp.openPopupSelectResource(IsoBuilding(this.eElement));
         }
         else
         {
            Base.PopUp.openPopupSocial(IsoBuilding(this.eElement));
         }
      }
      
      public function openMarket(param1:Event) : void
      {
         Base.PopUp.openPopupMarket();
      }
      
      public function openHeroes(param1:Event) : void
      {
         Base.PopUp.openPopupHeroes();
      }
      
      public function openSocialBuilding(param1:IsoBuilding) : void
      {
         Base.PopUp.openPopupSocial(param1);
      }
      
      public function openGraveyard(param1:Event) : void
      {
         Base.PopUp.openPopupGraveyard();
      }
      
      public function openDragonNest(param1:Event) : void
      {
         Base.PopUp.openPopupDragons();
      }
      
      public function openBahamutSupremeInvocationTemple(param1:Event) : void
      {
         Base.PopUp.openPopupBahamutSupremeInvocationTemple();
      }
      
      public function openMonsterNest(param1:Event) : void
      {
         Base.PopUp.openPopupMonstersNest();
      }
      
      public function openResHeroes(param1:Event) : void
      {
         Base.PopUp.openPopupResurrectHeroes();
      }
      
      public function openPopupRecruitment(param1:Event) : void
      {
         Base.PopUp.openPopupRecruitment(IsoBuilding(this.eElement));
      }
      
      private function openPopupRecruitmentPopulation(param1:Event) : void
      {
         Base.PopUp.openPopupRecruitmentPopulation(IsoBuilding(this.eElement));
      }
      
      public function openPopupSocialFeeds(param1:Event) : void
      {
         Base.PopUp.openPopupSocialFeeds(IsoBuilding(this.eElement));
      }
      
      public function openPopupWizardry(param1:Event) : void
      {
         Base.PopUp.openPopupWizardry();
      }
      
      public function openDragonRiders(param1:Event) : void
      {
         if(Base.Player.dragonRiderTrainingType == 0)
         {
            Base.PopUp.openPopupDragonRiders();
         }
         else
         {
            Base.PopUp.openPopupDragonRiderTraining();
         }
      }
      
      public function openDragonTaming(param1:Event) : void
      {
         Base.PopUp.openPopupDragonTaming();
      }
      
      public function actualizarBarraTiempo() : void
      {
         if(this.extendedPortrait.barraTiempo != null)
         {
            TextFieldUtil.setHTML(this.extendedPortrait.barraTiempo.timeLeft,"" + GameStatic.dhms(Math.max(this.eElement.activation - this.eElement.collected_at,0)));
            this.extendedPortrait.barraTiempo.percentMask.scaleX = Math.min(this.eElement.collected_at / this.eElement.activation,1);
            TextFieldUtil.setHTML(this.extendedPortrait.barraTiempo.percentText,"" + Math.min(int(this.eElement.collected_at / this.eElement.activation * 100),100) + "%");
         }
      }
      
      public function actualizarBarraVida() : void
      {
         var _loc1_:Number = NaN;
         if(this.extendedPortrait.mcVida != null)
         {
            _loc1_ = (1 - IsoFightingElement(this.eElement).iHealth / IsoFightingElement(this.eElement).maxLife) * this.extendedPortrait.mcVida.barVida.width;
            if(this.extendedPortrait.mcVida.barVida != null)
            {
               this.extendedPortrait.mcVida.barVida.barraRoja.width = _loc1_;
            }
            TextFieldUtil.setHTML(this.extendedPortrait.mcVida.txVida,IsoFightingElement(this.eElement).iHealth + "/" + IsoFightingElement(this.eElement).maxLife);
         }
      }
      
      public function loadImage(param1:String) : void
      {
         this.extendedPortrait.mcImageSelected.addChild(ImageManager.instance.getThumbImage(param1 + ".jpg").getRealSizeBitmap(ImageManagerResource.ONLY_ADJUST_SIZE));
      }
      
      public function loadImageContained(param1:MovieClip, param2:String) : void
      {
         param1.image.addChild(ImageManager.instance.getThumbImage(param2 + ".jpg").getBitmap(45,45,1,ImageManagerResource.ONLY_ADJUST_SIZE));
      }
      
      public function loadTrainableUnitInfo(param1:IsoElement) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:StaticData = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _loc4_ = StaticDataLibrary.api.getItem(IsoBuilding(param1).buildingReference.building.trains);
         this.extendedPortrait.mcImageTrainable.addChild(ImageManager.instance.getThumbImage(_loc4_.img_name + ".jpg").getBitmap(90,90,1,ImageManagerResource.ONLY_ADJUST_SIZE));
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcVida.txVida,_loc4_.life);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcAttack.txAttack,_loc4_.attack);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcDefense.txDefense,_loc4_.attack_interval);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcSpeed.txSpeed,_loc4_.velocity);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcRange.txRange,_loc4_.attack_range);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcPop.txPop,_loc4_.population);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.txNombre,_loc4_.name);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.txtTitle,Language.getLiteral(Language.INFOPOPUP_TRAIN));
         TextFieldUtil.setHTML(this.extendedPortrait.txNombreUnidad,_loc4_.name);
         if(_loc4_.subcat_functional == Constants.SUBCATFUNC_UNIT_PEASANT)
         {
            _loc5_ = Base.Iso.getTownHallLevel();
            _loc6_ = int(Config.VILLAGER_QUEUE[_loc5_]);
            TextFieldUtil.setHTML(this.extendedPortrait.menu.villagerExtraInfo.desc,Language.getLiteral(_loc6_ == 1 ? int(Language.INFO_LIMIT_RECOLECCION_SINGULAR) : int(Language.INFO_LIMIT_RECOLECCION_PLURAL),[_loc6_]));
            this.extendedPortrait.menu.villagerExtraInfo.visible = true;
         }
         else
         {
            this.extendedPortrait.menu.villagerExtraInfo.visible = false;
         }
         this.extendedPortrait.menu.visible = false;
         this.extendedPortrait.mcImageTrainable.addEventListener(MouseEvent.MOUSE_OVER,this.overTrainableUnit);
         this.extendedPortrait.mcImageTrainable.addEventListener(MouseEvent.MOUSE_OUT,this.outTrainableUnit);
         this.extendedPortrait.mcImageTrainable.addEventListener(MouseEvent.CLICK,this.trainUnit);
         this.extendedPortrait.mcImageTrainable.buttonMode = true;
         _loc2_ = _loc4_.cost;
         switch(_loc4_.subcat_functional)
         {
            case Constants.SUBCATFUNC_UNIT_ARCHER:
            case Constants.SUBCATFUNC_UNIT_FOOTMAN:
            case Constants.SUBCATFUNC_UNIT_MOUNTED:
               if(Base.Iso.eBlacksmith != null)
               {
                  _loc2_ = Math.ceil(_loc2_ * Config.REDUCTION_MULTIPLIER_BLACKSMITH);
               }
               break;
            case Constants.SUBCATFUNC_UNIT_SIEGE:
               if(Base.Iso.eUniversity != null)
               {
                  _loc2_ = Math.ceil(_loc2_ * Config.REDUCTION_MULTIPLIER_UNIVERSITY);
               }
         }
         TextFieldUtil.setHTML(this.extendedPortrait.cost,_loc2_ >= 10000 ? _loc2_ / 1000 + "k" : _loc2_);
         TextFieldUtil.setHTML(this.extendedPortrait.costText,Language.getLiteral(Language.INFO_COST));
         this.extendedPortrait.iconResources.gotoAndStop(GameStatic.typeCostToFrame(_loc4_.cost_type));
         if(this.extendedPortrait.iconResourcesFood != null)
         {
            _loc3_ = Math.ceil(_loc2_ * Config.FOOD_PER_GOLD_INTRAINING);
            TextFieldUtil.setHTML(this.extendedPortrait.costFood,_loc3_ >= 10000 ? _loc3_ / 1000 + "k" : _loc3_);
            this.extendedPortrait.iconResourcesFood.gotoAndStop(GameStatic.typeCostToFrame(CostType.FOOD));
         }
         if(this.extendedPortrait.mcBuyWithCash != null)
         {
            this.extendedPortrait.mcBuyWithCash.gotoAndStop(1);
            this.extendedPortrait.mcBuyWithCash.addEventListener(MouseEvent.MOUSE_OVER,this.overBuyWithCash);
            this.extendedPortrait.mcBuyWithCash.addEventListener(MouseEvent.MOUSE_OUT,this.outBuyWithCash);
            this.extendedPortrait.mcBuyWithCash.btnBuy.addEventListener(MouseEvent.CLICK,this.trainUnitWithCash);
            this.extendedPortrait.mcBuyWithCash.btnBuy.buttonMode = true;
            TextFieldUtil.setHTML(this.extendedPortrait.mcBuyWithCash.menuCash.txQuantity,_loc4_.cost_unit_cash);
            this.extendedPortrait.mcBuyWithCash.menuCash.getMoreCash.addEventListener(MouseEvent.CLICK,this.addCashButtonClick);
         }
      }
      
      private function addCashButtonClick(param1:MouseEvent) : void
      {
         Base.Main.gotoGold();
         Base.Main.setMouseToInquire();
      }
      
      private function overBuyWithCash(param1:Event) : void
      {
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.mcBuyWithCash.gotoAndStop(2);
         }
      }
      
      private function outBuyWithCash(param1:Event) : void
      {
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.mcBuyWithCash.gotoAndStop(1);
         }
      }
      
      private function onHurryup(param1:Event) : void
      {
         Base.PopUp.openPopupHurryup(IsoBuilding(this.eElement));
      }
      
      private function overTrainableUnit(param1:Event) : void
      {
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.menu.visible = true;
            this.extendedPortrait.mcImageTrainable.scaleX = this.extendedPortrait.mcImageTrainable.scaleY = 0.64;
            this.extendedPortrait.mcImageTrainable.x -= 2;
            this.extendedPortrait.mcImageTrainable.y -= 2;
         }
      }
      
      private function outTrainableUnit(param1:Event) : void
      {
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.menu.visible = false;
            this.extendedPortrait.mcImageTrainable.scaleX = this.extendedPortrait.mcImageTrainable.scaleY = 0.6;
            this.extendedPortrait.mcImageTrainable.x += 2;
            this.extendedPortrait.mcImageTrainable.y += 2;
         }
      }
      
      private function overUpgrade(param1:Event) : void
      {
         var _loc2_:StaticData = null;
         param1.currentTarget.scaleX = param1.currentTarget.scaleY = 1.1;
         if(this.eElement is IsoBuilding)
         {
            _loc2_ = IsoBuilding(this.eElement).getUpgradeBuilding();
            if(_loc2_ != null)
            {
               if(this.extendedPortrait != null)
               {
                  this.extendedPortrait.upgradeinfo.visible = true;
               }
            }
         }
      }
      
      private function outUpgrade(param1:Event) : void
      {
         param1.currentTarget.scaleX = param1.currentTarget.scaleY = 1;
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.upgradeinfo.visible = false;
         }
      }
      
      private function ioErrorHandler(... rest) : *
      {
      }
      
      public function updateEarns() : Boolean
      {
         var _loc1_:StaticData = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc2_:Boolean = false;
         if(this.eElement != null && this.eElement.buildingReference != null)
         {
            _loc1_ = new StaticData(this.eElement.buildingReference.building);
            if(this.extendedPortrait != null)
            {
               if(this.extendedPortrait.btHurryup != null)
               {
                  this.extendedPortrait.btHurryup.visible = false;
               }
               if(this.extendedPortrait.earns != null)
               {
                  if(this.eElement is IsoBuilding && IsoBuilding(this.eElement).iUnitCapacity > 0)
                  {
                     if(IsoBuilding(this.eElement).vUnitsContained.length > 0)
                     {
                        _loc3_ = 1;
                        if(PopupCollect.doShit(this.eElement))
                        {
                           if(PopupCollect.hasShit(this.eElement))
                           {
                              _loc4_ = parseInt(this.eElement.buildingReference.loaded.attrs.cp);
                              _loc3_ = Number(Config.COLLECT_MULTIPLIER[_loc4_ - 1]);
                           }
                        }
                        TextFieldUtil.setHTML(this.extendedPortrait.earns,Math.floor(Math.floor(_loc1_.collect + (IsoBuilding(this.eElement).vUnitsContained.length - 1) * _loc1_.collect * Config.MULTIPLIER_PEASANTS) * _loc3_));
                        this.extendedPortrait.earns.visible = true;
                        this.extendedPortrait.barraTiempo.visible = true;
                        this.checkHurryUp(_loc1_);
                     }
                     else
                     {
                        this.extendedPortrait.earns.visible = false;
                        this.extendedPortrait.barraTiempo.visible = false;
                     }
                  }
                  else
                  {
                     TextFieldUtil.setHTML(this.extendedPortrait.earns,_loc1_.collect);
                     this.extendedPortrait.earns.visible = true;
                     this.extendedPortrait.barraTiempo.visible = true;
                     this.checkHurryUp(_loc1_);
                  }
                  this.extendedPortrait.iconResources.gotoAndStop(GameStatic.typeCostToFrame(_loc1_.collect_type));
                  if(_loc1_.collect_type == "none")
                  {
                     this.extendedPortrait.earns.visible = false;
                     this.extendedPortrait.barraTiempo.visible = false;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      public function checkHurryUp(param1:StaticData) : void
      {
         if(this.extendedPortrait.btHurryup != null)
         {
            switch(param1.subcat_functional)
            {
               case Constants.SUBCATFUNC_BUILDING_COLLECT:
               case Constants.SUBCATFUNC_BUILDING_MINE:
               case Constants.SUBCATFUNC_BUILDING_MILL:
                  this.extendedPortrait.btHurryup.visible = true;
                  this.extendedPortrait.btHurryup.addEventListener(MouseEvent.CLICK,this.onHurryup);
               case Constants.SUBCATFUNC_BUILDING_WONDER:
                  if(param1.population == 0)
                  {
                     this.extendedPortrait.btHurryup.visible = true;
                     this.extendedPortrait.btHurryup.addEventListener(MouseEvent.CLICK,this.onHurryup);
                  }
            }
         }
      }
      
      public function initBasicButtons() : void
      {
         var _loc1_:StaticData = null;
         var _loc2_:Array = null;
         if(this.eElement.PlayerID != Constants.PLAYER_SELF || Base.Main.gameMode == Constants.GAME_MODE_SURVIVAL && this.eElement.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_RELIC || this.eElement.buildingReference.building.id == Constants.ID_BUILDING_BLUE_PHOENIXEGG || this.eElement.inConstruction)
         {
            this.extendedPortrait.btMove.visible = false;
            this.extendedPortrait.btFlip.visible = false;
            if(this.extendedPortrait.btSell != null)
            {
               this.extendedPortrait.btSell.visible = false;
            }
            if(this.extendedPortrait.btPutInStorage != null)
            {
               this.extendedPortrait.btPutInStorage.visible = false;
            }
         }
         else
         {
            this.extendedPortrait.btMove.visible = true;
            this.extendedPortrait.btFlip.visible = true;
            if(this.extendedPortrait.btPutInStorage != null)
            {
               this.extendedPortrait.btPutInStorage.visible = true;
            }
            this.extendedPortrait.btMove.addEventListener(MouseEvent.CLICK,this.moveItem);
            this.extendedPortrait.btFlip.addEventListener(MouseEvent.MOUSE_DOWN,this.flipItem);
            if(this.extendedPortrait.btPutInStorage != null)
            {
               this.extendedPortrait.btPutInStorage.addEventListener(MouseEvent.MOUSE_DOWN,this.putItemInStorage);
            }
            if(this.extendedPortrait.btSell != null)
            {
               this.extendedPortrait.btSell.visible = true;
               this.extendedPortrait.btSell.addEventListener(MouseEvent.MOUSE_DOWN,this.upgradeItem);
               this.extendedPortrait.btSell.addEventListener(MouseEvent.MOUSE_OVER,this.overUpgrade);
               this.extendedPortrait.btSell.addEventListener(MouseEvent.MOUSE_OUT,this.outUpgrade);
               TextFieldUtil.setHTML(this.extendedPortrait.btSell.lbl,Language.getLiteral(Language.ICON_UPGRADE));
            }
         }
         if(this.extendedPortrait.btSell != null)
         {
            this.extendedPortrait.btSell.visible = false;
            if(this.eElement is IsoBuilding)
            {
               _loc1_ = IsoBuilding(this.eElement).getUpgradeBuilding();
               if(_loc1_ != null)
               {
                  this.extendedPortrait.btSell.visible = true;
                  this.extendedPortrait.upgradeinfo.mcFoto.addChild(ImageManager.instance.getThumbImage(_loc1_.img_name + ".jpg").getBitmap(81,81,1,ImageManagerResource.ONLY_ADJUST_SIZE));
                  TextFieldUtil.setHTML(this.extendedPortrait.upgradeinfo.nom,_loc1_.name);
                  if(Base.Player.iLevel < _loc1_.min_level)
                  {
                     TextFieldUtil.setHTML(this.extendedPortrait.upgradeinfo.unlock.levelText,_loc1_.min_level);
                     this.extendedPortrait.upgradeinfo.unlock.visible = true;
                  }
                  else
                  {
                     this.extendedPortrait.upgradeinfo.unlock.visible = false;
                     _loc2_ = Base.Iso.getDifferenceCost(this.eElement.buildingReference.building,_loc1_);
                     TextFieldUtil.setHTML(this.extendedPortrait.upgradeinfo.earns,_loc2_[0]);
                     this.extendedPortrait.upgradeinfo.iconResources.gotoAndStop(GameStatic.typeCostToFrame(_loc2_[1]));
                  }
               }
            }
            this.extendedPortrait.upgradeinfo.visible = false;
         }
      }
      
      public function removeInitBasicButtons() : void
      {
         this.extendedPortrait.btMove.removeEventListener(MouseEvent.CLICK,this.moveItem);
         this.extendedPortrait.btFlip.removeEventListener(MouseEvent.MOUSE_DOWN,this.flipItem);
         this.extendedPortrait.btSell.removeEventListener(MouseEvent.MOUSE_DOWN,this.upgradeItem);
         this.extendedPortrait.btSell.removeEventListener(MouseEvent.MOUSE_OVER,this.overUpgrade);
         this.extendedPortrait.btSell.removeEventListener(MouseEvent.MOUSE_OUT,this.outUpgrade);
         this.extendedPortrait.btSell.buttonMode = true;
         if(this.extendedPortrait.btPutInStorage != null)
         {
            this.extendedPortrait.btPutInStorage.removeEventListener(MouseEvent.MOUSE_DOWN,this.putItemInStorage);
         }
      }
      
      public function initContainedPortraits() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:PortraitMC = null;
         _loc1_ = 1;
         _loc3_ = 0;
         while(_loc3_ < 2)
         {
            _loc2_ = 0;
            while(_loc2_ < 3)
            {
               var _temp_1:* = new PortraitMC();
               _loc4_ = new PortraitMC();
               _loc4_.x = _loc2_ * 50;
               _loc4_.y = _loc3_ * 50;
               _loc4_.name = "portrait" + _loc1_;
               _loc1_++;
               this.extendedPortrait.mcContained.addChild(_loc4_);
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      public function update() : void
      {
         if(this.extendedPortrait == null)
         {
            return;
         }
         if(this.eElement != null)
         {
            if(this.eElement is IsoFightingElement)
            {
               this.actualizarBarraVida();
            }
            if(this.eElement is IsoBuilding && IsoBuilding(this.eElement).iUnitCapacity > 0)
            {
               this.refreshContained();
            }
            this.actualizarBarraTiempo();
            if(this.eElement.buildingReference.building.id == Constants.ID_BUILDING_FORTRESS_1)
            {
               this.extendedPortrait.mcAttack.txAttack.text = this.eElement.buildingReference.building.attack + (Base.Main.gameMode == Constants.GAME_MODE_ASSAULT ? IsoBuilding(this.eElement).buildingReference.loaded.units.length : IsoBuilding(this.eElement).vUnitsContained.length) * FortressDelegate.DMG_ARROW;
            }
         }
      }
      
      public function initTrainingPortrait(param1:IsoInteractiveElement, param2:StaticData) : void
      {
         this.extendedPortrait = new EP_NewBarracksMC();
         this.ri.addChild(this.extendedPortrait);
         // initBasicButtons expects the move, rotate and store buttons at the top level
         this.extendedPortrait.btMove = this.extendedPortrait.menuTools.btMove;
         this.extendedPortrait.btFlip = this.extendedPortrait.menuTools.btFlip;
         this.extendedPortrait.btPutInStorage = this.extendedPortrait.menuTools.btPutInStorage;
         this.initBasicButtons();
         this.extendedPortrait.menuTools.visible = false;
         this.extendedPortrait.btTools.visible = this.extendedPortrait.btMove.visible;
         this.extendedPortrait.btTools.addEventListener(MouseEvent.MOUSE_DOWN,this.showHideTools);
         this.actualizarBarraVida();
         TextFieldUtil.setHTML(this.extendedPortrait.txNombre,param1.sName);
         this.loadImage(param2.img_name);
         this.loadTrainingUnitInfo(IsoBuilding(param1));
         this.vQueueThumbs = [];
         this.refreshTrainingQueue();
      }
      
      private function loadTrainingUnitInfo(param1:IsoBuilding) : void
      {
         var _loc2_:StaticData = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Loader = null;
         var _loc7_:MovieClip = this.extendedPortrait.trainUnit;
         var _loc8_:MovieClip = this.extendedPortrait.speedup;
         _loc2_ = StaticDataLibrary.api.getItem(param1.buildingReference.building.trains);
         this.extendedPortrait.mcImageTrainable.thumb.addChild(ImageManager.instance.getThumbImage(_loc2_.img_name + ".jpg").getBitmap(64,64,1,ImageManagerResource.ONLY_ADJUST_SIZE));
         this.trainingPie = new Sprite();
         this.trainingPie.alpha = 0.8;
         this.extendedPortrait.mcImageTrainable.thumb.addChild(this.trainingPie);
         this.extendedPortrait.mcImageTrainable.addEventListener(MouseEvent.CLICK,this.trainUnit);
         this.extendedPortrait.mcImageTrainable.buttonMode = true;
         this.extendedPortrait.txRemaining.visible = false;
         TextFieldUtil.setHTML(this.extendedPortrait.txTrainingUnit,_loc2_.name);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcVida.txVida,_loc2_.life);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcAttack.txAttack,_loc2_.attack);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcDefense.txDefense,_loc2_.attack_interval);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcSpeed.txSpeed,_loc2_.velocity);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcRange.txRange,_loc2_.attack_range);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.mcPop.txPop,_loc2_.population);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.txNombre,_loc2_.name);
         TextFieldUtil.setHTML(this.extendedPortrait.menu.txtTitle,Language.getLiteral(Language.INFOPOPUP_TRAIN));
         if(_loc2_.subcat_functional == Constants.SUBCATFUNC_UNIT_PEASANT)
         {
            _loc5_ = int(Config.VILLAGER_QUEUE[Base.Iso.getTownHallLevel()]);
            TextFieldUtil.setHTML(this.extendedPortrait.menu.villagerExtraInfo.desc,Language.getLiteral(_loc5_ == 1 ? int(Language.INFO_LIMIT_RECOLECCION_SINGULAR) : int(Language.INFO_LIMIT_RECOLECCION_PLURAL),[_loc5_]));
            this.extendedPortrait.menu.villagerExtraInfo.visible = true;
         }
         else
         {
            this.extendedPortrait.menu.villagerExtraInfo.visible = false;
         }
         this.extendedPortrait.menu.visible = false;
         // Same prices UnitTrainingStart charges
         _loc3_ = _loc2_.cost;
         switch(_loc2_.subcat_functional)
         {
            case Constants.SUBCATFUNC_UNIT_ARCHER:
            case Constants.SUBCATFUNC_UNIT_FOOTMAN:
            case Constants.SUBCATFUNC_UNIT_MOUNTED:
               if(Base.Iso.eBlacksmith != null)
               {
                  _loc3_ = Math.ceil(_loc3_ * Config.REDUCTION_MULTIPLIER_BLACKSMITH);
               }
               break;
            case Constants.SUBCATFUNC_UNIT_SIEGE:
               if(Base.Iso.eUniversity != null)
               {
                  _loc3_ = Math.ceil(_loc3_ * Config.REDUCTION_MULTIPLIER_UNIVERSITY);
               }
         }
         _loc4_ = _loc2_.subcat_functional == Constants.SUBCATFUNC_UNIT_PEASANT ? 0 : int(Math.ceil(_loc3_ * Config.FOOD_PER_GOLD_INTRAINING));
         TextFieldUtil.setHTML(_loc7_.txtTitle,Language.getLiteral(LITERAL_TRAIN));
         TextFieldUtil.setHTML(_loc7_.cost,_loc3_ >= 10000 ? _loc3_ / 1000 + "k" : _loc3_);
         TextFieldUtil.setHTML(_loc7_.costFood,_loc4_ >= 10000 ? _loc4_ / 1000 + "k" : _loc4_);
         TextFieldUtil.setHTML(_loc7_.txCostTime,int(param1.uiTrainingTime / 1000) + "s");
         _loc6_ = new Loader();
         _loc6_.load(new URLRequest(Base.Main.apfx + "externalized/RecuadroInfo/clock.png"));
         _loc7_.clock.addChild(_loc6_);
         _loc7_.addEventListener(MouseEvent.MOUSE_OVER,this.overTrainUnitButton);
         _loc7_.addEventListener(MouseEvent.MOUSE_OUT,this.outTrainUnitButton);
         _loc7_.addEventListener(MouseEvent.CLICK,this.trainUnit);
         _loc7_.buttonMode = true;
         // The 1.1.5 speed up bar trains the unit with cash instead: training takes seconds here
         TextFieldUtil.setHTML(_loc8_.txtSpeedUpTitle,Language.getLiteral(LITERAL_TRAIN_WITH_CASH));
         TextFieldUtil.setHTML(_loc8_.txSpeedupCost,_loc2_.cost_unit_cash);
         _loc8_.mouseChildren = false;
         if(_loc2_.cost_unit_cash > 0)
         {
            _loc8_.addEventListener(MouseEvent.CLICK,this.trainUnitWithCash);
            _loc8_.buttonMode = true;
         }
         else
         {
            _loc8_.alpha = 0.4;
         }
      }
      
      public function refreshTrainingQueue() : void
      {
         var _loc1_:IsoBuilding = null;
         var _loc2_:StaticData = null;
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc5_:DisplayObject = null;
         if(!(this.extendedPortrait is EP_NewBarracksMC) || !(this.eElement is IsoBuilding))
         {
            return;
         }
         _loc1_ = IsoBuilding(this.eElement);
         for each(_loc5_ in this.vQueueThumbs)
         {
            if(_loc5_.parent != null)
            {
               _loc5_.parent.removeChild(_loc5_);
            }
         }
         this.vQueueThumbs = [];
         _loc2_ = StaticDataLibrary.api.getItem(_loc1_.buildingReference.building.trains);
         _loc3_ = 0;
         while(_loc3_ < IsoBuilding.MAX_TRAINING_QUEUE)
         {
            _loc4_ = this.extendedPortrait["queuePortrait" + (_loc3_ + 1)];
            _loc4_.removeEventListener(MouseEvent.CLICK,this.cancelTrainingUnit);
            _loc4_.buttonMode = false;
            if(_loc3_ < _loc1_.getTrainingCount())
            {
               _loc5_ = _loc4_.addChild(ImageManager.instance.getThumbImage(_loc2_.img_name + ".jpg").getBitmap(25,25,1,ImageManagerResource.ONLY_ADJUST_SIZE));
               this.vQueueThumbs.push(_loc5_);
               _loc4_.addEventListener(MouseEvent.CLICK,this.cancelTrainingUnit);
               _loc4_.buttonMode = true;
            }
            _loc3_++;
         }
         if(!_loc1_.bTrainingUnit)
         {
            this.extendedPortrait.txRemaining.visible = false;
            if(this.trainingPie != null)
            {
               this.trainingPie.graphics.clear();
            }
         }
      }
      
      private function refreshTrainingTime(param1:Number) : void
      {
         var _loc2_:Number = 1 - Math.min(Math.max(param1,0),1);
         var _loc3_:int = Math.ceil(_loc2_ * IsoBuilding(this.eElement).uiTrainingTime / 1000);
         var _loc4_:String = "";
         if(_loc3_ >= 3600)
         {
            _loc4_ += int(_loc3_ / 3600) + "h ";
         }
         if(_loc3_ >= 60)
         {
            _loc4_ += int(_loc3_ % 3600 / 60) + "\' ";
         }
         _loc4_ += _loc3_ % 60 + "\'\'";
         TextFieldUtil.setHTML(this.extendedPortrait.txRemaining,_loc4_);
         this.extendedPortrait.txRemaining.visible = true;
         if(this.trainingPie != null)
         {
            this.drawPie(this.trainingPie.graphics,_loc2_,50,37,37,-Math.PI / 2);
         }
      }
      
      // From 1.1.5 EP_SelfBarracksBuilding.drawPieMask
      private function drawPie(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:int = 10) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         param1.clear();
         param1.beginFill(6710886);
         param1.moveTo(param4,param5);
         param3 /= Math.cos(1 / param7 * Math.PI);
         _loc8_ = Math.floor(param2 * param7);
         _loc9_ = 0;
         while(_loc9_ <= _loc8_)
         {
            _loc10_ = _loc9_ / param7 * (Math.PI * 2) + param6;
            param1.lineTo(Math.cos(_loc10_) * param3 * -1 + param4,Math.sin(_loc10_) * param3 + param5);
            _loc9_++;
         }
         if(param2 * param7 != _loc8_)
         {
            _loc10_ = param2 * (Math.PI * 2) + param6;
            param1.lineTo(Math.cos(_loc10_) * param3 * -1 + param4,Math.sin(_loc10_) * param3 + param5);
         }
         param1.endFill();
      }
      
      private function cancelTrainingUnit(param1:MouseEvent) : void
      {
         if(this.eElement is IsoBuilding)
         {
            IsoBuilding(this.eElement).cancelLastTrainingUnit();
         }
      }
      
      private function showHideTools(param1:MouseEvent) : void
      {
         if(this.extendedPortrait != null && this.extendedPortrait.menuTools != null)
         {
            this.extendedPortrait.menuTools.visible = !this.extendedPortrait.menuTools.visible;
         }
      }
      
      private function overTrainUnitButton(param1:Event) : void
      {
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.trainUnit.scaleX = this.extendedPortrait.trainUnit.scaleY = 1.05;
            --this.extendedPortrait.trainUnit.x;
            --this.extendedPortrait.trainUnit.y;
            this.extendedPortrait.menu.visible = true;
         }
      }
      
      private function outTrainUnitButton(param1:Event) : void
      {
         if(this.extendedPortrait != null)
         {
            this.extendedPortrait.trainUnit.scaleX = this.extendedPortrait.trainUnit.scaleY = 1;
            this.extendedPortrait.trainUnit.x += 1;
            this.extendedPortrait.trainUnit.y += 1;
            this.extendedPortrait.menu.visible = false;
         }
      }
      
      public function trainUnit(param1:Event) : void
      {
         if(this.eElement != null && this.eElement is IsoBuilding)
         {
            IsoBuilding(this.eElement).UnitTrainingStart();
         }
         Base.Main.hideArrow();
         if(Base.Gui.missionBox != null)
         {
            Base.Gui.missionBox.closeAllPopups();
         }
      }
      
      public function trainUnitWithCash(param1:Event) : void
      {
         if(this.eElement != null && this.eElement is IsoBuilding)
         {
            IsoBuilding(this.eElement).UnitTrainingStart(true);
         }
         Base.Main.hideArrow();
         if(Base.Gui.missionBox != null)
         {
            Base.Gui.missionBox.closeAllPopups();
         }
      }
      
      public function refreshTrained() : void
      {
      }
      
      public function refreshCollect() : void
      {
      }
      
      public function refreshContained() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Portrait = null;
         var _loc4_:PortraitMC = null;
         if(this.extendedPortrait.mcContained != null)
         {
            if(this.eElement is IsoBuilding)
            {
               this.vUnitsContained = IsoBuilding(this.eElement).vUnitsContained;
               _loc2_ = int(this.vUnitsContained.length);
               _loc1_ = 0;
               while(_loc1_ < 6)
               {
                  _loc4_ = this.extendedPortrait.mcContained.getChildByName("portrait" + (_loc1_ + 1));
                  if(_loc4_ != null)
                  {
                     if(_loc2_ > _loc1_)
                     {
                        _loc4_.visible = true;
                        _loc4_.barraVida.barraRoja.width = 0;
                        _loc4_.addEventListener(MouseEvent.MOUSE_DOWN,this.clickContained);
                        _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.overMcContained);
                        _loc4_.addEventListener(MouseEvent.MOUSE_OUT,this.outMcContained);
                        _loc4_.buttonMode = true;
                        this.loadImageContained(_loc4_,this.vUnitsContained[_loc1_].buildingReference.building.img_name);
                     }
                     else
                     {
                        _loc4_.visible = false;
                     }
                  }
                  else
                  {
                     Tracing.Trace("panic");
                  }
                  _loc1_++;
               }
            }
            if(_loc2_ == 0)
            {
               if(IsoBuilding(this.eElement).iUnitCapacity == 0)
               {
                  this.extendedPortrait.txCapacity.visible = false;
               }
            }
            else
            {
               TextFieldUtil.setHTML(this.extendedPortrait.mcContained.txTip,"");
            }
         }
         if(this.extendedPortrait.txCapacity != null)
         {
            TextFieldUtil.setHTML(this.extendedPortrait.txCapacity,Language.getLiteral(Language.INFO_CAPACIDAD,[IsoBuilding(this.eElement).vUnitsContained.length,IsoBuilding(this.eElement).buildingReference.building.unit_capacity]));
         }
      }
      
      public function clickContained(param1:Event) : void
      {
         var _loc2_:IsoUnit = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         _loc3_ = param1.currentTarget.name;
         _loc3_ = _loc3_.substr(8,1);
         _loc4_ = parseInt(_loc3_);
         if(this.eElement != null && this.eElement is IsoBuilding && this.eElement.buildingReference != null && this.eElement.buildingReference.building.unit_capacity > 0)
         {
            this.vUnitsContained = IsoBuilding(this.eElement).vUnitsContained;
            _loc2_ = this.vUnitsContained[_loc4_ - 1];
            if(_loc2_ != null)
            {
               IsoBuilding(this.eElement).PopUnit(_loc2_,true,false);
            }
         }
      }
      
      public function overMcContained(param1:Event) : void
      {
         param1.currentTarget.scaleX = param1.currentTarget.scaleY = 1.2;
         param1.currentTarget.x -= 5;
         param1.currentTarget.y -= 5;
      }
      
      public function outMcContained(param1:Event) : void
      {
         param1.currentTarget.scaleX = param1.currentTarget.scaleY = 1;
         param1.currentTarget.x += 5;
         param1.currentTarget.y += 5;
      }
      
      public function moveItem(param1:Event) : void
      {
         if(Base.Main.selectedItem != null)
         {
            if(Base.Main.selectedItem.mc != null && Base.Main.selectedItem.mc.fauxBar != null)
            {
               return;
            }
            Base.Main.unhighlightBuilding();
            Base.Main.removeDirectBuilding(Base.Main.selectedItem,false);
            Base.Main.moveItem(Base.Main.selectedItem);
         }
      }
      
      public function flipItem(param1:Event) : void
      {
         if(Base.Main.selectedItem != null)
         {
            Base.Main.selectedItem.mc.changeDirection();
         }
      }
      
      public function sellItem(param1:Event) : void
      {
         var _loc4_:String = null;
         var _loc2_:int = undefined;
         var _loc3_:BuildingReference = Base.Main.selectedItem;
         if(Base.Main.selectedItem != null)
         {
            if(Base.Main.selectedItem.mc != null && Base.Main.selectedItem.mc.fauxBar != null)
            {
               return;
            }
            if(_loc3_.building.cost > 0)
            {
               Base.Main.bulldozeInd = _loc3_.tx + _loc3_.ty * Config.EI_MAP_WIDTH;
               _loc2_ = Math.floor(_loc3_.building.cost / Config.DIVISOR_SELL);
               if(Config.SELL_FOR_ZERO_CASH && _loc3_.building.cost_type == CostType.CASH)
               {
                  _loc2_ = 0;
               }
               _loc4_ = "";
               switch(_loc3_.building.cost_type)
               {
                  case CostType.GOLD:
                     _loc4_ = Language.getLiteral(_loc2_ == 1 ? int(Language.INFO_ORO_SINGULAR) : int(Language.INFO_ORO_PLURAL));
                     break;
                  case CostType.FOOD:
                     _loc4_ = Language.getLiteral(_loc2_ == 1 ? int(Language.INFO_COMIDA_SINGULAR) : int(Language.INFO_COMIDA_PLURAL));
                     break;
                  case CostType.WOOD:
                     _loc4_ = Language.getLiteral(_loc2_ == 1 ? int(Language.INFO_MADERA_SINGULAR) : int(Language.INFO_MADERA_PLURAL));
                     break;
                  case CostType.STONE:
                     _loc4_ = Language.getLiteral(_loc2_ == 1 ? int(Language.INFO_PIEDRA_SINGULAR) : int(Language.INFO_PIEDRA_PLURAL));
                     break;
                  case CostType.CASH:
                     _loc4_ = Language.getLiteral(_loc2_ == 1 ? int(Language.INFO_CASH_SINGULAR) : int(Language.INFO_CASH_PLURAL));
               }
               Base.PopUp.confirm(Language.getLiteral(Language.INFO_CONFIRMAR_VENTA,[_loc2_,_loc4_]),Base.Main.bulldozeBuilding,null);
            }
            else
            {
               this.removeItem();
            }
            Base.Main.unhighlightBuilding();
         }
      }
      
      public function upgradeItem(param1:Event) : void
      {
         var _loc2_:BuildingReference = Base.Main.selectedItem;
         if(_loc2_ != null && _loc2_.mc != null && _loc2_.mc is IsoBuilding)
         {
            if(IsoBuilding(_loc2_.mc).upgrade())
            {
               Base.Main.deseleccionarElementos();
            }
         }
      }
      
      public function removeItem(... rest) : *
      {
         var _loc2_:BuildingReference = Base.Main.selectedItem;
         if(!(Config.SELL_FOR_ZERO_CASH && _loc2_.building.cost_type == CostType.CASH))
         {
            Base.Player.adjustStatByType(Math.floor(_loc2_.building.cost / Config.DIVISOR_SELL),_loc2_.building.cost_type,0);
         }
         Base.Main.removeDirectBuilding(Base.Main.selectedItem,true,Constants.SELL_REASON_RECUADROINFO);
         Base.Main.unhighlightBuilding();
      }
      
      public function putItemInStorage(param1:Event) : void
      {
         if(Base.Main.selectedItem != null)
         {
            if(Base.Main.selectedItem.mc != null && Base.Main.selectedItem.mc.fauxBar != null)
            {
               return;
            }
            if(Base.Main.mState == Constants.STATE_MOVING)
            {
               return;
            }
            Base.Main.unhighlightBuilding();
            Base.Main.removeDirectBuilding(Base.Main.selectedItem,false);
            Base.Main.storeItem(Base.Main.selectedItem);
         }
      }
   }
}

