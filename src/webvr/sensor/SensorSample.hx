package webvr.sensor;
import webvr.sensor.Vector3;


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
 * Haxe port by https://github.com/modjke/
 */

class SensorSample 
{

	public var sample(default, null):Vector3;
	public var timestampS(default, null):Float;
	
	public function new(?sample:Vector3, ?timestampS:Float) 
	{
		set(sample, timestampS);
	}
	
	public function set(?sample:Vector3, ?timestampS:Float) 
	{
		this.sample = sample;
		this.timestampS = timestampS;
	}

	public function copy(other:SensorSample)
	{
		this.sample = other.sample;
		this.timestampS = other.timestampS;
	}
}