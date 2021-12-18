## Conclusion

The complimentry trust algorithm presented in this paper estimates attitude in a single axis using a three axis accelerometer and a gyroscope measurement on the axis to be estimated.

The key features of the estimator are:

* computationally simple as demonstrated on a 16Mhz 8-Bit microcontroller:
  * runs at 100Hz consuming less than 33% of CPU
  * uses only a handful of bytes of RAM
* tuning parameters have physcial meaning

In cases where gimbal lock discontinuities can be tolerated, this algorithm may be applied to more than one axis, as demonstrated on Petoi's Bittle for fall detection.
