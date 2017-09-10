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

class PosePredictor 
{
	var predictionTimeS:Float;
	var previousQ = new Quaternion();
	var deltaQ = new Quaternion();
	var outQ = new Quaternion();
	var previousTimestampS:Float = null;

	public function new(predictionTimeS:Float) 
	{
		this.predictionTimeS = predictionTimeS;
	}
	
	public function getPrediction(currentQ:Quaternion, gyro:Vector3, timestampS:Float)
	{
		if (this.previousTimestampS == null) {
			this.previousQ.copy(currentQ);
			this.previousTimestampS = timestampS;
			return currentQ;
		}

		// Calculate axis and angle based on gyroscope rotation rate data.
		var axis = new Vector3();
		axis.copy(gyro);
		axis.normalize();

		var angularSpeed = gyro.length();

		// If we're rotating slowly, don't do prediction.
		if (angularSpeed < 20 * Math.PI / 180.0) {
			this.outQ.copy(currentQ);
			this.previousQ.copy(currentQ);
			return this.outQ;
		}

		// Get the predicted angle based on the time delta and latency.
		var deltaT = timestampS - this.previousTimestampS;
		var predictAngle = angularSpeed * this.predictionTimeS;

		this.deltaQ.setFromAxisAngle(axis, predictAngle);
		this.outQ.copy(this.previousQ);
		this.outQ.multiply(this.deltaQ);

		this.previousQ.copy(currentQ);
		this.previousTimestampS = timestampS;

		return this.outQ;
	}
}