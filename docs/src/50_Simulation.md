## Simulation

### Dynamics model

![IMU accelerometer with offset and noise](src/images/montecarloIMUAccY.gif)




Outline what the system does and how inputs work

Show the result of simulate. 

### IMU model

Outline how noise and offset is selected

Show the result of simulate IMU

Show a monte carlo IMU simulation on accel and Gyro

### Estimator

Outline the compared estimators and what gains are used

Outline how we handle wrap around (shorted radian path + wrapPi)

Show the comparative results of a single simulation

Show the comparative results of a monte carlo vs. Accel or Gyro on thier own (error, mean squared error etc)
