# ClimaViz.jl

This is a prototype for a convenient viz of CliMA models (ClimaLand, ClimaAtmos, ClimaCoupler) outputs.

```julia
using ClimaViz
dashboard(path)
```

Will launch a dashboard in a web browser.

It works from HPC as well, all you need is ssh as usual but with port forwarding

```shell
ssh -L 8080:localhost:8080 user@ssh.example.com
```

and then open this URL on your local browser:

http://localhost:8080/

## Features

implemented:
- global map of variables var at time t, height h
- animate with play

## Requests
New ideas are welcome. Anything is possible so don't hesitate.
Current to do list: see [issue](https://github.com/AlexisRenchon/ClimaViz.jl/issues/1)

<img width="1522" height="1044" alt="image" src="https://github.com/user-attachments/assets/2926903b-4f36-4e2e-9456-0721f2d6f227" />
