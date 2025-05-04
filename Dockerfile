From instrumentisto/flutter:3.29.3 AS build

RUN apt-get update
RUN apt-get install -y curl git unzip nginx
COPY . /app
WORKDIR /app

# Build the flutter project for web
RUN flutter clean
RUN flutter pub get
RUN flutter gen-l10n
RUN dart run build_runner build
RUN flutter build web

FROM nginx AS runtime
# Download the Flutter framework so that we can use flutter and dart commands.
# 
# This usually takes a long time, so for iterative purposes, just copy and paste the flutter sdk folder
# on your system into the root directory of this project (alongside this same Dockerfile) and then comment
# the line below.
# RUN git clone --branch stable --single-branch https://www.github.com/flutter/flutter.git 
# ENV PATH "/app/flutter/bin:${PATH}"
COPY --from=build /app /app

# Remove the default nginx stuff and replace it with our Flutter web app
RUN rm -rf /usr/share/nginx/html
RUN mv /app/build/web /usr/share/nginx/html

# IMPORTANT:
# For the 443 port (SSL) to work, you'd need to modify the [/etc/nginx/conf.d/default.conf] file and
# add your certifiacates.
# You could use these commands to help you do this:
# $ apt install python-certbot-nginx
# $ certbot --nginx -d [your_domain] -d www.[your_domain]
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
