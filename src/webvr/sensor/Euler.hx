package webvr.sensor;

/*
 * Partial haxe port of three.js Euler class
 * by https://github.com/modjke/
 */

@:enum
abstract Order(String) to String
{
	var XYZ = "XYZ";
	var YXZ = "YXZ";
	var ZXY = "ZXY";
	var ZYX = "ZYX";
	var YZX = "YZX";
	var XZY = "XZY";
}

class Euler 
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0) 
	{
		
	}
	
	/**
	 * Order is XYZ	 
	 */
	public function setFromQuaternion(q:Quaternion, order:Order)
	{
		var x = q.x, y = q.y, z = q.z, w = q.w;
		var x2 = x + x, y2 = y + y, z2 = z + z;
		var xx = x * x2, xy = x * y2, xz = x * z2;
		var yy = y * y2, yz = y * z2, zz = z * z2;
		var wx = w * x2, wy = w * y2, wz = w * z2;
		
		var m11 = 1 - ( yy + zz );
		var m12 = xy - wz;
		var m13 = xz + wy;
		var m21 = xy + wz;
		var m22 = 1 - ( xx + zz );
		var m23 = yz - wx;
		var m31 = xz - wy;
		var m32 = yz + wx;
		var m33 = 1 - ( xx + yy );
		
		inline function clamp(v:Float, min:Float, max:Float) return Math.max(min, Math.min(max, v));
		
		switch (order)
		{
			case XYZ:
				this.y = Math.asin( clamp( m13, - 1, 1 ) );

				if ( Math.abs( m13 ) < 0.99999 ) {

					this.x = Math.atan2( - m23, m33 );
					this.z = Math.atan2( - m12, m11 );

				} else {

					this.x = Math.atan2( m32, m22 );
					this.z = 0;

				}
			case YXZ:
				this.x = Math.asin( - clamp( m23, - 1, 1 ) );

				if ( Math.abs( m23 ) < 0.99999 ) {

					this.y = Math.atan2( m13, m33 );
					this.z = Math.atan2( m21, m22 );

				} else {

					this.y = Math.atan2( - m31, m11 );
					this.z = 0;

				}
			
			case ZXY:
				this.x = Math.asin( clamp( m32, - 1, 1 ) );

				if ( Math.abs( m32 ) < 0.99999 ) {

					this.y = Math.atan2( - m31, m33 );
					this.z = Math.atan2( - m12, m22 );

				} else {

					this.y = 0;
					this.z = Math.atan2( m21, m11 );

				}
			case ZYX:
				this.y = Math.asin( - clamp( m31, - 1, 1 ) );

				if ( Math.abs( m31 ) < 0.99999 ) {

					this.x = Math.atan2( m32, m33 );
					this.z = Math.atan2( m21, m11 );

				} else {

					this.x = 0;
					this.z = Math.atan2( - m12, m22 );

				}
			case YZX:
				this.z = Math.asin( clamp( m21, - 1, 1 ) );

				if ( Math.abs( m21 ) < 0.99999 ) {

					this.x = Math.atan2( - m23, m22 );
					this.y = Math.atan2( - m31, m11 );

				} else {

					this.x = 0;
					this.y = Math.atan2( m13, m33 );

				}
				
			case XZY:
				this.z = Math.asin( - clamp( m12, - 1, 1 ) );

				if ( Math.abs( m12 ) < 0.99999 ) {

					this.x = Math.atan2( m32, m22 );
					this.y = Math.atan2( m13, m11 );

				} else {

					this.x = Math.atan2( - m23, m33 );
					this.y = 0;

				}
		}
		
	}
	
}