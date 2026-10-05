FROM ghcr.io/cirruslabs/flutter:3.38.9 AS build

ARG API_URL=https://your-backend.onrender.com
ARG API_KEY=your-api-key

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --dart-define=API_URL=${API_URL} --dart-define=API_KEY=${API_KEY}

FROM nginx:1.27-alpine
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html
ENV PORT=8080
EXPOSE 8080
