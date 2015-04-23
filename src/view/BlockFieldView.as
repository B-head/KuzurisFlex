package view 
{
	import flash.display.Bitmap;
	import flash.geom.ColorTransform;
	import model.BlockField;
	import model.BlockState;
	import model.GameSetting;
	import mx.core.UIComponent;
	import mx.core.UIComponentCachePolicy;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class BlockFieldView extends UIComponent
	{
		private static const whiteTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 128, 128, 128, 0);
		private static const blackTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 0, 0, 0, 0);
			
		public var blockGraphics:BlockGraphics;
		public var shockGraphics:ShockEffectGraphics;
		public var shockEffectHelper:ShockEffectHelper;
		public var showSpecial:Boolean;
		public var isGhost:Boolean;
		
		private var blocks:Vector.<Bitmap>;
		private var effects:Vector.<Bitmap>;
		
		public function BlockFieldView() 
		{
			super();
			this.blocks = new Vector.<Bitmap>();
			this.effects = new Vector.<Bitmap>();
		}
		
		public function update(field:BlockField, shockSave:Boolean):void
		{
			if (field == null)
			{
				reset();
				return;
			}
			var w:int = field.maxWidth;
			var h:int = field.maxHeight;
			var blockIndex:int = 0;
			var effectIndex:int = 0;
			for (var x:int = 0; x < w; x++)
			{
				for (var y:int = 0; y < h; y++)
				{
					if (!field.isExistBlock(x, y)) continue;
					if (blockIndex >= blocks.length) addBlock();
					var bbm:Bitmap = blocks[blockIndex++];
					var effectDamageRest:Number = 0;
					if (shockEffectHelper != null)
					{
						var id:uint = field.getId(x, y);
						effectDamageRest = shockEffectHelper.getDamageRest(id);
						effectIndex = updateEffects(id, x, y, effectIndex);
					}
					updateBlock(bbm, x, y, effectDamageRest, field, shockSave);
				}
			}
			postHidden(blockIndex, effectIndex);
		}
		
		private function updateBlock(bbm:Bitmap, x:int, y:int, effectDamageRest:Number, field:BlockField, shockSave:Boolean):void
		{
			var type:uint = field.getType(x, y);
			var color:uint = field.getColor(x, y);
			var hitPoint:Number = field.getHitPoint(x, y);
			var specialUnion:Boolean = field.getSpecialUnion(x, y);
			var reviseHitPoint:Number = Math.ceil(hitPoint + effectDamageRest);
			var graphicIndex:int = Math.min(blockGraphics.blockLength, reviseHitPoint);
			graphicIndex = Math.max(graphicIndex, 0);
			graphicIndex = Math.min(graphicIndex, blockGraphics.blockLength - 1);
			bbm.visible = true;
			bbm.x = x * blockGraphics.blockWidth;
			bbm.y = y * blockGraphics.blockHeight;
			bbm.transform.colorTransform = createColorTransform(effectDamageRest, specialUnion, shockSave);
			if (isGhost)
			{
				bbm.bitmapData = blockGraphics.ghost[color];
				return;
			}
			switch(type)
			{
				case BlockState.normal:
					if (hitPoint > 0)
					{
						bbm.bitmapData = blockGraphics.union[color][graphicIndex];
					}
					else
					{
						bbm.bitmapData = blockGraphics.split[color][graphicIndex];
					}
					break;
				case BlockState.nonBreak:
					bbm.bitmapData = blockGraphics.nonBreak[color];
					break;
				case BlockState.jewel:
					bbm.bitmapData = blockGraphics.jewel[color];
					break;
				default:
					bbm.bitmapData = null;
					break;
			}
		}
		
		private function updateEffects(id:uint, x:int, y:int, effectIndex:int):int
		{
			var effectStates:Vector.<ShockEffectState> = shockEffectHelper.getEffectState(id);
			if (effectStates == null) return effectIndex;
			for (var i:int = 0; i < effectStates.length; i++)
			{
				var es:ShockEffectState = effectStates[i];
				if (!es.isVisible()) continue;
				if (effectIndex >= effects.length) addEffect();
				var reviseFrame:int = es.getGraphicFrame();
				var ebm:Bitmap = effects[effectIndex++];
				ebm.visible = true;
				if (es.toSplit)
				{
					ebm.bitmapData = shockGraphics.toSplit[reviseFrame];
				}
				else
				{
					ebm.bitmapData = shockGraphics.normal[reviseFrame];
				}
				ebm.x = x * shockGraphics.blockWidth + shockGraphics.offsetX;
				ebm.y = y * shockGraphics.blockHeight + shockGraphics.offsetY;
			}
			return effectIndex;
		}
		
		private function createColorTransform(effectDamageRest:Number, specialUnion:Boolean, shockSave:Boolean):ColorTransform
		{
			var tedr:Number = Math.min(1, effectDamageRest / GameSetting.hitPointMax);
			var multi:Number = 1 - tedr;
			var offset:int = 0xFF * tedr;
			var colorTransform:ColorTransform = new ColorTransform(multi, multi, multi, 1, offset, offset, offset, 0);
			if (showSpecial && specialUnion)
			{
				if (shockSave)
				{
					colorTransform.concat(blackTransform);
				}
				else
				{
					colorTransform.concat(whiteTransform);
				}
			}
			return colorTransform;
		}
		
		private function reset():void
		{
			for (var i:int = 0; i < blocks.length; i++)
			{
				blocks[i].visible = false;
			}
		}
		
		private function postHidden(blockIndex:int, effectIndex:int):void
		{
			while (blockIndex < blocks.length) blocks[blockIndex++].visible = false;
			while (effectIndex < effects.length) effects[effectIndex++].visible = false;
		}
		
		private function addBlock():void
		{
			var add:Bitmap = new Bitmap();
			blocks.push(add);
			addChildAt(add, 0);
		}
		
		private function addEffect():void
		{
			var add:Bitmap = new Bitmap();
			effects.push(add);
			addChild(add);
		}
	}

}