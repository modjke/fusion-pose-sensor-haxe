package webvr.sensor;


/*
 * Copyright 2015 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Partial haxe port by https://github.com/modjke/
 */

class Vector3 
{

	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0) 
	{
		this.x = x;
		this.y = y;
		this.z = z;			
	}
	
	public function copy(v:Vector3):Vector3
	{
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
		
		return this;
	}
	
	public function normalize():Vector3
	{
		var scalar = length();
		if (scalar > 0)
		{
			multiplyScalar( 1 / scalar );
		} else {
			x = 0;
			y = 0;
			z = 0;
		}
		
		return this;
	}
	
	public function set(x:Float, y:Float, z:Float)
	{
		this.x = x;
		this.y = y;
		this.z = z;			
	}
	
	public function multiplyScalar(scalar:Float):Vector3
	{
		x *= scalar;
		y *= scalar;
		z *= scalar;
		return this;
	}
	
	public function length()
	{
		return Math.sqrt( this.x * this.x + this.y * this.y + this.z * this.z );
	}
	
	public function dot(v:Vector3)
	{
		return x * v.x + y * v.y + z * v.z;
	}
	
	public function crossVectors(a:Vector3, b:Vector3)
	{
		var ax = a.x, ay = a.y, az = a.z;
		var bx = b.x, by = b.y, bz = b.z;

		this.x = ay * bz - az * by;
		this.y = az * bx - ax * bz;
		this.z = ax * by - ay * bx;

		return this;
	}
	
	public function applyQuaternion(q:Quaternion) 
	{
		var x = this.x;
		var y = this.y;
		var z = this.z;

		var qx = q.x;
		var qy = q.y;
		var qz = q.z;
		var qw = q.w;

		// calculate quat * vector
		var ix =  qw * x + qy * z - qz * y;
		var iy =  qw * y + qz * x - qx * z;
		var iz =  qw * z + qx * y - qy * x;
		var iw = - qx * x - qy * y - qz * z;

		// calculate result * inverse quat
		this.x = ix * qw + iw * - qx + iy * - qz - iz * - qy;
		this.y = iy * qw + iw * - qy + iz * - qx - ix * - qz;
		this.z = iz * qw + iw * - qz + ix * - qy - iy * - qx;

		return this;
	}

}