package view 
{
	import flash.display.Bitmap;
	import flash.geom.ColorTransform;
	import model.BlockField;
	import model.BlockState;
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
				for (var i:int = 0; i < blocks.length; i++)
				{
					blocks[i].visible = false;
				}
				return;
			}
			var w:int = field.width;
			var h:int = field.height;
			var blockIndex:int = 0;
			var effectIndex:int = 0;
			for (var x:int = 0; x < w; x++)
			{
				for (var y:int = 0; y < h; y++)
				{
					if (!field.isExistBlock(x, y)) continue;
					if (blockIndex >= blocks.length)
					{
						var add:Bitmap = new Bitmap();
						blocks.push(add);
						addChildAt(add, 0);
						add = new Bitmap();
						effects.push(add);
						addChild(add);
					}
					var bbm:Bitmap = blocks[blockIndex++];
					var state:BlockState = field.getState(x, y);
					var effectDamageRest:Number = 0;
					if (shockEffectHelper != null)
					{
						effectDamageRest = shockEffectHelper.getDamageRest(state);
						effectIndex = updateEffects(state, x, y, effectIndex);
					}
					var graphicIndex:int = Math.min(blockGraphics.blockLength, Math.ceil(field.getHitPoint(x, y) + effectDamageRest));
					graphicIndex = Math.max(graphicIndex, 0);
					graphicIndex = Math.min(graphicIndex, blockGraphics.blockLength - 1);
					var color:uint = field.getColor(x, y);
					var specialUnion:Boolean = field.getSpecialUnion(x, y);
					bbm.visible = true;
					bbm.bitmapData = blockGraphics[color][graphicIndex];
					bbm.x = x * blockGraphics.blockWidth;
					bbm.y = y * blockGraphics.blockHeight;
					var tedr:Number = Math.min(1, effectDamageRest / ShockEffectState.hitPointMax);
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
					bbm.transform.colorTransform = colorTransform;
				}
			}
			while (blockIndex < blocks.length) blocks[blockIndex++].visible = false;
			while (effectIndex < effects.length) effects[effectIndex++].visible = false;
		}
		
		private function updateEffects(state:BlockState, x:int, y:int, effectIndex:int):int
		{
			var effectStates:Vector.<ShockEffectState> = shockEffectHelper.getEffectState(state);
			if (effectStates == null) return effectIndex;
			for (var i:int = 0; i < effectStates.length; i++)
			{
				var es:ShockEffectState = effectStates[i];
				var reviseFrame:int = es.getReviseFrame();
				if (es.isEndEffect())
				{
					effectStates.splice(i--, 1);
					continue;
				}
				es.frameCount++;
				if (es.isNonVisible()) continue;
				if (effectIndex >= effects.length)
				{
					var add:Bitmap = new Bitmap();
					effects.push(add);
					addChild(add);
				}
				var ebm:Bitmap = effects[effectIndex++];
				ebm.visible = true;
				ebm.alpha = 0.7;
				if (es.toSplit)
				{
					ebm.bitmapData = shockGraphics.toSplit[reviseFrame];
				}
				else
				{
					ebm.bitmapData = shockGraphics.normal[reviseFrame];
				}
				ebm.x = x * shockGraphics.blockWidth - shockGraphics.blockWidth / 2;
				ebm.y = y * shockGraphics.blockHeight - shockGraphics.blockHeight / 2;
			}
			return effectIndex;
		}
		
	}

}