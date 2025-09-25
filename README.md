# ClimaViz.jl

This is a prototype for a convenient viz of CliMA models (ClimaLand, ClimaAtmos, ClimaCoupler) outputs.

```julia
using ClimaViz
dashboard(path)
```

Will launch a dashboard in a web browser.

It works from HPC as well, all you need is ssh as usual but with port forwarding

```shell
ssh -R 9384:localhost:9384 user@ssh.example.com
```

and then open this URL on your local browser:

http://localhost:9384/browser-display

## Features

implemented:
- global map of variables var at time t

To be implemented:
- slider for height h
- textbox for var (so user can use either menu or textbox)
- ax for vertical profile of a var at time t, lon and lat, by clicking on a location
