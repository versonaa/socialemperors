package core.isoengine
{
   import battle.*;
   import battle.projectiles.ProjectileDefinition;
   import caurina.transitions.Tweener;
   import com.socialpoint.obfuscated.OInt;
   import com.socialpoint.obfuscated.ONumber;
   import core.*;
   import core.isoengine.events.ExtraEvent;
   import core.isoengine.events.IsoElementEvent;
   import core.statics.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import managers.SoundManager;
   import popups.PopupCollect;
   
   public class IsoBuilding extends IsoFightingElement
   {
      
      public static const EVT_UNIT_PUSHED:String = "unit_pushed";
      
      public static const EVT_UNIT_POPED:String = "unit_poped";
      
      public var bTrainingUnit:Boolean;
      
      public var uiTrainingTime:uint;
      
      public var vUnitsContained:Vector.<IsoUnit>;
      
      private var _iUnitsContained:OInt = new OInt(0);
      
      private var _iUnitsContainedWhenHarvested:OInt = new OInt(0);
      
      private var _iUnitCapacity:ONumber = new ONumber(0);
      
      public var bContainedUnitsInitiated:Boolean;
      
      public var uiGoldContained:uint;
      
      public var uiFoodContained:uint;
      
      public var uiStoneContained:uint;
      
      public var uiWoodContained:uint;
      
      public var uiPopulationGranted:uint;
      
      public var bInFlames:Boolean;
      
      public var mcFire:MovieClip;
      
      public var flamesState:int = 0;
      
      public var murallaAbierta:Boolean = false;
      
      public var payedWithCash:Boolean = false;
      
      public static const MAX_TRAINING_QUEUE:int = 5;
      
      public var trainingQueue:Array = [];
      
      private var isGlowing:Boolean = false;
      
      public function IsoBuilding(param1:int = 0, param2:int = 0, param3:BuildingReference = null, param4:int = 1)
      {
         super(param1,param2,param3,param4);
         this.vUnitsContained = new Vector.<IsoUnit>();
         this.iUnitCapacity = param3.building.unit_capacity;
         this.uiPopulationGranted = param3.building.population;
         this.uiTrainingTime = 3000;
         this.bTrainingUnit = false;
         this.bInFlames = false;
         this.bContainedUnitsInitiated = false;
         this.iUnitsContainedWhenHarvested = -1;
      }
      
      public function set iUnitsContained(param1:int) : void
      {
         this._iUnitsContained = new OInt(param1);
      }
      
      public function get iUnitsContained() : int
      {
         return this._iUnitsContained.v;
      }
      
      public function set iUnitsContainedWhenHarvested(param1:int) : void
      {
         this._iUnitsContainedWhenHarvested = new OInt(param1);
      }
      
      public function get iUnitsContainedWhenHarvested() : int
      {
         return this._iUnitsContainedWhenHarvested.v;
      }
      
      public function set iUnitCapacity(param1:uint) : void
      {
         this._iUnitCapacity = new ONumber(param1);
      }
      
      public function get iUnitCapacity() : uint
      {
         return uint(this._iUnitCapacity.v);
      }
      
      override public function removeIconoSeleccionado() : void
      {
         if(delegate != null)
         {
            delegate.unselect();
         }
         super.removeIconoSeleccionado();
      }
      
      override public function clickItem(param1:MouseEvent = null) : void
      {
         this.stopGlowAnimation();
         if(delegate != null)
         {
            delegate.select();
         }
         super.clickItem(param1);
      }
      
      override public function highlight() : void
      {
         if(this.isGlowing)
         {
            return;
         }
         if(delegate != null)
         {
            delegate.highlight();
         }
         super.highlight();
      }
      
      override public function unhighlight() : void
      {
         if(delegate != null)
         {
            delegate.unhighlight();
         }
         super.unhighlight();
      }
      
      public function glowAnimation(param1:uint = 16777215, param2:Number = 5, param3:Number = 8, param4:Number = 1) : void
      {
         if(!this.isGlowing)
         {
            this.isGlowing = true;
            this.doGlowAnimation(param1,param2,param3,param4,0);
         }
      }
      
      private function doGlowAnimation(param1:uint = 16777215, param2:Number = 5, param3:Number = 8, param4:Number = 1, param5:Number = 1) : void
      {
         Tweener.addTween(this.bmd,{
            "_Glow_color":param1,
            "_Glow_strength":param2,
            "_Glow_blurX":param3,
            "_Glow_blurY":param3,
            "_Glow_quality":2,
            "_Glow_alpha":1,
            "time":param4,
            "transition":"linear"
         });
         Tweener.addTween(this.bmd,{
            "_Glow_color":param1,
            "_Glow_strength":param2,
            "_Glow_blurX":param3,
            "_Glow_blurY":param3,
            "_Glow_quality":2,
            "_Glow_alpha":0,
            "time":param4,
            "transition":"linear",
            "delay":1,
            "onComplete":this.doGlowAnimation,
            "onCompleteParams":[param1,param2,param3,param4,1]
         });
      }
      
      public function stopGlowAnimation() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.isGlowing)
         {
            this.isGlowing = false;
            Tweener.removeTweens(this.bmd);
            _loc1_ = this.bmd.filters;
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_[_loc2_] is GlowFilter)
               {
                  _loc1_.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
            this.bmd.filters = _loc1_;
         }
      }
      
      public function initContainedUnits() : void
      {
         var _loc1_:IsoElement = null;
         var _loc2_:StaticData = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(!this.bContainedUnitsInitiated)
         {
            if(this.buildingReference.loaded != null)
            {
               if(this.iUnitCapacity > 0)
               {
                  if(this.buildingReference.loaded.units.length > 0)
                  {
                     if(PopupCollect.doShit(this) && !PopupCollect.hasShit(this))
                     {
                        PopupCollect.addIconZZ(this);
                     }
                     for each(_loc4_ in this.buildingReference.loaded.units)
                     {
                        _loc2_ = StaticDataLibrary.api.getItem(_loc4_);
                        _loc3_ = Base.Iso.encontrarTileProximaLibre(10,10,true);
                        if(Boolean(_loc3_.encontrado) && _loc2_.type == Constants.TYPE_UNIT)
                        {
                           _loc1_ = Base.Main.addElement(_loc3_.ty * Config.EI_MAP_WIDTH + _loc3_.tx,_loc2_,false,false,Constants.PLAYER_SELF);
                           if(_loc1_ != null)
                           {
                              this.vUnitsContained.push(_loc1_);
                              this.iUnitsContained += 1;
                              IsoUnit(_loc1_).eContainer = this;
                              switch(this.buildingReference.building.subcat_functional)
                              {
                                 case Constants.SUBCATFUNC_RESOURCE_TREE:
                                    IsoUnit(_loc1_).bHarvesting = true;
                                    IsoUnit(_loc1_).TargetElement = this;
                                    break;
                                 case Constants.SUBCATFUNC_RESOURCE_GOLD:
                                 case Constants.SUBCATFUNC_RESOURCE_STONE:
                                    IsoUnit(_loc1_).bHarvesting = true;
                                    IsoUnit(_loc1_).TargetElement = this;
                                    break;
                                 default:
                                    Base.Main.removeElementByBuildRef(_loc1_.buildingReference,false);
                              }
                              dispatchEvent(new UnitPushedEvent(EVT_UNIT_PUSHED,IsoUnit(_loc1_),true));
                           }
                        }
                     }
                  }
                  else
                  {
                     this.activation = 0;
                     this.collected_at = 0;
                     this.removeIconoCollect();
                  }
               }
            }
            else
            {
               if(this.buildingReference.building.unit_capacity != 0)
               {
                  this.activation = 0;
               }
               this.collected_at = 0;
               this.removeIconoCollect();
            }
            this.bContainedUnitsInitiated = true;
         }
      }
      
      public function setInFlames(param1:Boolean) : void
      {
         if(this.bInFlames != param1)
         {
            this.bInFlames = param1;
            Base.Player.updatePopulation();
            if(this.bInFlames)
            {
               this.updateVida();
            }
            else
            {
               this.updateVida();
               this.bDead = false;
            }
         }
      }
      
      public function updateFlamesGraphics() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = this.iHealth / this.buildingReference.building.life * 100;
         if(_loc2_ == 0)
         {
            _loc1_ = 4;
         }
         else if(_loc2_ < 34)
         {
            _loc1_ = 3;
         }
         else if(_loc2_ < 67)
         {
            _loc1_ = 2;
         }
         else if(_loc2_ < 100)
         {
            _loc1_ = 1;
         }
         if(_loc1_ != this.flamesState)
         {
            this.flamesState = _loc1_;
            if(this.flamesState == Constants.FLAME_MAX)
            {
               this.setInFlames(true);
            }
            if(this.flamesState == Constants.FLAME_NONE)
            {
               this.setInFlames(false);
            }
            if(this.flamesState == 0)
            {
               if(this.mcFire != null)
               {
                  this.removeChild(this.mcFire);
                  this.mcFire = null;
               }
            }
            else
            {
               if(this.mcFire == null)
               {
                  this.mcFire = new FireMC();
                  this.addChild(this.mcFire);
               }
               this.mcFire.gotoAndStop(this.flamesState);
            }
         }
      }
      
      public function updateRepair() : void
      {
         this.iHealth = Math.min(this.iHealth + Config.INCREMENT_HEALTH_REPAIR,this.buildingReference.building.life);
         Base.Main.ps.addParticle(new NumberParticle(this.x * Base.Main.currentZoom + parent.x,this.y * Base.Main.currentZoom + parent.y,[Config.INCREMENT_HEALTH_REPAIR],[Constants.COST_HEAL]));
         this.updateVida();
      }
      
      public function PushUnit(param1:IsoUnit, param2:Boolean = true, param3:Boolean = true) : Boolean
      {
         var _loc4_:Object = null;
         if(this.buildingReference.building.id == Constants.ID_BUILDING_UNIT_WAREHOUSE)
         {
            return this.pushUnitToWarehause(param1);
         }
         if(!this.bDead && !this.inConstruction)
         {
            if(this.iUnitsContained < this.iUnitCapacity)
            {
               this.vUnitsContained.push(param1);
               this.iUnitsContained += 1;
               param1.eContainer = this;
               if(param2)
               {
                  if(this.pPortrait != null)
                  {
                     this.pPortrait.update();
                  }
                  Base.Main.removeElementByBuildRef(param1.buildingReference,false);
               }
               if(param3)
               {
                  Base.Commands.addCommand({
                     "cmd":Constants.CMD_PUSH_UNIT,
                     "args":[param1.iLastPosSentToServerX,param1.iLastPosSentToServerY,param1.buildingReference.building.id,this.buildingReference.tx,this.buildingReference.ty,Base.Main.townID]
                  });
                  if(this.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_REFUGE)
                  {
                     Base.Commands.sendCommands();
                  }
                  param1.iLastPosSentToServerX = this.buildingReference.tx;
                  param1.iLastPosSentToServerY = this.buildingReference.ty;
                  param1.iLastExplicitMoveX = this.buildingReference.tx;
                  param1.iLastExplicitMoveY = this.buildingReference.ty;
               }
               _loc4_ = {
                  "unit":param1,
                  "building":this
               };
               Base.Iso.dispatchEvent(new ExtraEvent(IsoEngine.UNIT_PUSHED,_loc4_));
               if(this.buildingReference.building.id == Constants.ID_BUILDING_HATCHERY && this.vUnitsContained.length == 2)
               {
                  this.activation = this.iOriginalActivation;
               }
               else if(this.buildingReference.building.id != Constants.ID_BUILDING_HATCHERY && this.activation <= 0)
               {
                  if(PopupCollect.doShit(this))
                  {
                     if(!PopupCollect.hasShit(this))
                     {
                        this.activation = 0;
                        PopupCollect.addIconZZ(this);
                     }
                  }
                  else
                  {
                     this.activation = this.iOriginalActivation;
                  }
               }
               Base.Gui.recuadroInfo.updateEarns();
               controlAnimation();
               dispatchEvent(new UnitPushedEvent(EVT_UNIT_PUSHED,param1));
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function pushUnitToWarehause(param1:IsoUnit) : Boolean
      {
         if(!this.bDead && !this.inConstruction)
         {
            if(Base.Main.warehousedUnits.length < Base.Main.warehouseCurrentCapacity)
            {
               Base.Main.warehousedUnits.push(param1.buildingReference.building.id);
               Base.Main.removeElementByBuildRef(param1.buildingReference,false);
               Base.Commands.addCommand({
                  "cmd":Constants.CMD_ADD_UNIT_WAREHOUSE,
                  "args":[param1.iLastPosSentToServerX,param1.iLastPosSentToServerY,Base.Main.townID,param1.buildingReference.building.id]
               });
               Base.Commands.sendCommands();
               param1.iLastPosSentToServerX = this.buildingReference.tx;
               param1.iLastPosSentToServerY = this.buildingReference.ty;
               param1.iLastExplicitMoveX = this.buildingReference.tx;
               param1.iLastExplicitMoveY = this.buildingReference.ty;
               Base.Player.updatePopulation();
               return true;
            }
            return false;
         }
         return false;
      }
      
      public function popAll() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IsoUnit = null;
         var _loc3_:int = 0;
         if(this.iUnitCapacity > 0)
         {
            _loc3_ = int(this.vUnitsContained.length);
            _loc1_ = 0;
            while(_loc1_ < _loc3_)
            {
               _loc2_ = this.vUnitsContained[0];
               this.PopUnit(_loc2_,true,false);
               _loc2_.eContainer = null;
               _loc1_++;
            }
         }
      }
      
      public function PopUnit(param1:IsoUnit, param2:Boolean = true, param3:Boolean = false, param4:Boolean = true) : IsoUnit
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:IsoUnit = null;
         var _loc8_:StaticData = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         _loc6_ = this.vUnitsContained.indexOf(param1);
         if(_loc6_ >= 0)
         {
            this.vUnitsContained.splice(_loc6_,1);
            --this.iUnitsContained;
            param1.bHarvesting = false;
            param1.eContainer = null;
            if(param2)
            {
               _loc5_ = Base.Iso.encontrarTileProximaLibre(this.buildingReference.tx,this.buildingReference.ty,true,true);
               if(_loc5_.encontrado)
               {
                  _loc8_ = StaticDataLibrary.api.getItem(param1.buildingReference.building.id);
                  _loc7_ = IsoUnit(Base.Main.addElement(_loc5_.ty * Config.EI_MAP_WIDTH + _loc5_.tx,_loc8_,this.inServer,false,Constants.PLAYER_SELF));
               }
               if(param4)
               {
                  param1.iLastPosSentToServerX = _loc5_.tx;
                  param1.iLastPosSentToServerY = _loc5_.ty;
                  param1.iLastExplicitMoveX = _loc5_.tx;
                  param1.iLastExplicitMoveY = _loc5_.ty;
                  Base.Commands.addCommand({
                     "cmd":Constants.CMD_POP_UNIT,
                     "args":[this.buildingReference.tx,this.buildingReference.ty,Base.Main.townID,param1.buildingReference.building.id,_loc5_.tx,_loc5_.ty,param1.buildingReference.frame]
                  });
               }
            }
            else if(param4)
            {
               param1.iLastPosSentToServerX = param1.buildingReference.tx;
               param1.iLastPosSentToServerY = param1.buildingReference.ty;
               param1.iLastExplicitMoveX = param1.buildingReference.tx;
               param1.iLastExplicitMoveY = param1.buildingReference.ty;
               if(param3)
               {
                  Base.Commands.addCommand({
                     "cmd":Constants.CMD_POP_UNIT,
                     "args":[this.buildingReference.tx,this.buildingReference.ty,Base.Main.townID,param1.buildingReference.building.id]
                  });
               }
               else
               {
                  Base.Commands.addCommand({
                     "cmd":Constants.CMD_POP_UNIT,
                     "args":[this.buildingReference.tx,this.buildingReference.ty,Base.Main.townID,param1.buildingReference.building.id,param1.buildingReference.tx,param1.buildingReference.ty,param1.buildingReference.frame]
                  });
               }
            }
            if(this.pPortrait != null)
            {
               this.pPortrait.update();
            }
            dispatchEvent(new UnitPopedEvent(EVT_UNIT_POPED,param1));
            Base.Missions.onUnitPopped(buildingReference.building.subcat_functional);
            Base.Gui.recuadroInfo.updateEarns();
         }
         if(this.vUnitsContained.length == 1 && this.buildingReference.building.id == Constants.ID_BUILDING_HATCHERY)
         {
            this.activation = 0;
            this.collected_at = 0;
            this.removeIconoCollect();
         }
         else if(this.vUnitsContained.length == 0)
         {
            if(this.buildingReference.building.subcat_functional != Constants.SUBCATFUNC_RESOURCE_GOLD && this.buildingReference.building.subcat_functional != Constants.SUBCATFUNC_RESOURCE_STONE && this.buildingReference.building.subcat_functional != Constants.SUBCATFUNC_RESOURCE_TREE && this.buildingReference.building.subcat_functional != Constants.SUBCATFUNC_RESOURCE_REGEN)
            {
               this.activation = 0;
               this.collected_at = 0;
               this.removeIconoCollect();
            }
            else if(!canCollect())
            {
               this.activation = 0;
               this.collected_at = 0;
               this.removeIconoCollect();
            }
            if(PopupCollect.doShit(this))
            {
               PopupCollect.resetShit(this);
            }
         }
         controlAnimation();
         return _loc7_;
      }
      
      public function PopSell(param1:IsoUnit) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:IsoUnit = null;
         var _loc5_:StaticData = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         _loc3_ = this.vUnitsContained.indexOf(param1);
         if(_loc3_ >= 0)
         {
            this.vUnitsContained.splice(_loc3_,1);
            --this.iUnitsContained;
            if(param1.inServer && !param1.summoned)
            {
               Base.Commands.addCommand({
                  "cmd":Constants.CMD_POP_SELL,
                  "args":[this.buildingReference.tx,this.buildingReference.ty,Base.Main.townID,this.buildingReference.building.id,param1.buildingReference.building.id]
               });
            }
         }
         if(this.pPortrait != null)
         {
            this.pPortrait.update();
         }
         if(this.vUnitsContained.length == 0)
         {
            this.activation = 0;
            this.collected_at = 0;
            this.removeIconoCollect();
         }
         controlAnimation();
      }
      
      public function SetResources(param1:uint, param2:uint, param3:uint, param4:uint) : void
      {
         this.uiGoldContained = param1;
         this.uiFoodContained = param2;
         this.uiStoneContained = param3;
         this.uiWoodContained = param4;
      }
      
      public function onTrainUnit(param1:Event) : void
      {
         trace(param1.toString());
         this.UnitTrainingStart();
      }
      
      public function UnitTrainingStart(param1:Boolean = false) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:StaticData = null;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:Boolean = false;
         var _loc6_:int = Base.Player.iPopulationCurrent;
         var _loc7_:int = Base.Player.iPopulationMax;
         _loc5_ = StaticDataLibrary.api.getItem(this.buildingReference.building.trains);
         _loc2_ = _loc5_.cost;
         switch(_loc5_.subcat_functional)
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
         _loc3_ = Math.ceil(_loc2_ * Config.FOOD_PER_GOLD_INTRAINING);
         if(param1)
         {
            _loc4_ = _loc5_.cost_unit_cash;
            if(!Base.Player.canAfford(_loc4_,CostType.CASH))
            {
               Base.PopUp.moneyConfirm(-1,CostType.CASH);
               return false;
            }
         }
         if(_loc5_.subcat_functional == Constants.SUBCATFUNC_UNIT_PEASANT)
         {
            _loc3_ = 0;
            MapInitializer.centerMapOnTile(this.buildingReference.tx,this.buildingReference.ty);
         }
         if(Base.Main.tutorialMode)
         {
            if(Base.Main.tutorial.getStep() == 2 && _loc5_.subcat_functional == Constants.SUBCATFUNC_UNIT_PEASANT)
            {
               Base.Main.tutorial.nextStep();
            }
            else
            {
               if(!(Base.Main.tutorial.getStep() == 23 && _loc5_.subcat_functional == Constants.SUBCATFUNC_UNIT_PEASANT))
               {
                  return false;
               }
               Base.Main.tutorial.nextStep();
            }
         }
         if(_loc6_ + IsoBuilding.getTrainingPopulation() + _loc5_.population <= _loc7_)
         {
            if(Base.Iso.checkUnitLimit(this.buildingReference.building.trains))
            {
               if(param1 || Base.Player.canAfford(_loc2_,_loc5_.cost_type))
               {
                  if(param1 || Base.Player.canAfford(_loc3_,CostType.FOOD))
                  {
                     if(!this.bTrainingUnit || this.canQueueUnit(_loc5_))
                     {
                        if(param1)
                        {
                           Base.Player.adjustStatByType(-_loc4_,CostType.CASH,_loc5_.xp);
                           _loc8_ = [-_loc4_];
                           _loc9_ = [CostType.CASH];
                           if(_loc5_.xp > 0)
                           {
                              _loc8_.push(_loc5_.xp);
                              _loc9_.push(Constants.COST_XP);
                           }
                           Base.Main.ps.addParticle(new NumberParticle(x * Base.Main.currentZoom + parent.x,y * Base.Main.currentZoom + parent.y,_loc8_,_loc9_));
                           _loc10_ = true;
                        }
                        else
                        {
                           Base.Player.adjustStatByType(-_loc2_,_loc5_.cost_type,_loc5_.xp);
                           Base.Player.adjustStatByType(-_loc3_,CostType.FOOD);
                           _loc8_ = [-_loc2_,-_loc3_];
                           _loc9_ = [_loc5_.cost_type,CostType.FOOD];
                           if(_loc5_.xp > 0)
                           {
                              _loc8_.push(_loc5_.xp);
                              _loc9_.push(Constants.COST_XP);
                           }
                           Base.Main.ps.addParticle(new NumberParticle(x * Base.Main.currentZoom + parent.x,y * Base.Main.currentZoom + parent.y,_loc8_,_loc9_));
                           _loc10_ = false;
                        }
                        if(this.bTrainingUnit)
                        {
                           this.trainingQueue.push(_loc10_);
                           this.refreshTrainingQueueText();
                        }
                        else
                        {
                           this.payedWithCash = _loc10_;
                           this.addProgressBar(Language.getLiteral(Language.AUX_ENTRENANDO),this.uiTrainingTime / 1000,this.OnTrainingTimer);
                           this.bTrainingUnit = true;
                        }
                        if(this.pPortrait != null)
                        {
                           this.pPortrait.loadTrainableUnitInfo(this);
                        }
                        return true;
                     }
                     return false;
                  }
                  Base.PopUp.moneyConfirm(-1,CostType.FOOD);
                  return false;
               }
               Base.PopUp.moneyConfirm(-1,_loc5_.cost_type);
               return false;
            }
            Base.PopUp.alert(Language.getLiteral(Language.AVISO_TOPE_UNIDADES));
            return false;
         }
         if(Base.Player.iPopulationCurrent >= Config.MAX_POPULATION + Base.Iso.getAdditionalPopulation())
         {
            Base.PopUp.alert(Language.getLiteral(Language.AVISO_TOPE_POBLACION));
         }
         else
         {
            Base.PopUp.alert(Language.getLiteral(Language.AVISO_TOPE_ALOJAMIENTO));
         }
         return false;
      }
      
      public function OnTrainingTimer() : void
      {
         var _loc1_:IsoElement = null;
         var _loc2_:int = 0;
         var _loc3_:StaticData = null;
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         this.bTrainingUnit = false;
         if(this.buildingReference != null)
         {
            _loc5_ = Base.Iso.encontrarTileProximaLibre(this.buildingReference.tx,this.buildingReference.ty,true,true);
            _loc2_ = _loc5_.ty * Config.EI_MAP_WIDTH + _loc5_.tx;
            if(Base.Main.tutorialMode)
            {
               if(Base.Main.tutorial.getStep() == 24)
               {
                  _loc2_ = _loc5_.ty * Config.EI_MAP_WIDTH + (_loc5_.tx - 2);
               }
            }
            if(_loc5_.encontrado)
            {
               _loc3_ = StaticDataLibrary.api.getItem(this.buildingReference.building.trains);
               if(_loc3_ != null)
               {
                  Base.Main.setMouseToInquire();
                  _loc4_ = 1;
                  switch(_loc3_.subcat_functional)
                  {
                     case Constants.SUBCATFUNC_UNIT_ARCHER:
                     case Constants.SUBCATFUNC_UNIT_FOOTMAN:
                     case Constants.SUBCATFUNC_UNIT_MOUNTED:
                        if(Base.Iso.eBlacksmith != null)
                        {
                           _loc4_ = Config.REDUCTION_MULTIPLIER_BLACKSMITH;
                        }
                        break;
                     case Constants.SUBCATFUNC_UNIT_SIEGE:
                        if(Base.Iso.eUniversity != null)
                        {
                           _loc4_ = Config.REDUCTION_MULTIPLIER_UNIVERSITY;
                        }
                  }
                  Base.Main.showFeedNewItem(_loc3_);
                  _loc1_ = Base.Main.addElement(_loc2_,_loc3_,true,false,Constants.PLAYER_SELF);
                  if(_loc1_ != null)
                  {
                     Base.Sound.playSfx(SoundManager.SFX_ROLL_OVER,this);
                     if(this.payedWithCash)
                     {
                        Base.Commands.addCommand({
                           "cmd":Constants.CMD_BUY_UNIT_WITH_CASH,
                           "args":[_loc1_.buildingReference.building.id,_loc2_ % Config.EI_MAP_WIDTH,int(_loc2_ / Config.EI_MAP_WIDTH),_loc1_.buildingReference.frame,Base.Main.townID]
                        });
                     }
                     else
                     {
                        Base.Commands.addCommand({
                           "cmd":Constants.CMD_BUY,
                           "args":[_loc1_.buildingReference.building.id,_loc2_ % Config.EI_MAP_WIDTH,int(_loc2_ / Config.EI_MAP_WIDTH),_loc1_.buildingReference.frame,Base.Main.townID,0,_loc4_,_loc1_.buildingReference.building.type]
                        });
                     }
                     Base.Iso.dispatchEvent(new IsoElementEvent(IsoEngine.UNIT_TRAINED,_loc1_,this));
                     if(_loc1_ is IsoSpecialUnit)
                     {
                        Base.Player.oSpecialUnitsBorn[_loc1_.buildingReference.building.id] = null;
                        IsoSpecialUnit(_loc1_).isExpired = false;
                        IsoSpecialUnit(_loc1_).lifeRemaining = 86400;
                     }
                  }
               }
            }
         }
         this.startNextQueuedUnit();
      }
      
      private function canQueueUnit(param1:StaticData) : Boolean
      {
         return !Base.Main.tutorialMode && param1.units_limit == 0 && 1 + this.trainingQueue.length < MAX_TRAINING_QUEUE;
      }
      
      private function startNextQueuedUnit() : void
      {
         if(this.trainingQueue.length == 0)
         {
            return;
         }
         if(this.buildingReference == null || this.parent == null)
         {
            this.trainingQueue = [];
            return;
         }
         this.payedWithCash = this.trainingQueue.shift();
         this.addProgressBar(Language.getLiteral(Language.AUX_ENTRENANDO),this.uiTrainingTime / 1000,this.OnTrainingTimer);
         this.bTrainingUnit = true;
         this.refreshTrainingQueueText();
         if(this.pPortrait != null)
         {
            this.pPortrait.loadTrainableUnitInfo(this);
         }
      }
      
      private function refreshTrainingQueueText() : void
      {
         if(this.fauxBar is FauxBar3)
         {
            FauxBar3(this.fauxBar).suffix = this.trainingQueue.length > 0 ? " +" + this.trainingQueue.length : "";
         }
      }
      
      public static function getTrainingPopulation() : int
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:IsoBuilding = null;
         var _loc4_:StaticData = null;
         for each(_loc2_ in Base.Main.buildingArray)
         {
            _loc3_ = _loc2_.mc as IsoBuilding;
            if(_loc3_ != null && _loc3_.bTrainingUnit)
            {
               _loc4_ = StaticDataLibrary.api.getItem(_loc2_.building.trains);
               if(_loc4_ != null)
               {
                  _loc1_ += (1 + _loc3_.trainingQueue.length) * _loc4_.population;
               }
            }
         }
         return _loc1_;
      }
      
      public function Destroy() : void
      {
      }
      
      private function isSorroundedByTowers() : Boolean
      {
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         if(Base.Main.towersCount < Config.NEW_TOWER_IA_TOWER_COUNT)
         {
            return false;
         }
         var _loc1_:Array = Base.Main.tileArray;
         var _loc2_:Object = this.buildingReference;
         var _loc3_:int = Math.max(0,_loc2_.tx - 1);
         var _loc4_:int = Math.max(0,_loc2_.ty - 1);
         var _loc5_:int = Math.min(Config.EI_MAP_WIDTH - 1,_loc2_.tx + 1);
         var _loc6_:int = Math.min(Config.EI_MAP_HEIGHT - 1,_loc2_.ty + 1);
         var _loc8_:int = _loc4_;
         while(_loc8_ <= _loc6_)
         {
            _loc9_ = _loc3_;
            while(_loc9_ <= _loc5_)
            {
               _loc7_ = _loc8_ * Config.EI_MAP_WIDTH + _loc9_;
               _loc2_ = _loc1_[_loc7_];
               if(!(_loc2_ is BuildingReference))
               {
                  return false;
               }
               if(_loc2_.building.subcat_functional != Constants.SUBCATFUNC_BUILDING_TOWER)
               {
                  return false;
               }
               _loc9_++;
            }
            _loc8_++;
         }
         return true;
      }
      
      override public function Update(param1:uint) : void
      {
         var _loc2_:IsoUnit = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:FXArrowAnimation = null;
         if(this.frameParticleAttack > 0)
         {
            --this.frameParticleAttack;
         }
         if(!this.bDead && !this.inConstruction)
         {
            _loc3_ = this.buildingReference.tx;
            _loc4_ = this.buildingReference.ty;
            if(param1 % this.iAttackInterval == 0 && this.PlayerID != Constants.PLAYER_NEUTRAL && ((this.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_TOWER || this.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_CASTLE || this.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_DRAGONKILLER || this.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_TOWNHALL) && this.buildingReference.building.id != Constants.ID_BUILDING_TOWNHALL_1))
            {
               if(this.TargetElement != null && this.TargetElement.buildingReference != null)
               {
                  if(Base.Iso.distance(this,this.TargetElement)[0] > this.iAttackRange / 2)
                  {
                     this.TargetElement = null;
                  }
                  if(this.buildingReference.building.id == Constants.ID_BUILDING_TOWER_ICE && this.TargetElement is IsoUnit && IsoUnit(this.TargetElement).Incapacitated == true)
                  {
                     this.TargetElement = null;
                  }
               }
               else
               {
                  this.TargetElement = null;
               }
               if((this.TargetElement == null || TargetElement.bDead) && !this.isSorroundedByTowers())
               {
                  if(PlayerID != Constants.PLAYER_ENEMY || Base.Iso.bboxPlayers.intersectsRange(this))
                  {
                     if(this.buildingReference.building.id == Constants.ID_BUILDING_TOWER_ICE)
                     {
                        acquireNewTargetNotIncapacitated(_loc3_,_loc4_,iAttackRange);
                     }
                     else
                     {
                        acquireNewTarget(_loc3_,_loc4_,this.iAttackRange);
                     }
                  }
               }
               if(this.TargetElement != null && (delegate == null || delegate.onAttack(this)) && Base.Iso.isElementValidTarget(this.TargetElement))
               {
                  _loc5_ = x;
                  _loc6_ = y - this.bmd.height * Constants.DIST_ALTURA_TIRO;
                  _loc7_ = this.TargetElement.x;
                  _loc8_ = this.TargetElement.y - this.TargetElement.bmd.height * Constants.DIST_ALTURA_TIRO;
                  _loc9_ = -1;
                  switch(this.buildingReference.building.id)
                  {
                     case Constants.ID_BUILDING_TOWER_1:
                     case Constants.ID_BUILDING_TOWER_2:
                     case Constants.ID_BUILDING_TOWER_3:
                     case Constants.ID_BUILDING_CN_TOWER:
                     case Constants.ID_BUILDING_TROLL_TOWER_1:
                     case Constants.ID_BUILDING_TROLL_TOWER_2:
                     case Constants.ID_BUILDING_TROLL_TOWER_3:
                        shootProjectile2(ProjectileDefinition.ARROW);
                        return;
                     case Constants.ID_BUILDING_NECRO_TOWER:
                     case Constants.ID_BUILDING_NECRO_BARRACK_PRIEST:
                        _loc9_ = Constants.PROJECTILE_NECRO_FIRE;
                        break;
                     case Constants.ID_BUILDING_GLA_TOWER:
                        _loc9_ = Constants.PROJECTILE_LIGHT_BALL;
                        break;
                     case Constants.ID_BUILDING_TOWER_4:
                     case Constants.ID_BUILDING_VK_TOWER:
                     case Constants.ID_BUILDING_TROLL_TOWER_4:
                        shootProjectile2(ProjectileDefinition.LARGE_ARROW);
                        return;
                     case Constants.ID_BUILDING_CASTLE_1:
                     case Constants.ID_BUILDING_CASTLE_2:
                     case Constants.ID_BUILDING_TROLL_CASTLE_1:
                     case Constants.ID_BUILDING_TROLL_CASTLE_2:
                     case Constants.ID_BUILDING_CASTLE_WIZARD:
                     case Constants.ID_BUILDING_TOWER_5:
                     case Constants.ID_BUILDING_TROLL_TOWER_5:
                     case Constants.ID_BUILDING_AZ_TOWER:
                     case Constants.ID_BUILDING_CASTLE_5x5_20:
                     case Constants.ID_BUILDING_CASTLE_5x5_40:
                     case Constants.ID_BUILDING_DIAMOND_CASTLE:
                     case Constants.ID_BUILDING_DORC_TOWER:
                        shootProjectile2(ProjectileDefinition.CANNONBALL);
                        return;
                     case Constants.ID_BUILDING_TOWER_FIRE:
                     case Constants.ID_BUILDING_EG_TOWER:
                     case Constants.ID_BUILDING_CASTLE_3:
                     case Constants.ID_BUILDING_GOLDEN_TOWNHALL:
                     case Constants.ID_BUILDING_GOLDEN_CASTLE:
                     case Constants.ID_BUILDING_GOLDEN_TOWER:
                     case Constants.ID_BUILDING_IF_TOWER:
                     case Constants.ID_BUILDING_HW_TOWER_BIG:
                        _loc9_ = Constants.PROJECTILE_FIREBALL;
                        break;
                     case Constants.ID_BUILDING_TOWER_LIGHTNING:
                     case Constants.ID_BUILDING_MYTH_TOWER:
                        _loc9_ = Constants.PROJECTILE_LIGHTNING;
                        break;
                     case Constants.ID_BUILDING_TOWER_ICE:
                        _loc9_ = Constants.PROJECTILE_SNOW;
                        break;
                     case Constants.ID_BUILDING_AT_TOWER:
                        _loc9_ = Constants.PROJECTILE_CHORRAZO;
                        break;
                     case Constants.ID_BUILDING_HW_TOWER:
                        _loc9_ = Constants.PROJECTILE_PUMPKIN;
                        break;
                     case Constants.ID_BUILDING_ELV_TOWER:
                     case Constants.ID_BUILDING_ELF_TOWER:
                     case Constants.ID_BUILDING_ANGEL_TOWER:
                     case Constants.ID_BUILDING_PHA_TOWER:
                        _loc9_ = Constants.PROJECTILE_GOLD_ARROW;
                        break;
                     case Constants.ID_BUILDING_DRAGONKILLER_CASTLE:
                     default:
                        _loc9_ = Constants.PROJECTILE_ARROW;
                  }
                  if(_loc9_ == -1)
                  {
                     IsoFightingElement(this.TargetElement).recibirAtaque(uiAttack,this);
                  }
                  else if(this.buildingReference.building.id == Constants.ID_BUILDING_TOWER_ICE && this.TargetElement is IsoUnit)
                  {
                     _loc10_ = new FXArrowAnimation(_loc9_,endAttack,_loc5_,_loc6_,_loc7_,_loc8_,this.TargetElement,this.uiAttack,this);
                     Base.Main.buildingLayer.addChild(_loc10_);
                     Base.Main.vProyectiles.push(_loc10_);
                  }
                  else if(this.buildingReference.building.id != Constants.ID_BUILDING_TOWER_ICE)
                  {
                     _loc10_ = new FXArrowAnimation(_loc9_,endAttack,_loc5_,_loc6_,_loc7_,_loc8_,this.TargetElement,this.uiAttack,this);
                     Base.Main.buildingLayer.addChild(_loc10_);
                     Base.Main.vProyectiles.push(_loc10_);
                  }
               }
            }
            else if(this.buildingReference.building.subcat_functional == Constants.SUBCATFUNC_BUILDING_HEALING)
            {
               if(param1 % this.iAttackInterval == 0)
               {
                  _loc2_ = IsoUnit(Base.Iso.getNearestTarget(_loc3_,_loc4_,this.PlayerID == Constants.PLAYER_SELF,this.iAttackRange,false,Base.Iso.fCheckToHeal));
                  if(_loc2_ != null && _loc2_.buildingReference != null)
                  {
                     _loc2_.recibirVida(this.uiAttack,this);
                     new MagicParticle(this,_loc2_.buildingReference.tx,_loc2_.buildingReference.ty,MagicParticle.MAGIC_TYPE_STARS,0,0);
                     ++Base.Missions.unitsHealedWithHealingSpring;
                  }
               }
            }
         }
      }
      
      public function abrirCerrarMuralla(param1:Boolean) : void
      {
         if(!this.bDead)
         {
            if(param1)
            {
               this.ghostBuilding.gotoAndStop(this.ghostBuilding.currentFrame + 2);
               Base.Main.clearOccupiedPath(this.buildingReference);
            }
            else
            {
               this.ghostBuilding.gotoAndStop(this.ghostBuilding.currentFrame - 2);
               Base.Main.setOccupiedPath(this.buildingReference);
            }
            this.murallaAbierta = param1;
         }
      }
      
      public function upgrade() : Boolean
      {
         var _loc1_:StaticData = null;
         var _loc2_:StaticData = null;
         var _loc4_:IsoBuilding = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc3_:Boolean = false;
         if(parent == null)
         {
            return false;
         }
         _loc2_ = this.getUpgradeBuilding();
         if(_loc2_ != null)
         {
            if(Base.Player.iLevel >= _loc2_.min_level)
            {
               _loc6_ = Base.Iso.getDifferenceCost(this.buildingReference.building,_loc2_);
               _loc7_ = int(_loc6_[0]);
               _loc5_ = _loc6_[1];
               if(Base.Player.canAfford(_loc7_,_loc5_))
               {
                  _loc3_ = true;
               }
               else
               {
                  Base.PopUp.moneyConfirm(-1,_loc5_);
               }
            }
            else
            {
               Base.PopUp.alert(Language.getLiteral(Language.AVISO_NIVEL_MEJORAR,[_loc2_.min_level]));
            }
         }
         if(_loc3_)
         {
            _loc11_ = this.buildingReference.building.cost_type;
            _loc12_ = this.buildingReference.building.cost;
            if(Config.SELL_FOR_ZERO_CASH && _loc11_ == CostType.CASH)
            {
               Base.Player.adjustStatByType(-_loc7_,_loc5_,_loc2_.xp);
               Base.Main.ps.addParticle(new NumberParticle(this.x * Base.Main.currentZoom + parent.x,this.y * Base.Main.currentZoom + parent.y,[-_loc7_,_loc2_.xp],[_loc5_,Constants.COST_XP]));
            }
            else
            {
               Base.Player.adjustStatByType(Math.floor(_loc12_ / Config.DIVISOR_SELL),_loc11_,0);
               Base.Player.adjustStatByType(-_loc7_,_loc5_,_loc2_.xp);
               Base.Main.ps.addParticle(new NumberParticle(this.x * Base.Main.currentZoom + parent.x,this.y * Base.Main.currentZoom + parent.y,[Math.floor(_loc12_ / Config.DIVISOR_SELL),-_loc7_,_loc2_.xp],[_loc11_,_loc5_,Constants.COST_XP]));
            }
            _loc8_ = this.buildingReference.tx;
            _loc9_ = this.buildingReference.ty;
            _loc10_ = _loc9_ * Config.EI_MAP_WIDTH + _loc8_;
            Base.Main.removeElement(_loc10_,true,Constants.SELL_REASON_UPGRADE);
            _loc4_ = IsoBuilding(Base.Main.addElement(_loc10_,_loc2_,true,true,Constants.PLAYER_SELF,true));
            Base.Commands.addCommand({
               "cmd":Constants.CMD_BUY,
               "args":[_loc2_.id,_loc8_,_loc9_,1,Base.Main.townID,0,1,_loc2_.type]
            });
         }
         return _loc3_;
      }
      
      public function getUpgradeBuilding() : StaticData
      {
         var _loc1_:StaticData = null;
         if(this.buildingReference.building.upgrades_to > 0)
         {
            return StaticDataLibrary.api.getItem(this.buildingReference.building.upgrades_to);
         }
         return null;
      }
      
      public function buildingBeingAttack(param1:IsoFightingElement) : void
      {
         if(this.uiAttack > 0)
         {
            if(this.TargetElement == null)
            {
               this.TargetElement = param1;
            }
            else if(this.TargetElement is IsoFightingElement && IsoFightingElement(this.TargetElement).uiAttack == 0)
            {
               this.TargetElement = param1;
            }
         }
         if(Base.Main.gameMode == Constants.GAME_MODE_ASSAULT)
         {
            Assault.iaDefender.BeingAttacked(param1,this);
         }
      }
   }
}

