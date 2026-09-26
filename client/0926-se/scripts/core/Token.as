package core
{
   import caurina.transitions.*;
   import core.isoengine.*;
   import core.statics.*;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import managers.CollectableManager;
   import utils.TextFieldUtil;
   
   public class Token extends TokenMC
   {
      
      public var valor:int;
      
      public var tipoToken:int;
      
      public var sourceElement:IsoElement;
      
      public var autoClick:Boolean;
      
      public var cCollectible:Collectible;
      
      public var mcTooltip:tooltipColMC;
      
      public var COL_WIDTH:int = 60;
      
      public var COL_HEIGHT:int = 60;
      
      public var COL_SCALE:Number = 0.85;
      
      public var randomSpread:Boolean;
      
      public var sCostType:String;
      
      public var particle:Boolean;
      
      public var TOKEN_SIZE:Number = 1.2;
      
      public var loader:Loader;
      
      public function Token(param1:IsoElement, param2:int, param3:int = 0, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false)
      {
         var _loc7_:BitmapData = null;
         var _loc8_:Matrix = null;
         super();
         this.particle = param6;
         this.gotoAndStop(param2);
         if(param2 == Constants.TOKEN_COLLECTIBLE)
         {
            _loc8_ = new Matrix();
            _loc8_.translate(-(this.COL_WIDTH * this.COL_SCALE) / 2,-(this.COL_WIDTH * this.COL_SCALE) / 2);
            _loc8_.scale(this.COL_SCALE,this.COL_SCALE);
            this.cCollectible = CollectableManager.getLoot(param1);
            if(this.cCollectible == null)
            {
               return;
            }
            _loc7_ = CollectableManager.getImage(this.cCollectible.iIdCollection,this.cCollectible.iIdCollectible);
            this.graphics.beginBitmapFill(_loc7_,_loc8_);
            this.graphics.drawRect(-(this.COL_WIDTH * this.COL_SCALE) / 2 + 4,-(this.COL_WIDTH * this.COL_SCALE) / 2 + 4,this.COL_WIDTH * this.COL_SCALE,this.COL_HEIGHT * this.COL_SCALE);
            this.graphics.endFill();
            this.filters = new Array(new GlowFilter(16777215,1,3,3,50,3));
         }
         this.tipoToken = param2;
         this.valor = param3;
         this.sourceElement = param1;
         this.randomSpread = param5;
         this.buttonMode = true;
         this.addEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onClick);
         this.autoClick = Base.Main.bAllowAdminPanel;
         if(Base.Main.arTokens.length >= 6 || param4 || Base.Main.tutorialMode && param2 != Constants.TOKEN_WOOD)
         {
            this.autoClick = true;
         }
         this.spawn();
      }
      
      public static function collectAllTokens() : void
      {
         var _loc1_:* = 0;
         var _loc2_:Array = Base.Main.arTokens;
         _loc1_ = int(_loc2_.length - 1);
         while(_loc1_ >= 0)
         {
            Token(_loc2_[_loc1_]).onClick(null);
            _loc1_--;
         }
      }
      
      public function spawn() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         Base.Main.buildingLayer.addChild(this);
         Base.Main.arTokens.push(this);
         _loc1_ = Utils.TileToPixel(this.sourceElement.buildingReference.tx,this.sourceElement.buildingReference.ty);
         this.x = _loc1_.x;
         this.y = _loc1_.y;
         if(!this.randomSpread)
         {
            switch(this.tipoToken)
            {
               case Constants.TOKEN_GOLD:
               case Constants.TOKEN_STONE:
               case Constants.TOKEN_FOOD:
               case Constants.TOKEN_WOOD:
                  _loc2_ = Utils.TileToPixel(this.sourceElement.buildingReference.tx + 1,this.sourceElement.buildingReference.ty);
                  if(Base.Main.tutorialMode && Base.Main.tutorial.getStep() == 6)
                  {
                     _loc3_ = this.x;
                     _loc4_ = this.y - 30;
                  }
                  else
                  {
                     _loc3_ = this.x + 80;
                     _loc4_ = this.y + 60;
                  }
                  this.x += 30;
                  break;
               case Constants.TOKEN_XP:
                  _loc2_ = Utils.TileToPixel(this.sourceElement.buildingReference.tx,this.sourceElement.buildingReference.ty + 1);
                  _loc3_ = this.x - 80;
                  _loc4_ = this.y + 60;
                  this.x -= 30;
                  break;
               case Constants.TOKEN_COLLECTIBLE:
                  _loc2_ = Utils.TileToPixel(this.sourceElement.buildingReference.tx + 1,this.sourceElement.buildingReference.ty + 1);
                  _loc3_ = this.x;
                  _loc4_ = this.y + 60;
            }
         }
         else
         {
            _loc3_ = this.x + (Math.random() * 180 - 90);
            _loc4_ = this.y + 120;
         }
         §§push(this);
         var _loc5_:Number;
         this.scaleY = _loc5_ = 1 / Base.Main.currentZoom * this.TOKEN_SIZE;
         §§pop().scaleX = _loc5_;
         if(this.autoClick)
         {
            this.onClick();
         }
         else
         {
            Tweener.addTween(this,{
               "y":_loc4_,
               "time":1,
               "transition":"easeOutBounce"
            });
            Tweener.addTween(this,{
               "x":_loc3_,
               "time":1,
               "transition":"linear"
            });
         }
      }
      
      public function onOver(param1:MouseEvent) : void
      {
         if(this.tipoToken == Constants.TOKEN_COLLECTIBLE)
         {
            this.filters = new Array(new GlowFilter(16777215,1,6,6,50,3));
            if(this.mcTooltip != null)
            {
               Base.Main.overTileLayer.removeChild(this.mcTooltip);
               this.mcTooltip = null;
            }
            this.mcTooltip = new tooltipColMC();
            TextFieldUtil.setHTML(this.mcTooltip.texte,Language.getLiteral(this.cCollectible.idName));
            this.mcTooltip.x = x * Base.Main.currentZoom + (Base.Main.getStage().stageWidth >> 1) + this.COL_WIDTH / 2;
            this.mcTooltip.y = y * Base.Main.currentZoom + (Base.Main.getStage().stageHeight >> 1) - this.COL_HEIGHT / 2 * Base.Main.currentZoom;
            Base.Main.overTileLayer.addChild(this.mcTooltip);
         }
         else
         {
            this.filters = new Array(new GlowFilter(16777215,1,3,3,50,3));
         }
      }
      
      public function onOut(param1:MouseEvent) : void
      {
         if(this.tipoToken == Constants.TOKEN_COLLECTIBLE)
         {
            this.filters = new Array(new GlowFilter(16777215,1,3,3,50,3));
            if(this.mcTooltip != null)
            {
               Base.Main.overTileLayer.removeChild(this.mcTooltip);
               this.mcTooltip = null;
            }
         }
         else
         {
            this.filters = [];
         }
      }
      
      public function onClick(param1:MouseEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:String = null;
         _loc2_ = Base.Main.arTokens.indexOf(this);
         if(_loc2_ >= 0)
         {
            Base.Main.arTokens.splice(_loc2_,1);
         }
         var _loc6_:Number = this.x * Base.Main.currentZoom + Base.Main.buildingLayer.x;
         var _loc7_:Number = this.y * Base.Main.currentZoom + Base.Main.buildingLayer.y;
         this.parent.removeChild(this);
         Base.Main.ps.addToken(this);
         this.scaleX = this.scaleY = 1;
         this.x = _loc6_;
         this.y = _loc7_;
         switch(this.tipoToken)
         {
            case Constants.TOKEN_GOLD:
               this.sCostType = CostType.GOLD;
               if(Base.Main.gameMode == Constants.GAME_MODE_ASSAULT)
               {
                  Tweener.addTween(this,{
                     "x":35 + (Base.Main.getStage().stageWidth - 760) / 2,
                     "time":0.7,
                     "transition":"linear",
                     "onComplete":this.onComplete1
                  });
                  Tweener.addTween(this,{
                     "y":52,
                     "time":0.7,
                     "transition":"easeInQuad"
                  });
               }
               else
               {
                  Tweener.addTween(this,{
                     "x":20 + (Base.Main.getStage().stageWidth - 760) / 2,
                     "time":0.7,
                     "transition":"linear",
                     "onComplete":this.onComplete1
                  });
                  Tweener.addTween(this,{
                     "y":20,
                     "time":0.7,
                     "transition":"easeInQuad"
                  });
               }
               break;
            case Constants.TOKEN_XP:
               this.sCostType = Constants.COST_XP;
               if(Base.Main.gameMode == Constants.GAME_MODE_ASSAULT)
               {
                  Tweener.addTween(this,{
                     "x":140 + (Base.Main.getStage().stageWidth - 760) / 2,
                     "time":0.7,
                     "transition":"linear",
                     "onComplete":this.onComplete1
                  });
                  Tweener.addTween(this,{
                     "y":52,
                     "time":0.7,
                     "transition":"easeInQuad"
                  });
               }
               else
               {
                  Tweener.addTween(this,{
                     "x":460 + (Base.Main.getStage().stageWidth - 760) / 2,
                     "time":0.7,
                     "transition":"linear",
                     "onComplete":this.onComplete1
                  });
                  Tweener.addTween(this,{
                     "y":30,
                     "time":0.7,
                     "transition":"easeInQuad"
                  });
               }
               break;
            case Constants.TOKEN_WOOD:
               this.sCostType = CostType.WOOD;
               Tweener.addTween(this,{
                  "x":140 + (Base.Main.getStage().stageWidth - 760) / 2,
                  "time":0.7,
                  "transition":"linear",
                  "onComplete":this.onComplete1
               });
               Tweener.addTween(this,{
                  "y":20,
                  "time":0.7,
                  "transition":"easeInQuad"
               });
               break;
            case Constants.TOKEN_FOOD:
               this.sCostType = CostType.FOOD;
               Tweener.addTween(this,{
                  "x":25 + (Base.Main.getStage().stageWidth - 760) / 2,
                  "time":0.7,
                  "transition":"linear",
                  "onComplete":this.onComplete1
               });
               Tweener.addTween(this,{
                  "y":50,
                  "time":0.7,
                  "transition":"easeInQuad"
               });
               break;
            case Constants.TOKEN_STONE:
               this.sCostType = CostType.STONE;
               Tweener.addTween(this,{
                  "x":140 + (Base.Main.getStage().stageWidth - 760) / 2,
                  "time":0.7,
                  "transition":"linear",
                  "onComplete":this.onComplete1
               });
               Tweener.addTween(this,{
                  "y":50,
                  "time":0.7,
                  "transition":"easeInQuad"
               });
               break;
            case Constants.TOKEN_COLLECTIBLE:
               Base.Gui.panelCollectibleIn(this.cCollectible.iIdCollection);
               _loc3_ = MovieClip(Base.Gui.panelCollection.getChildByName("collectible" + this.cCollectible.iIdCollectible));
               _loc4_ = 425 + _loc3_.x + this.COL_WIDTH * this.COL_SCALE / 2;
               _loc5_ = 100 + _loc3_.y + this.COL_WIDTH * this.COL_SCALE / 2;
               Tweener.addTween(this,{
                  "x":_loc4_ + (Base.Main.getStage().stageWidth - 760) / 2,
                  "time":0.7,
                  "transition":"linear",
                  "onComplete":this.onCompleteCollectible
               });
               Tweener.addTween(this,{
                  "y":_loc5_,
                  "scaleX":0.75,
                  "scaleY":0.75,
                  "time":0.7,
                  "transition":"easeInQuad"
               });
         }
         if(this.particle)
         {
            switch(this.tipoToken)
            {
               case Constants.TOKEN_GOLD:
                  _loc8_ = CostType.GOLD;
                  break;
               case Constants.TOKEN_FOOD:
                  _loc8_ = CostType.FOOD;
                  break;
               case Constants.TOKEN_WOOD:
                  _loc8_ = CostType.WOOD;
                  break;
               case Constants.TOKEN_STONE:
                  _loc8_ = CostType.STONE;
                  break;
               case Constants.TOKEN_XP:
                  _loc8_ = Constants.COST_XP;
            }
            Base.Main.ps.addParticle(new NumberParticle(this.sourceElement.x * Base.Main.currentZoom + this.sourceElement.parent.x,this.sourceElement.y * Base.Main.currentZoom + this.sourceElement.parent.y,[this.valor],[_loc8_],1.5,60));
         }
      }
      
      public function onCompleteCollectible() : void
      {
         CollectableManager.addCollectible(this.cCollectible.iIdCollection,this.cCollectible.iIdCollectible);
         Tweener.addTween(this,{
            "scaleX":1.5,
            "scaleY":1.5,
            "alpha":0.3,
            "time":0.5,
            "transition":"linear",
            "onComplete":this.destroy
         });
      }
      
      public function onComplete1() : void
      {
         Tweener.addTween(this,{
            "scaleX":2,
            "scaleY":2,
            "alpha":0.3,
            "time":0.5,
            "transition":"linear",
            "onComplete":this.onComplete2
         });
      }
      
      public function onComplete2() : void
      {
         switch(this.tipoToken)
         {
            case Constants.TOKEN_GOLD:
            case Constants.TOKEN_FOOD:
            case Constants.TOKEN_WOOD:
            case Constants.TOKEN_STONE:
               if(Base.Main.gameMode == Constants.GAME_MODE_NORMAL)
               {
                  Base.Player.adjustStatByType(this.valor,this.sCostType,0);
               }
               if(Base.Main.tutorialMode)
               {
                  if(Base.Main.tutorial.getStep() == 7)
                  {
                     Base.Main.tutorial.nextStep();
                  }
               }
               break;
            case Constants.TOKEN_XP:
               if(Base.Main.gameMode == Constants.GAME_MODE_NORMAL)
               {
                  Base.Player.adjustStatByType(0,this.sCostType,this.valor);
               }
         }
         this.destroy();
      }
      
      public function resmooth() : void
      {
         this.scaleX = this.scaleY = 1 / Base.Main.currentZoom * this.TOKEN_SIZE;
      }
      
      public function destroy() : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
   }
}

