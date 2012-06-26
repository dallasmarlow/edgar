## edgar
capacity planning and time series forecasting service (using R)

![](http://cl.ly/0c2W0p3x402I291j1t1v/Screen%20Shot%202012-06-26%20at%206.21.21%20PM.png)
![](http://cl.ly/0D0t1d3O0G201q0P3T10/Screen%20Shot%202012-06-26%20at%206.30.39%20PM.png)

## installation and requirements

### R
install R

```
~# brew install r
```

once you have R installed you will need to install the forecast and Rserve packages

```
~# R

R version 2.15.0 (2012-03-30)
Copyright (C) 2012 The R Foundation for Statistical Computing
ISBN 3-900051-07-0
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> install.packages('forecast', 'Rserve')
```

### Ruby
  install a version of ruby 1.9.x (mri) using your prefered method, some examples:

  - https://github.com/sstephenson/rbenv/
  - https://rvm.io/
  - or use your operating systems package manager

  once you have ruby installed, install the bundler gem and use bundle install.

```
~# gem install bundler
~# bundle install # from inside the root directory of your clone

```

## running

from the root of the clone

```
~# rainbows -c config/rainbows.rb
```

edgar should be running at http://0.0.0.0:8080 ^_^