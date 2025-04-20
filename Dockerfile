FROM ubuntu AS build

RUN apt-get update
RUN apt-get install -y curl git unzip
RUN git clone --branch stable --single-branch https://github.com/flutter/flutter.git 
ENV PATH="/flutter/bin:${PATH}"
COPY . /app
WORKDIR /app
RUN flutter clean
RUN flutter build web
FROM ubuntu
COPY --from=build /app /app
COPY --from=build /flutter /
ENV PATH="/flutter/bin:${PATH}"
RUN flutter run -d web-server --web-port=80
