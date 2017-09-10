package webvr.sensor;
import js.Browser;
import js.html.DeviceMotionEvent;
import js.html.DeviceOrientationEvent;
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

class FusionPoseSensor 
{

	var accelerometer = new Vector3();
	var gyroscope = new Vector3();
	var filter = new ComplementaryFilter(0.98);
	var posePredictor = new PosePredictor(0.040);
	var filterToWorldQ = new Quaternion();
	var inverseWorldToScreenQ = new Quaternion();
	var worldToScreenQ = new Quaternion();
	var originalPoseAdjustQ = new Quaternion();
	var resetQ = new Quaternion();	
	var isFirefoxAndroid = Util.isFirefoxAndroid();
	var isIOS = Util.isIOS();
	var out_ = new Quaternion();
	var previousTimestampS:Float;

	var predictedQ:Quaternion;
	
	public function new() 
	{
		
		filterToWorldQ.setFromAxisAngle(new Vector3(1, 0, 0), isIOS ? Math.PI / 2 : -Math.PI / 2);
		originalPoseAdjustQ.setFromAxisAngle(new Vector3(0, 0, 1), -Browser.window.orientation * Math.PI / 180);
		setScreenTransform();
		
		if (Util.isLandscapeMode())		
			filterToWorldQ.multiply(inverseWorldToScreenQ);
		
		start();
		
	}
	
	public function getOrientation():Quaternion
	{
		var orientation = filter.getOrientation();
		predictedQ = posePredictor.getPrediction(orientation, gyroscope, previousTimestampS);
		
		// Convert to THREE coordinate system: -Z forward, Y up, X right.
		out_.copy(this.filterToWorldQ);
		out_.multiply(this.resetQ);

		out_.multiply(this.predictedQ);
		out_.multiply(this.worldToScreenQ);

		return out_;
	}
	
	public function resetPose()
	{
		// Reduce to inverted yaw-only.
		this.resetQ.copy(this.filter.getOrientation());
		this.resetQ.x = 0;
		this.resetQ.y = 0;
		this.resetQ.z *= -1;
		this.resetQ.normalize();

		// Take into account extra transformations in landscape mode.
		if (Util.isLandscapeMode()) {
			this.resetQ.multiply(this.inverseWorldToScreenQ);
		}

		// Take into account original pose.
		this.resetQ.multiply(this.originalPoseAdjustQ);
	}
	
	function updateDeviceMotion(e:DeviceMotionEvent)
	{
		var accGravity = e.accelerationIncludingGravity;
		var rotRate = e.rotationRate;
		var timestampS = e.timeStamp / 1000;
	
		var deltaS = timestampS - this.previousTimestampS;
		if (deltaS <= Util.MIN_TIMESTEP || deltaS > Util.MAX_TIMESTEP) {
			//console.warn('Invalid timestamps detected. Time step between successive ' +
			//		'gyroscope sensor samples is very small or not monotonic');
			this.previousTimestampS = timestampS;
			return;
		}
		this.accelerometer.set(-accGravity.x, -accGravity.y, -accGravity.z);
		this.gyroscope.set(rotRate.alpha, rotRate.beta, rotRate.gamma);
	
		// With iOS and Firefox Android, rotationRate is reported in degrees,
		// so we first convert to radians.
		if (this.isIOS || this.isFirefoxAndroid) {
			this.gyroscope.multiplyScalar(Math.PI / 180);
		}
	
		trace(accelerometer.x, accelerometer.y, accelerometer.z, gyroscope.x, gyroscope.y, gyroscope.z);
		
		
		this.filter.addAccelMeasurement(this.accelerometer, timestampS);
		this.filter.addGyroMeasurement(this.gyroscope, timestampS);
	
		this.previousTimestampS = timestampS;
	}
	
	function setScreenTransform()
	{
		this.worldToScreenQ.set(0, 0, 0, 1);
		switch (Browser.window.orientation) {			
			case 90:
				this.worldToScreenQ.setFromAxisAngle(new Vector3(0, 0, 1), -Math.PI / 2);
			case -90:
				this.worldToScreenQ.setFromAxisAngle(new Vector3(0, 0, 1), Math.PI / 2);		
			default:	
		}
		this.inverseWorldToScreenQ.copy(this.worldToScreenQ);
		this.inverseWorldToScreenQ.inverse();
	}
	
	function _onOrientationChange(e:DeviceOrientationEvent)
	{
		setScreenTransform();
	}
	
	function _onDeviceMotion(e:DeviceMotionEvent)
	{
		updateDeviceMotion(e);
	}
	
	public function start()
	{
		Browser.window.addEventListener("devicemotion", _onDeviceMotion);
		Browser.window.addEventListener("orientationchange", _onOrientationChange);
	}
	
	public function stop()
	{
		Browser.window.removeEventListener("devicemotion", _onDeviceMotion);
		Browser.window.removeEventListener("orientationchange", _onOrientationChange);
	}
}