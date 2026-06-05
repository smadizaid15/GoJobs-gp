# Stage 1: Build Environment
FROM debian:stable-slim AS build-env

# 1. Install ALL necessary system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone the stable branch directly to save time/memory
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# 3. Pre-initialize and explicitly enable web
RUN flutter doctor -v
RUN flutter config --enable-web

# 4. Copy app files and build
WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release --verbose


# Stage 2: Production Environment
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

# Keep your custom entrypoint message
RUN echo -e '#!/bin/sh\necho "\n\n🟢 🟢 🟢 CLICK HERE: http://localhost:8080 🟢 🟢 🟢\n\n"' > /docker-entrypoint.d/99-print-link.sh && chmod +x /docker-entrypoint.d/99-print-link.sh

CMD ["nginx", "-g", "daemon off;"]