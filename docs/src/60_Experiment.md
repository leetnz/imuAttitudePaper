## Implementing on Bittle

To demonstrate the behavior of the estimator on a real system; the estimator was implemented on Petoi's Bittle.

Bittle is a quadrapedal robot which is controlled by Petoi's NyBoard. The NyBoard's microcontroller is the ATMega328P which is a 16Mhz single-core 8-bit microcontroller with only 2kB of RAM. The NyBoard uses InvenSense's MPU6050 IMU. 

The motion and peripheral algorithms leave only a handful of bytes avaliable for attitude determination. There is also a trade-off between update period and computational power. We want to update frequently for improved gyroscope estimates; however, the ATMega328P is limited in the number of operations it can complete between updates.

The embedded implementation on Bittle has the following characteristics:
* Updates at 100Hz
* Configures the MPU6050 with:
  * a low-pass filter with a 100Hz corner frequency
  * an accelerometer range of ±1g
  * a gyroscope range of ±1000°/s

The Bittle MPU6050's sensor frame is not aligned with the Bittle's body frame. The transform between the sensor frame and body frame is a 180° rotation about the z-axis.

### Embedded algorithm

The core of the Embedded algorithm is available on [https://github.com/leetnz/Bittleet/](https://github.com/leetnz/Bittleet/blob/main/src/state/Attitude.cpp).

Bittle samples three accelerometer and three gyroscope readings through I2C at 400kHz. Each value is represented by a 16-bit integer count. 

A small transform is made to IMU measurements to move the x and y axes from the sensor frame into the body frame:
* $\dot{\phi}^{gyro}_k = -\dot{\phi}^{imu}_k$
* $\dot{\theta}^{gyro}_k = -\dot{\theta}^{imu}_k$
* $\ddot{x}^{accel}_k = -\ddot{x}^{imu}_k$
* $\ddot{y}^{accel}_k = -\ddot{y}^{imu}_k$

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

| Function | Sample IMU | Estimation |
|----------|------------|------------|
| microseconds | TODO | TODO |

This allows a maximum sample rate of TODO Hz. 
Bittle firmware is also responsible for actuating servos and taking user commands; so a compromise of 100Hz sampling is used to balance these requirements.

### Experimental setup

* Describe the mounting of Raspberry pi on bittle with Camera
- place image of experimental bittle here.

* Describe the data capture/visualization

### Results

* Show video / frames of resulting experiment

