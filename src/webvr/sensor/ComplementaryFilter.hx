package webvr.sensor;
import webvr.sensor.Quaternion;
import webvr.sensor.SensorSample;
import webvr.sensor.Util;
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

class ComplementaryFilter 
{

	var kFilter:Float;
	var filterQ = new Quaternion(Util.isIOS() ? -1 : 1, 0, 0, 1);
	var accelQ = new Quaternion();
	var isOrientationInitialized = false;
	var estimatedGravity = new Vector3();
	var measuredGravity = new Vector3();
	var gyroIntegralQ = new Quaternion();
	var previousFilterQ = new Quaternion();
	var currentAccelMeasurement = new SensorSample();
	var currentGyroMeasurement = new SensorSample();
	var previousGyroMeasurement = new SensorSample();
	
	public function new(kFilter:Float) 
	{
		this.kFilter = kFilter;
		previousFilterQ.copy(filterQ);
		
		
	}
	
	public function getOrientation()
	{
		return filterQ;
	}
	
	public function addAccelMeasurement(vector:Vector3, timestampS:Float)
	{
		this.currentAccelMeasurement.set(vector, timestampS);
	}
	
	public function addGyroMeasurement(vector:Vector3, timestampS:Float)
	{
		this.currentGyroMeasurement.set(vector, timestampS);
		
		var deltaT = timestampS - previousGyroMeasurement.timestampS;
		if (Util.isTimestampDeltaValid(deltaT))
			run();
			
		previousGyroMeasurement.copy(currentGyroMeasurement);
	}
	
	function run()
	{
		if (!this.isOrientationInitialized) {
			this.accelQ = this.accelToQuaternion(this.currentAccelMeasurement.sample);
			this.previousFilterQ.copy(this.accelQ);
			this.isOrientationInitialized = true;
			return;
		}

		var deltaT = this.currentGyroMeasurement.timestampS - this.previousGyroMeasurement.timestampS;

		  // Convert gyro rotation vector to a quaternion delta.
		  var gyroDeltaQ = this.gyroToQuaternionDelta(this.currentGyroMeasurement.sample, deltaT);
		  this.gyroIntegralQ.multiply(gyroDeltaQ);

		  // filter_1 = K * (filter_0 + gyro * dT) + (1 - K) * accel.
		  this.filterQ.copy(this.previousFilterQ);
		  this.filterQ.multiply(gyroDeltaQ);

		  // Calculate the delta between the current estimated gravity and the real
		  // gravity vector from accelerometer.
		  var invFilterQ = new Quaternion();
		  invFilterQ.copy(this.filterQ);
		  invFilterQ.inverse();

		  this.estimatedGravity.set(0, 0, -1);
		  this.estimatedGravity.applyQuaternion(invFilterQ);
		  this.estimatedGravity.normalize();

		  this.measuredGravity.copy(this.currentAccelMeasurement.sample);
		  this.measuredGravity.normalize();

		  // Compare estimated gravity with measured gravity, get the delta quaternion
		  // between the two.
		  var deltaQ = new Quaternion();
		  deltaQ.setFromUnitVectors(this.estimatedGravity, this.measuredGravity);
		  deltaQ.inverse();

		  
		  // Calculate the SLERP target: current orientation plus the measured-estimated
		  // quaternion delta.
		  var targetQ = new Quaternion();
		  targetQ.copy(this.filterQ);
		  targetQ.multiply(deltaQ);

		  // SLERP factor: 0 is pure gyro, 1 is pure accel.
		  this.filterQ.slerp(targetQ, 1 - this.kFilter);

		  this.previousFilterQ.copy(this.filterQ);
	}
	
	function accelToQuaternion(accel:Vector3)
	{
		var normAccel = new Vector3();
		normAccel.copy(accel);
		normAccel.normalize();
		var quat = new Quaternion();
		quat.setFromUnitVectors(new Vector3(0, 0, -1), normAccel);
		quat.inverse();
		return quat;
	}
	
	function gyroToQuaternionDelta(gyro:Vector3, dt:Float)
	{
		var quat = new Quaternion();
		var axis = new Vector3();
		axis.copy(gyro);
		axis.normalize();
		quat.setFromAxisAngle(axis, gyro.length() * dt);
		return quat;
	}
}