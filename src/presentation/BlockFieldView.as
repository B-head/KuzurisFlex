package presentation {
	import common.*;
	import flash.display.*;
	import flash.geom.*;
	import model.*;
	import mx.core.*;
	
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
		public var breakBlockGraphics:BreakBlockGraphics;
		public var shockEffectHelper:ShockEffectHelper;
		public var showSpecial:Boolean;
		public var isGhost:Boolean;
		private var bitmaps:Vector.<Bitmap>;
		private var bitmapIndex:int;
		
		public function BlockFieldView() 
		{
			super();
			this.bitmaps = new Vector.<Bitmap>();
		}
		
		public function update(field:BlockField, shockSave:Boolean):void
		{
			bitmapIndex = 0;
			if (field == null)
			{
				postHidden();
				return;
			}
			var w:int = field.maxWidth;
			var h:int = field.maxHeight;
			for (var x:int = 0; x < w; x++)
			{
				for (var y:int = 0; y < h; y++)
				{
					if (!field.isExistBlock(x, y)) continue;
					var effectDamageRest:Number = 0;
					var flashStrongth:Number = 0;
					if (shockEffectHelper != null)
					{
						var id:uint = field.getId(x, y);
						effectDamageRest = shockEffectHelper.getDamageRest(id);
						//flashStrongth = (shockEffectHelper.hasImmediatelySplit(id) ? 1 : 0);
						updateEffects(id, x, y, field);
					}
					updateBlock(x, y, effectDamageRest, flashStrongth, field, shockSave);
				}
			}
			postHidden();
		}
		
		private function updateBlock(x:int, y:int, effectDamageRest:Number, flashStrongth:Number, field:BlockField, shockSave:Boolean):void
		{
			var bb:Bitmap = getBitmap();
			var type:uint = field.getType(x, y);
			var color:uint = field.getColor(x, y);
			var hitPoint:Number = field.getHitPoint(x, y);
			var specialUnion:Boolean = field.getSpecialUnion(x, y);
			var reviseHitPoint:Number = Math.ceil(hitPoint + effectDamageRest);
			var graphicIndex:int = Math.min(blockGraphics.blockLength, reviseHitPoint);
			graphicIndex = Math.max(graphicIndex, 0);
			graphicIndex = Math.min(graphicIndex, blockGraphics.blockLength - 1);
			bb.x = x * blockGraphics.blockWidth;
			bb.y = y * blockGraphics.blockHeight;
			bb.transform.colorTransform = createColorTransform(flashStrongth, specialUnion, shockSave);
			if (isGhost)
			{
				bb.bitmapData = blockGraphics.ghost[color];
				return;
			}
			switch(type)
			{
				case BlockState.normal:
					if (hitPoint > 0)
					{
						bb.bitmapData = blockGraphics.union[color][graphicIndex];
					}
					else
					{
						bb.bitmapData = blockGraphics.split[color][graphicIndex];
					}
					break;
				case BlockState.nonBreak:
					bb.bitmapData = blockGraphics.nonBreak[color];
					break;
				case BlockState.jewel:
					bb.bitmapData = blockGraphics.jewel[color];
					break;
				default:
					bb.bitmapData = null;
					break;
			}
		}
		
		private function updateEffects(id:uint, x:int, y:int, field:BlockField):void
		{
			var effectStates:Vector.<ShockEffectState> = shockEffectHelper.getEffectState(id);
			if (effectStates == null) return;
			for (var i:int = 0; i < effectStates.length; i++)
			{
				var es:ShockEffectState = effectStates[i];
				if (es.isShockWaveVisible())
				{
					var shockWaveFrame:int = es.getShockWaveFrame();
					var swb:Bitmap = getBitmap();
					if (es.toSplit)
					{
						swb.bitmapData = shockGraphics.toSplit[shockWaveFrame];
					}
					else
					{
						swb.bitmapData = shockGraphics.normal[shockWaveFrame];
					}
					swb.x = x * shockGraphics.blockWidth + shockGraphics.offsetX;
					swb.y = y * shockGraphics.blockHeight + shockGraphics.offsetY;
				}
				if (false && es.isFireworksVisible())
				{
					var fireworksFrame:int = es.getFireworksFrame();
					var dir:Number = es.fireworksDirection;
					var color:uint = field.getColor(x, y);
					var fwb:Bitmap = getBitmap();
					fwb.bitmapData = breakBlockGraphics.fireworks[color][fireworksFrame];
					fwb.x = x * breakBlockGraphics.size - breakBlockGraphics.size;
					fwb.y = y * breakBlockGraphics.size - breakBlockGraphics.size;
					fwb.rotation = 0;
					Utility.rotate(fwb, dir, breakBlockGraphics.size * 1.5, breakBlockGraphics.size * 1.5);
				}
			}
		}
		
		private function createColorTransform(flashStrongth:Number, specialUnion:Boolean, shockSave:Boolean):ColorTransform
		{
			var tedr:Number = Math.min(1, flashStrongth);
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
		
		private function postHidden():void
		{
			while (bitmapIndex < bitmaps.length) bitmaps[bitmapIndex++].visible = false;
		}
		
		private function getBitmap():Bitmap
		{
			if (bitmapIndex >= bitmaps.length)
			{
				var add:Bitmap = new Bitmap();
				bitmaps.push(add);
				addChildAt(add, 0);
			}
			var ret:Bitmap = bitmaps[bitmapIndex++];
			ret.visible = true;
			ret.rotation = 0;
			return ret;
		}
	}

}