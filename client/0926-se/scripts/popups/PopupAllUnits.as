package popups
{
   import battle.*;
   import com.socialpoint.ObfuscatedNumber;
   import com.socialpoint.obfuscated.OData;
   import core.*;
   import core.isoengine.*;
   import core.statics.*;
   import flash.display.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.*;
   import flash.text.*;
   import flash.utils.Timer;
   import managers.ImageManager;
   import managers.UnitCollectionsManager;
   import managers.images.ImageManagerResource;
   import utils.TextFieldUtil;
   
   public class PopupAllUnits extends PopupAllUnitsMC
   {
      
      public static var ALL_UNITS:Array;
      
      public static var categoryTitles:Array;
      
      private const THUMB_WIDTH:int = 120;
      
      private const THUMB_HEIGHT_CONDESC:int = 90;
      
      private const THUMB_HEIGHT_SINDESC:int = 120;
      
      private const THUMB_MARGIN:int = 8;
      
      private const MIN_RATIO:Number = 1;
      
      private const COLUMNES:int = 5;
      
      private const FILES:int = 4;
      
      private const SEPARACIO_HORITZONTAL:int = 0;
      
      private const SEPARACIO_VERTICAL:int = 0;
      
      private var vUnits:Vector.<Vector.<UnitListMC>>;
      
      public var categoryOffset:int = 0;
      
      private var tooltip:MovieClip;
      
      private var tooltipTimer:Timer;
      
      private var actualCollection:uint;
      
      private var categoryUnitsObj:OData;
      
      private var ucm:UnitCollectionsManager;
      
      public function PopupAllUnits(param1:int, param2:int)
      {
         super();
         this.categoryUnitsObj = Base.Items.unitCollectionCategories.clone();
         this.categoryUnitsObj.sortOn(["position"],[Array.NUMERIC]);
         this.ucm = Base.UnitCollections;
         TextFieldUtil.setHTML(lblObtained,Language.getLiteral(Language.POPUP_ALL_UNITS_OBTAINED));
         TextFieldUtil.setHTML(progressBar.percentText,this.ucm.totalUnits + " / " + this.ucm.totalToBuy);
         progressBar.percentMask.scaleX = this.ucm.totalUnits / this.ucm.totalToBuy;
         this.x = param1;
         this.y = param2;
         Base.Gui.addGuiCover(Base.Gui);
         TextFieldUtil.setHTML(this.txTitle,Language.getLiteral(Language.POPUP_ALL_UNITS_TITLE));
         TextFieldUtil.setHTML(btnOk.lbl,Language.getLiteral(Language.AUX_OK));
         btnOk.buttonMode = true;
         btnOk.gotoAndStop(0);
         btnOk.hitZone.addEventListener(MouseEvent.CLICK,this.onClose);
         btnOk.hitZone.addEventListener(MouseEvent.ROLL_OVER,GameStatic.startFloat);
         btnOk.hitZone.addEventListener(MouseEvent.ROLL_OUT,GameStatic.stopFloat);
         closeButt.addEventListener(MouseEvent.MOUSE_UP,this.onClose);
         left.addEventListener(MouseEvent.CLICK,this.prevPage);
         left.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         left.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         right.addEventListener(MouseEvent.CLICK,this.nextPage);
         right.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         right.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.init();
         this.refresh();
      }
      
      public function init() : void
      {
         var _loc1_:int = 0;
         var _loc3_:UnitListMC = null;
         var _loc4_:Sprite = null;
         var _loc5_:Sprite = null;
         _loc1_ = 0;
         var _loc2_:int = 0;
         this.vUnits = new Vector.<Vector.<UnitListMC>>();
         _loc1_ = 0;
         while(_loc1_ < this.FILES)
         {
            this.vUnits[_loc1_] = new Vector.<UnitListMC>();
            _loc2_ = 0;
            while(_loc2_ < this.COLUMNES)
            {
               _loc3_ = new UnitListMC();
               _loc4_ = new Sprite();
               _loc4_.graphics.beginFill(0,0);
               _loc4_.graphics.drawRect(_loc3_.frame.x,_loc3_.frame.y,_loc3_.frame.width,_loc3_.frame.height);
               _loc4_.graphics.endFill();
               _loc3_.addChild(_loc4_);
               _loc3_.area = _loc4_;
               if(_loc2_ > 0)
               {
                  _loc3_.removeChild(_loc3_.lblCategory);
                  _loc3_.removeChild(_loc3_.butGetReward);
                  _loc3_.removeChild(_loc3_.lblCompleted);
               }
               _loc5_ = new Sprite();
               _loc5_.x = 6;
               _loc3_.addChildAt(_loc5_,0);
               this.vUnits[_loc1_][_loc2_] = _loc3_;
               _loc3_.x = _loc2_ * (104 + this.SEPARACIO_HORITZONTAL);
               _loc3_.y = _loc1_ * (_loc3_.height + this.SEPARACIO_VERTICAL);
               content.addChild(_loc3_);
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function refresh() : void
      {
         var _loc3_:UnitListMC = null;
         var _loc4_:Sprite = null;
         var _loc5_:int = 0;
         var _loc6_:StaticData = null;
         var _loc7_:Boolean = false;
         var _loc8_:uint = 0;
         var _loc9_:OData = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this.FILES)
         {
            _loc9_ = this.categoryUnitsObj.index(this.categoryOffset + _loc1_,true) as OData;
            _loc8_ = 0;
            _loc10_ = _loc9_ != null ? _loc9_.getArray("units") : [];
            _loc2_ = 0;
            while(_loc2_ < this.COLUMNES)
            {
               _loc3_ = this.vUnits[_loc1_][_loc2_];
               if(_loc9_ == null)
               {
                  _loc3_.visible = false;
               }
               else
               {
                  if(_loc2_ == 0)
                  {
                     TextFieldUtil.setHTML(_loc3_.lblCategory,Language.getLiteral(_loc9_.getInt("category_lang_id")));
                     _loc3_.butGetReward.visible = false;
                     _loc3_.lblCompleted.visible = false;
                  }
                  _loc3_.lblCounter.visible = false;
                  _loc3_.cost = new ObfuscatedNumber();
                  if(_loc9_.has("costs") && _loc9_.get("costs") != "")
                  {
                     _loc11_ = _loc9_.getArray("costs");
                     if(_loc11_.length > _loc2_)
                     {
                        _loc3_.cost.value = _loc11_[_loc2_];
                     }
                     else
                     {
                        _loc3_.cost.value = _loc9_.getInt("cost");
                     }
                  }
                  else
                  {
                     _loc3_.cost.value = _loc9_.getInt("cost");
                  }
                  if(_loc2_ < _loc10_.length)
                  {
                     _loc6_ = StaticDataLibrary.api.getItem(_loc10_[_loc2_]);
                     _loc4_ = _loc3_.getChildAt(0) as Sprite;
                     while(_loc4_.numChildren > 0)
                     {
                        _loc4_.removeChildAt(0);
                     }
                     _loc4_.addChild(ImageManager.instance.getThumbImage(_loc6_.img_name + ".jpg").getRealSizeBitmap(ImageManagerResource.ONLY_ADJUST_SIZE));
                     TextFieldUtil.setHTML(_loc3_.lblName,_loc6_.name);
                     _loc7_ = this.ucm.boughtUnits[_loc10_[_loc2_]] != null;
                     _loc3_.sd = _loc6_;
                     _loc3_.owned = _loc7_;
                     if(!_loc3_.hasEventListener(MouseEvent.MOUSE_OVER))
                     {
                        _loc3_.area.addEventListener(MouseEvent.MOUSE_OVER,this.showUnitInfo,false,0,true);
                        _loc3_.area.addEventListener(MouseEvent.MOUSE_OUT,this.hideUnitInfo,false,0,true);
                        _loc3_.area.buttonMode = true;
                     }
                     if(_loc7_)
                     {
                        _loc8_++;
                        this.setSaturation(_loc4_,1);
                     }
                     else
                     {
                        this.setSaturation(_loc4_,0);
                     }
                     _loc3_.visible = true;
                  }
                  else
                  {
                     _loc3_.visible = false;
                  }
                  if(_loc2_ == _loc10_.length - 1)
                  {
                     _loc3_.lblCounter.visible = true;
                     TextFieldUtil.setHTML(_loc3_.lblCounter,_loc8_ + "/" + _loc10_.length);
                  }
               }
               _loc2_++;
            }
            if(_loc9_ != null)
            {
               if(_loc8_ >= _loc10_.length)
               {
                  if(_loc8_ == _loc10_.length && Base.Player.unitCollectionsCompleted.indexOf(_loc9_.getInt("category_id")) == -1)
                  {
                     _loc3_ = this.vUnits[_loc1_][0];
                     _loc3_.butGetReward.visible = true;
                     GameStatic.buttonize(_loc3_.butGetReward,Language.POPUP_RECLUTAMIENTO_RECOMPENSA);
                     _loc3_.butGetReward.id = _loc9_.getInt("rewards");
                     _loc3_.butGetReward.catId = _loc9_.getInt("category_id");
                     _loc3_.butGetReward.addEventListener(MouseEvent.CLICK,this.getCollectionReward);
                     _loc3_.butGetReward.addEventListener(MouseEvent.MOUSE_OVER,this.hideUnitInfo);
                  }
                  else if(Base.Player.unitCollectionsCompleted.indexOf(_loc9_.getInt("category_id")) != -1)
                  {
                     _loc3_ = this.vUnits[_loc1_][0];
                     TextFieldUtil.setHTML(_loc3_.lblCompleted,Language.getLiteral(Language.AUX_COMPLETADO));
                     _loc3_.lblCompleted.visible = true;
                  }
               }
            }
            _loc1_++;
         }
         this.updateButtons();
      }
      
      protected function buyUnit(param1:MouseEvent) : void
      {
         var _loc3_:BuildingReference = null;
         var _loc2_:StaticData = this.tooltip.sd;
         if(Base.Player.canAfford(this.tooltip.cost.value,CostType.CASH))
         {
            Base.Player.adjustStatByType(-this.tooltip.cost.value,CostType.CASH);
            _loc3_ = new BuildingReference(_loc2_);
            Base.Main.storeItem(_loc3_,false,false);
            this.ucm.addUnit(_loc2_.id);
            Base.Commands.addCommand({
               "cmd":Constants.CMD_BUY_STORED_ITEM_CASH,
               "args":[Base.Main.townID,_loc2_.id,this.tooltip.cost.value]
            });
            this.removeTooltip();
            this.refresh();
         }
         else
         {
            Base.PopUp.moneyConfirm(-1,CostType.CASH);
         }
      }
      
      protected function buyCollection(param1:MouseEvent) : void
      {
      }
      
      protected function getCollectionReward(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.id);
         var _loc3_:int = int(param1.currentTarget.catId);
         var _loc4_:UnitListMC = param1.currentTarget.parent;
         var _loc5_:BuildingReference = new BuildingReference(StaticDataLibrary.api.getItem(_loc2_));
         var _loc6_:int = _loc2_;
         var _loc7_:Array = Base.Player.unitCollectionsCompleted;
         _loc7_.push(_loc3_);
         Base.Player.unitCollectionsCompleted = _loc7_;
         _loc4_.butGetReward.visible = false;
         TextFieldUtil.setHTML(_loc4_.lblCompleted,Language.getLiteral(Language.AUX_COMPLETADO));
         _loc4_.lblCompleted.visible = true;
         Base.PopUp.openPopupNextIslandAttack(Base.Player.iLevel,1,_loc6_,false,false);
         Base.Player.adjustStatByType(1,CostType.CASH);
         Base.Commands.addCommand({
            "cmd":Constants.CMD_UNIT_COLLECTION_COMPLETED,
            "args":[_loc3_]
         });
      }
      
      private function updateButtons() : void
      {
         if(this.categoryOffset > 0)
         {
            this.enableButton(left);
         }
         else
         {
            this.disableButton(left);
         }
         if(this.categoryOffset + this.FILES < this.categoryUnitsObj.length)
         {
            this.enableButton(right);
         }
         else
         {
            this.disableButton(right);
         }
      }
      
      private function enableButton(param1:SimpleButton) : void
      {
         param1.mouseEnabled = true;
         param1.alpha = 1;
      }
      
      private function disableButton(param1:SimpleButton) : void
      {
         param1.mouseEnabled = false;
         param1.alpha = 0.5;
      }
      
      private function setSaturation(param1:DisplayObject, param2:Number) : void
      {
         var _loc3_:ColorMatrixFilter = new ColorMatrixFilter();
         if(param2 >= 0 && param2 <= 2)
         {
            _loc3_.matrix = [0.114 + 0.886 * param2,0.299 * (1 - param2),0.587 * (1 - param2),0,0,0.114 * (1 - param2),0.299 + 0.701 * param2,0.587 * (1 - param2),0,0,0.114 * (1 - param2),0.299 * (1 - param2),0.587 + 0.413 * param2,0,0,0,0,0,1,0];
         }
         param1.filters = [_loc3_];
      }
      
      private function removeTooltip() : void
      {
         if(this.tooltip != null)
         {
            this.tooltip.parent.removeChild(this.tooltip);
            this.tooltip = null;
            this.tooltipTimer.stop();
            this.tooltipTimer.removeEventListener(TimerEvent.TIMER,this.updateAnimation);
            this.tooltipTimer = null;
         }
      }
      
      private function hideUnitInfo(param1:MouseEvent) : void
      {
         if(this.tooltip == null)
         {
            return;
         }
         if(!this.tooltip.hitTestPoint(this.tooltip.parent.mouseX,this.tooltip.parent.mouseY,true))
         {
            this.removeTooltip();
         }
      }
      
      private function showUnitInfo(param1:MouseEvent) : void
      {
         var unitList:UnitListMC;
         var unidadItem:StaticData;
         var point:Point;
         var e:MouseEvent = param1;
         this.removeTooltip();
         unitList = UnitListMC(e.currentTarget.parent);
         unitList.parent.setChildIndex(unitList,unitList.parent.numChildren - 1);
         unidadItem = unitList.sd;
         if(unitList.owned)
         {
            this.tooltip = new InfoButtonUnitCollectionMC();
         }
         else
         {
            this.tooltip = new InfoButtonUnitCollectionBuyMC();
            TextFieldUtil.setHTML(this.tooltip.buyPane.btnBuy.txUnlock,Language.getLiteral(Language.AUX_BUY_FOR));
            TextFieldUtil.setHTML(this.tooltip.buyPane.btnBuy.txPrice,unitList.cost.value);
            this.tooltip.buyPane.btnBuy.mouseChildren = false;
            this.tooltip.buyPane.btnBuy.buttonMode = true;
            this.tooltip.buyPane.btnBuy.addEventListener(MouseEvent.CLICK,this.buyUnit);
            this.tooltip.buyPane.btnBuy.addEventListener(MouseEvent.MOUSE_OVER,function(param1:MouseEvent):void
            {
               param1.currentTarget.scaleX = param1.currentTarget.scaleY = 1.1;
            });
            this.tooltip.buyPane.btnBuy.addEventListener(MouseEvent.MOUSE_OUT,function(param1:MouseEvent):void
            {
               param1.currentTarget.scaleX = param1.currentTarget.scaleY = 1;
            });
            this.tooltip.sd = unidadItem;
            this.tooltip.cost = new ObfuscatedNumber();
            this.tooltip.cost.value = unitList.cost.value;
         }
         this.tooltip.descEspecial.visible = false;
         this.tooltipTimer = new Timer(3000);
         this.tooltipTimer.addEventListener(TimerEvent.TIMER,this.updateAnimation);
         this.tooltipTimer.start();
         TextFieldUtil.setHTML(this.tooltip.mcVida.txVida,unidadItem.life);
         TextFieldUtil.setHTML(this.tooltip.mcAttack.txAttack,unidadItem.attack);
         TextFieldUtil.setHTML(this.tooltip.mcDefense.txDefense,unidadItem.attack_interval);
         TextFieldUtil.setHTML(this.tooltip.mcSpeed.txSpeed,unidadItem.velocity);
         TextFieldUtil.setHTML(this.tooltip.mcRange.txRange,unidadItem.attack_range);
         TextFieldUtil.setHTML(this.tooltip.mcPop.txPop,unidadItem.population);
         TextFieldUtil.setHTML(this.tooltip.txNombre,unidadItem.name);
         if(unitList.y < 50)
         {
            this.tooltip.y = unitList.height - 10 + this.tooltip.height / 2;
            this.tooltip.background.gotoAndStop(2);
         }
         point = new Point(this.tooltip.x,this.tooltip.y);
         point = unitList.bufHolder.localToGlobal(point);
         this.tooltip.x = point.x;
         this.tooltip.y = point.y;
         Base.Main.getStage().addChild(this.tooltip);
         this.loadAnim(unidadItem.img_name);
      }
      
      private function updateAnimation(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         try
         {
            this.cycleAnimation();
         }
         catch(e:Error)
         {
         }
      }
      
      protected function cycleAnimation() : void
      {
         var anim:MovieClip = null;
         try
         {
            anim = MovieClip(this.tooltip.thumb.getChildAt(0));
            if(anim.currentFrame == Constants.ANIMATION_WALKING * 5 + Constants.ORIENTATION_DOWN_RIGHT)
            {
               anim.gotoAndStop(Constants.ANIMATION_ATTACKING * 5 + Constants.ORIENTATION_DOWN_RIGHT);
               if(anim.numChildren > 0)
               {
                  MovieClip(anim.getChildAt(0)).play();
               }
            }
            else if(anim.currentFrame == Constants.ANIMATION_ATTACKING * 5 + Constants.ORIENTATION_DOWN_RIGHT && anim.totalFrames >= Constants.ANIMATION_ATTACKING_SPECIAL1 * 5)
            {
               anim.gotoAndStop(Constants.ANIMATION_ATTACKING_SPECIAL1 * 5 + Constants.ORIENTATION_DOWN_RIGHT);
            }
            else
            {
               anim.gotoAndStop(Constants.ANIMATION_WALKING * 5 + Constants.ORIENTATION_DOWN_RIGHT);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function prevPage(param1:MouseEvent) : void
      {
         this.categoryOffset -= this.FILES;
         this.refresh();
      }
      
      public function nextPage(param1:MouseEvent) : void
      {
         this.categoryOffset += this.FILES;
         this.refresh();
      }
      
      public function onOver(param1:MouseEvent) : void
      {
         param1.target.scaleX = 1.1;
         param1.target.scaleY = 1.1;
      }
      
      public function onOut(param1:MouseEvent) : void
      {
         param1.target.scaleX = 1;
         param1.target.scaleY = 1;
      }
      
      public function loadAnim(param1:String) : void
      {
         var thumbPath:String = null;
         var img_name:String = param1;
         var tmpLoader:Loader = new Loader();
         tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.previewAnimationLoaded);
         thumbPath = Base.Main.apfx + "buildingsprites/" + img_name + ".swf";
         tmpLoader.load(new URLRequest(thumbPath));
         tmpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
         {
         });
         while(this.tooltip.thumb.numChildren > 0)
         {
            this.tooltip.thumb.removeChildAt(0);
         }
         this.tooltip.thumb.addChild(tmpLoader);
      }
      
      private function previewAnimationLoaded(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Rectangle = null;
         var _loc8_:Shape = null;
         if(this.tooltip == null)
         {
            return;
         }
         if(this.tooltip.thumb != null && this.tooltip.descEspecial != null)
         {
            if(this.tooltip.descEspecial.visible)
            {
               _loc2_ = this.THUMB_HEIGHT_CONDESC;
            }
            else
            {
               _loc2_ = this.THUMB_HEIGHT_SINDESC;
            }
            if(this.tooltip.thumb.contains(param1.currentTarget.loader))
            {
               _loc3_ = param1.currentTarget.loader.content.getChildAt(0);
               this.tooltip.thumb.removeChild(param1.currentTarget.loader);
               this.tooltip.thumb.addChild(_loc3_);
               _loc3_.gotoAndStop(Constants.ANIMATION_WALKING * 5 + Constants.ORIENTATION_DOWN_RIGHT);
               _loc4_ = _loc3_.width / this.THUMB_WIDTH;
               _loc5_ = _loc3_.height / _loc2_;
               _loc6_ = Math.max(_loc4_,_loc5_);
               if(_loc6_ < this.MIN_RATIO)
               {
                  _loc6_ = this.MIN_RATIO;
               }
               _loc3_.width /= _loc6_;
               _loc3_.height /= _loc6_;
               _loc7_ = _loc3_.getBounds(this.tooltip.thumb);
               _loc3_.x = (this.THUMB_WIDTH - _loc7_.width) / 2 + (_loc3_.x - _loc7_.x);
               _loc3_.y = (_loc2_ - _loc7_.height) / 2 + (_loc3_.y - _loc7_.y);
               _loc8_ = new Shape();
               _loc8_.graphics.beginFill(0,0.5);
               _loc8_.graphics.drawRect(-this.THUMB_MARGIN,-this.THUMB_MARGIN,this.THUMB_WIDTH + this.THUMB_MARGIN * 2,_loc2_ + this.THUMB_MARGIN * 2);
               _loc8_.graphics.endFill();
               this.tooltip.thumb.addChild(_loc8_);
               _loc3_.mask = _loc8_;
            }
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         this.closeWindow();
      }
      
      public function closeWindow() : void
      {
         this.removeTooltip();
         Base.PopUp.confirmWindow = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         Base.Gui.removeGuiCover(Base.Gui);
         Base.Main.enableMap();
      }
   }
}

