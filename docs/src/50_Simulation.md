## Simulation

The code in this simulation is written in Matlab and can be downloaded from [github.com/leetware/IMUAttitudeSimulation](https://github.com/leetnz/IMUAttitudeSimulation).

The simulation operates in a 2D plane where:
* the plane axes are $y$ and $z$
* the axis orthogonal to the simulated plane is $x$
* the angle about $x$ is $\theta$ and follows the right-handed rule

### Dynamics model

We want to expose a simulated body to $y$ and $z$ accelerations, and torques about $\theta$.

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
    \ddot{\theta}^{offset} &= \frac{4\pi}{360} (1 - 2 \times rand([0,1])) \\
    \ddot{\theta}^{stddev} &= \frac{\pi}{360} (1 - 2 \times rand([0,1]))
\end{split}
$$

The IMU equations in the *System of equations* section shows how simulation accelerations and rates are transformed into IMU measurements. The only missing conversion is that noise is computed on each step as follows:

$$
\begin{split}
    \ddot{y}^{noise}_k &= rand(\mathcal{N}(0, \ddot{y}^{stddev})) \\
    \ddot{z}^{noise}_k &= rand(\mathcal{N}(0, \ddot{z}^{stddev}))  \\
    \ddot{\theta}^{noise}_k &= rand(\mathcal{N}(0, \ddot{\theta}^{stddev})) 
\end{split}
$$


The plot below shows IMU simulated accelerometer data across a number of monte-carlo simulations. The estimator is judged and improved based on its statistical performance against hundreds of monte-carlo simulations.

![IMU accelerometer with offset and noise](src/images/montecarloIMUAccY.gif)

### Estimator

Outline the compared estimators and what gains are used

Outline how we handle wrap around (shorted radian path + wrapPi)

Show the comparative results of a single simulation

Show the comparative results of a monte carlo vs. Accel or Gyro on thier own (error, mean squared error etc)

