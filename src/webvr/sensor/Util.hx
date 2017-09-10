package webvr.sensor;
import js.Browser.*;


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

class Util 
{
	
	public inline static var MIN_TIMESTEP = 0.001;
	public inline static var MAX_TIMESTEP = 1;

	public static function isIOS():Bool
	{
		return ~/iPad|iPhone|iPod/.match(navigator.platform);
	}
	
	public static function isLandscapeMode():Bool
	{
		return (window.orientation == 90 || window.orientation == -90);
	}
	
	public static function isTimestampDeltaValid(timestampDeltaS:Float)
	{		
		return !Math.isNaN(timestampDeltaS) && timestampDeltaS > MIN_TIMESTEP && timestampDeltaS < MAX_TIMESTEP;
	}
	
	public static function isFirefoxAndroid():Bool
	{
		return  navigator.userAgent.indexOf('Firefox') > -1 &&
				navigator.userAgent.indexOf('Android') > -1;
	}
}