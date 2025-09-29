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
- animate with play

## Requests
New ideas are welcome. Anything is possible so don't hesitate.
Current to do list: see [issue](https://github.com/AlexisRenchon/ClimaViz.jl/issues/1)
