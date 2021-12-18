## Implementing on Bittle

To demonstrate the behavior of the estimator on a real system; the estimator was implemented on Petoi's Bittle.

![Petoi's Bittle With Raspberry Pi and Camera](src/images/60_bittle.jpg)


Bittle is a quadrapedal robot which is controlled by Petoi's NyBoard. The NyBoard's microcontroller is the ATMega328P which is a 16Mhz single-core 8-bit microcontroller with only 2kB of RAM. The NyBoard uses InvenSense's MPU6050 IMU. 

The motion and peripheral algorithms leave only a handful of bytes avaliable for attitude determination. There is also a trade-off between update period and computational power. We want to update frequently for improved gyroscope estimates; however, the ATMega328P is limited in the number of operations it can complete between updates.

The embedded implementation on Bittle has the following characteristics:

* Updates at 100Hz
* Configures the MPU6050 with:
  * a low-pass filter with a 100Hz corner frequency
  * an accelerometer range of ±1g
  * a gyroscope range of ±1000°/s

The Bittle MPU6050's sensor frame is not aligned with the Bittle's body frame. The transform between the sensor frame and body frame is a 180° rotation about the z-axis.

![NyBoard IMU is misaligned by 180 degrees](src/images/60_bittleOrientations.jpg)


### Embedded algorithm

The core of the Embedded algorithm is available on [https://github.com/leetnz/Bittleet/](https://github.com/leetnz/Bittleet/blob/main/src/state/Attitude.cpp).

Bittle samples three accelerometer and three gyroscope readings through I2C at 400kHz. Each value is represented by a 16-bit integer count. 

A small transform is made to IMU measurements to move the x and y axes from the sensor frame into the body frame:

$$
\begin{split}
    \dot{\phi}^{gyro}_k &= -\dot{\phi}^{imu}_k \\
    \dot{\theta}^{gyro}_k &= -\dot{\theta}^{imu}_k \\
    \ddot{x}^{accel}_k &= -\ddot{x}^{imu}_k \\
    \ddot{y}^{accel}_k &= -\ddot{y}^{imu}_k
\end{split}
$$

Where:

* $\dot{\phi}$ represents the rate on the x axis
* $\dot{\theta}$ represents the rate on the y axis

Now that we want estimates of $\theta$, we define the accelerometer estimator used for $y$:

$$
\begin{split}
    \bar{\theta}^{accel}_{k} &= \tan^{-1}\left(\frac{-\ddot{x}^{accel}_k}{\ddot{z}^{accel}_k}\right) \\
\end{split}
$$

When computing the accelrometer estimates, we do not convert the raw values into accelerations or units of $g$. Instead we represent $1g$ in units of counts. Trigonometry works in any unit, so this is a slight optimization to avoid floating point arithmetic which the ATMega328P is not suited for.

The trust function is computed once per iteration using the linearized trust function which reduces computational load by avoiding a square root.

The overall breakdown of timings is shown below:

| Function   | Timing  |
|------------|---------|
| Sample IMU | 1920 us |
| Estimator  | 1200 us |

This allows a maximum sample rate of 300 Hz. 
Bittle firmware is also responsible for actuating servos and taking user commands; so a compromise of 100Hz sampling is used.

### Experimental setup

The code used to capture data in this experiment is available on [https://github.com/leetnz/imuAttitudeProcessing](https://github.com/leetnz/imuAttitudeProcessing)

The goal of this experiment was to visualize the difference between Bittle's perceived attitude, and the true attitude. To achieve this goal, we needed two sets of sensors:

* The IMU which is used for attitude estimation
* A camera, which can record the "true" attitude of bittle for comparison

The `logCapture.py` script runs on the RaspberryPi attached to Bittle. For the length of the experiment it:

* Stores serial csv data from the NyBoard which contains time and attitude estimates
* Captures video output

Both the serial data and video outputs are at 25Hz.

### Results

The following shows bittle being moved in the roll direction with the roll estimate overlayed.

![Bench Testing Estimator on Bittle - Side to Side](src/images/60_estimatorBench.gif)

![Bench Testing Estimator on Bittle - Flip](src/images/60_estimatorFlip.gif)

The next figure shows bittle walking on uneven carpet causing bittle to fall over - which is quite helpful for demonstrating a real-world application of requiring responsive dynamic estimation.

![Testing Estimator on Bittle - Walk](src/images/60_estimatorWalk.gif)

The video [https://youtu.be/kj7YloDtiZY](https://youtu.be/kj7YloDtiZY) demonstrates this estimator operating alongside video at 25 FPS.

#### Issues with Gimbal lock

In the above demonstrations, when bittle is rolled more than 90 degrees, the accelerometer-based pitch estimate reaches a discontinuity, where it goes from 0 degrees to 180 degrees. 

This is a weakness of the representation of state in this estimator. Using Euler angles will always result in gimbal-lock derived discontinuities - in this case, pitch aligning with yaw. A quaternion representation of attitude would resolve this issue, but is beyond the scope of this paper.

This estimator is still useful for the following scenarios:

* We only require estimation in one axis
* The body is not expected to exceed $[-90^\circ, 90^\circ]$ in any axis under normal operation

Bittle meets the second requirement, where we assume if it has reached or exceeded 90 degrees, it has fallen over.
