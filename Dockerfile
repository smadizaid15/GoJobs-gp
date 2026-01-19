
FROM debian:latest AS build-env

RUN apt-get update && apt-get install -y curl git unzip
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter channel stable
RUN flutter upgrade

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN flutter pub get
RUN flutter build web


FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
# Add this line before the 'CMD' line:

RUN echo -e '#!/bin/sh\necho "\n\n🟢 🟢 🟢 CLICK HERE: http://localhost:8080 🟢 🟢 🟢\n\n"' > /docker-entrypoint.d/99-print-link.sh && chmod +x /docker-entrypoint.d/99-print-link.sh

# Start Nginx normally
CMD ["nginx", "-g", "daemon off;"]