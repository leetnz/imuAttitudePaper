## Simulation

The code in this simulation is written in Matlab and can be downloaded from [github.com/leetware/IMUAttitudeSimulation](https://github.com/leetnz/IMUAttitudeSimulation).

The simulation operates in a 2D plane where:
* the plane axes are $y$ and $z$
* the axis orthogonal to the simulated plane is $x$
* the angle about $x$ is $\phi$ and follows the right-handed rule

### Dynamics model

We want to expose a simulated body to $y$ and $z$ accelerations, and torques about $\phi$.

To do this an imaginary body was simulated in a mystery environment where:
* $y$ and $z$ directions have constant damping
* $theta$ has constant damping
* gravity is detected by the imu, but never acts on the body
  * simulating surfaces was not necessary for this simulation

The governing state-space equations were presented in the **System of equations** section.

A simulation using sinusoidal forces and torques for a portion of the simulation is shown below:

![Resultant dynamics of simulation with sinusoidal-like inputs](src/images/50_dynamicsSim.png)

### IMU model

The IMU model has three sensors to simulate:
* Accelerometer Y
* Accelerometer Z
* Gyroscope X

Note: in this simulation, the accelerometer measures in $g$ where $1g = 9.81 \frac{m}{s}$. This is typical of many IMUs.

Noise and offset are selected using a random function. This improves tuning since I don't want to assume I know the exact offsets/noise profile of the IMU I am using.

$$
\begin{split}
    \ddot{y}^{offset} &= 0.01 \times rand(\mathcal{N}(0, 0.01)) \\
    \ddot{y}^{stddev} &= 0.005 - 0.010 \times rand([1, 2]) \\
    \ddot{z}^{offset} &= 0.01 \times rand(\mathcal{N}(0, 0.01)) \\
    \ddot{z}^{stddev} &= 0.005 - 0.010 \times rand([1, 2]) \\
    \ddot{\phi}^{offset} &= \frac{4\pi}{360} (1 - 2 \times rand([0,1])) \\
    \ddot{\phi}^{stddev} &= \frac{\pi}{360} (1 - 2 \times rand([0,1]))
\end{split}
$$

The IMU equations in the *System of equations* section shows how simulation accelerations and rates are transformed into IMU measurements. The only missing conversion is that noise is computed on each step as follows:

$$
\begin{split}
    \ddot{y}^{noise}_k &= rand(\mathcal{N}(0, \ddot{y}^{stddev})) \\
    \ddot{z}^{noise}_k &= rand(\mathcal{N}(0, \ddot{z}^{stddev}))  \\
    \ddot{\phi}^{noise}_k &= rand(\mathcal{N}(0, \ddot{\phi}^{stddev})) 
\end{split}
$$


The plot below shows IMU simulated accelerometer data across a number of monte-carlo simulations. The estimator is judged and improved based on its statistical performance against hundreds of monte-carlo simulations.

![IMU accelerometer with offset and noise](src/images/50_monteCarloIMUAccY.gif)

### Estimator

Three estimators were compared:
* Accelerometer only estimator
* Gyro only estimator
* Complimentry trust estimator

#### Handling angular wrap-around

A practical implementation of the complimentry trust estimator needs to handle angle wrap-around. The important parts are:
* When finding the difference between two angles, a shortest radian path algorithm is used
  * This algorithm ensures that the magnitude of angles when computing a difference is never greater than pi
* All estimates of $\phi$ are wrapped into the range $[-\pi, +\pi]$

#### Results - Single Simulation

A single run of the simulated system is shown below.

![Estimator comparison single simulation](src/images/50_estimatorsSingle.png)

The following observations are important:
* The accelerometer-only estimator becomes poor when there are dynamics in the system
* The gyroscope estimator drifts and becomes less accurate the longer the simulation runs
* The complimentry trust estimator:
  * rejects the accelerometer estimates once the dynamics become too large
  * corrects for gyroscope drift once the accelerometer estimates are trusted again

#### Results - Monte Carlo

To compare performance between estimators, the simulations were run 100 times with the following results:

![Monte Carlo Accelerometer-Only Estimator](src/images/50_monteCarloAccel.png)

The accelerometer-only estimator is non-recursive, so noise and offsets do not aggregate over time.

![Monte Carlo Gyroscope-Only Estimator](src/images/50_monteCarloGyro.png)

The gyroscope-only estimator is recursive, noise and offsets cause estimates to drift relative to the inaccuracies of the sensor.

![Monte Carlo Complimentry Trust Estimator](src/images/50_monteCarloCTE.png)

The complimentry trust estimator combines properties of both estimators - it is prone to drift during dynamics, but will reconverge once acclerometer measurements become accurate again.

![Monte Carlo Estimator Mean Square Error](src/images/50_monteCarloMSE.png)

The mean-squared error across simulations is indicative of the general performance of the estimators. The result is a little misleading since gyro errors get larger the longer the simulation runs, and the other two estimator's errors will decrease assuming there are no more inputs to the system.
