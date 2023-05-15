# AS_Profile
in-situ acceleration-speed profile in team sports

______________________________________

Force velocity profiling is not specific to team sports actions, therefore accelaration-speed profiling can be assessed passively, save some proper testing sessions and bring continuous information about the athlete state of form (Morin et al. 2021).


## Raw data

Raw data is publicly available at https://libm-lab.univ-st-etienne.fr/as-profile/#/home

The example script ``AS_Profiling.m`` uses the time and speed data. A random noise is added to the speed data and then filtered with a 1-Hz lowpass 2nd order Butterworth filter as used in Clavel et al. 2023. Acceleration is computed with the first time derivative of speed.
$$a = \frac{dv}{dt}$$  

## Function
 
```MATLAB
function [A0,V0,r2,dataOut] = accSpeedProfile(data,col)
% A0 is the theoretical maximal acceleration (y- intercept of the AS linear relationship)
% S0 is the theoretical maxi- mal running speed (x-intercept of the AS relationship)
% r2 is the coefficient of determination
% dataOut is a table with 2 columns of speed and acceleration points retained
```

By specifying a 2 color RGB matric you can personalize the colors of the figure output
```MATLAB
accSpeedProfile(data,col)
```
![alt text](https://github.com/PabRD/AS_Profile/blob/main/yourColor_AS.png)


If you don't specify any 2nd input
```MATLAB
accSpeedProfile(data)
```

![alt text](https://github.com/PabRD/AS_Profile/blob/main/basicColor_AS.png)


__________________________________

Morin, J. B., Le Mat, Y., Osgnach, C., Barnabò, A., Pilati, A., Samozino, P., & di Prampero, P. E. (2021). Individual acceleration-speed profile in-situ: A proof of concept in professional football players. Journal of Biomechanics, 123, 110524. https://doi.org/10.1016/j.jbiomech.2021.110524

Clavel, P., Leduc, C., Morin, J., Buchheit, M., & Lacome, M. (2023). Reliability of individual acceleration-speed profile in-situ in elite youth soccer players. Journal of Biomechanics, 153(April), 111602. https://doi.org/10.1016/j.jbiomech.2023.111602
