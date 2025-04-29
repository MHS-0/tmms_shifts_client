# FROM ubuntu AS build

FROM ubuntu
RUN apt-get update
RUN apt-get install -y curl git unzip
COPY . /app
WORKDIR /app
RUN git clone --branch stable --single-branch https://www.github.com/flutter/flutter.git 
ENV PATH "/app/flutter/bin:${PATH}"
RUN flutter clean
RUN flutter pub get
RUN flutter gen-l10n
RUN dart run build_runner build
RUN flutter build web
CMD ["flutter", "run", "-d", "web-server", "--web-port=80", "--web-hostname=0.0.0.0", "--release"]
# FROM ubuntu
# COPY --from=build /app /app
# ENV PATH="/app/flutter/bin:${PATH}"
# RUN apt-get update
# RUN apt-get install -y curl git unzip
# RUN flutter run -d web-server --web-port=80
