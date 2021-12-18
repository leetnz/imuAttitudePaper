## Introduction

This paper outlines an attitude estimator using gyroscope and accelerometer measurements. The outputs of the estimator are roll (x-axis) and pitch (y-axis) in a right-handed system where gravity is aligned with the z-axis when all angles are zero.

### An estimator in the hand is worth two in the bush

A digital gyroscope-only estimator using trapezoidal integration on step $K$ is given by:

$$
\bar{\phi}_{K}^{gyro} = \phi_{0} + {\sum_{k=1}^K} \frac{\dot{\phi}_k + \dot{\phi}_{k-1}}{2}\Delta t_k
$$

Where:

* $\phi_{0}$ is the initial angle
* $\bar{\phi}_{K}^{gyro}$ is the $K^{th}$ estimated angle
* $\dot{\phi}_k$ is the gyroscope measurement on the $k^{th}$ sample
* $\Delta t_k$ is the change in time since the previous sample

Discrete integration causes the gyroscope estimator to drift due to:

* Offets and misalignment in $\dot{\phi}$ measurements
* Dynamics not measured between samples

A digital accelerometer-only estimator using trigonometry on step $K$ is given by:

$$
\bar{\phi}_{K}^{accel} = \tan^{-1}\left(\frac{\ddot{y}_K}{\ddot{z}_K}\right)
$$

Where:

* $\bar{\phi}_{K}^{accel}$ is the $K^{th}$ estimated angle
* $\ddot{z}_K$ and $\ddot{y}_K$ are the $K^{th}$ acceleration measurements

The accelerometer estimator assumes the accelerometer is only measuring gravity; typically, this only holds when the measured object is stationary.

Both estimators have a tendency to run off under various conditions. However, they both provide complimentry properties - the accelerometer estimator provides a "lost-in-space" estimate to compensate for drift; meanwhile, the gyroscope estimator provides reasonable dynamic estimates.

### Combining sensors

In the following sections, a Kalman filter is designed to fuse the accelerometer and gyroscope estimates. Some drawbacks of Kalman filters are:

* Filter gains are too abstract to base on physical properties
* Requires a matrix inversion, which can be computationally too intense for some bare-metal embedded systems

An alternative apporach is taken using a complementary filter with a dynamic gain computed using a trust function. This approach is equivalent to the core behaiour of a Kalman filter, but is more intuitive to tune and runs quickly on resource limited embedded systems.
