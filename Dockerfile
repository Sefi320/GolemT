# Base image: R + Shiny Server on Ubuntu
FROM rocker/shiny:latest

# System libraries required by arrow, plotly, and other dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install remotes so we can install from GitHub
RUN R -e "install.packages('remotes', repos='https://cran.rstudio.com/')"

# Install all CRAN dependencies
RUN R -e "install.packages(c( \
    'arrow', 'bslib', 'config', 'dplyr', 'fabletools', 'feasts', \
    'golem', 'lubridate', 'plotly', 'shiny', 'shinipsum', 'slider', \
    'stringr', 'tsibble', 'magrittr', 'purrr', 'tidyr', 'rugarch' \
    ), repos='https://cran.rstudio.com/')"

# Install RTL from GitHub (development version — not on CRAN)
RUN R -e "remotes::install_github('risktoollib/RTL')"

# Copy the GolemT package source into the image and install it
# This includes inst/extdata/ (the pre-fetched feather data files)
COPY . /app
RUN R -e "remotes::install_local('/app', dependencies = FALSE)"

# Expose Shiny port
EXPOSE 3838

# Run the app (host 0.0.0.0 makes it reachable from outside the container)
CMD ["R", "-e", "GolemT::run_app(options = list(host = '0.0.0.0', port = 3838))"]
