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

Finally, the Bittle MPU6050's sensor frame is not aligned with the Bittle's body frame. The transform between the sensor frame and body frame is a 180° rotation about the z-axis.

### Embedded algorithm

* Outline the embedded algorithm including alignment adjustments

### Experimental setup

* Describe the mounting of Raspberry pi on bittle with Camera
- place image of experimental bittle here.

* Describe the data capture/visualization

### Results

* Show video / frames of resulting experiment

