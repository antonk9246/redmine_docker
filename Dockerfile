FROM redmine:4.2

# Устанавливаем системные зависимости для компиляции gems
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    gcc \
    g++ \
    libpq-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем зависимости для плагинов
RUN bundle config set without 'development test'