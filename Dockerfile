# pull latest julia image
FROM --platform=linux/amd64 julia:latest

# create dedicated user
RUN useradd --create-home --shell /bin/bash genie

# set up the app
RUN mkdir /home/genie/app
COPY . /home/genie/app
WORKDIR /home/genie/app

# C compiler for PackageCompiler
RUN apt-get update && apt-get install -y g++

# configure permissions
RUN chown genie:genie -R *

# switch user
USER genie

# instantiate Julia packages
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile();"

# Compile app
RUN julia --project compiled/make.jl

RUN chmod +x bin/repl
RUN chmod +x bin/server
RUN chmod +x bin/runtask

# ports
EXPOSE 8000
EXPOSE 80

# set up app environment
ENV JULIA_DEPOT_PATH "/home/genie/.julia"
ENV GENIE_ENV "dev"
ENV HOST "0.0.0.0"
ENV PORT "8000"
ENV WSPORT "8000"
ENV EARLYBIND "true"

# run app
CMD ["bin/server"]
