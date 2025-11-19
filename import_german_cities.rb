#!/usr/bin/env ruby

# Скрипт для импорта немецких городов в базу данных Redmine
# Разместите в корне Redmine и запустите: ruby import_german_cities.rb

require File.expand_path(File.dirname(__FILE__) + '/config/environment')

def import_german_cities
  csv_file_path = File.expand_path('german_postcodes.csv', __dir__)
  
  # Проверяем существование CSV файла
  unless File.exist?(csv_file_path)
    puts "❌ CSV файл не найден: #{csv_file_path}"
    puts "📥 Пожалуйста, скачайте german_postcodes.csv и разместите в корневой директории Redmine"
    puts "💡 Можно скачать: wget http://download.geonames.org/export/zip/DE.zip && unzip DE.zip"
    return false
  end
  
  puts "🚀 Начинаем импорт из #{csv_file_path}..."
  start_time = Time.now
  
  imported_count = 0
  skipped_count = 0  # Исправлено: убрали лишние символы
  error_count = 0
  
  # Читаем CSV файл
  CSV.foreach(csv_file_path, headers: true, encoding: 'UTF-8') do |row|
    zip_code = row['zip_code']&.strip
    city_name = row['city']&.strip
    state = row['state']&.strip
    
    # Пропускаем пустые строки
    if zip_code.blank? || city_name.blank?
      skipped_count += 1
      next
    end
    
    begin
      # Проверяем, существует ли уже такой город с таким индексом
      existing_city = City.find_by(zip_code: zip_code, name: city_name)
      
      if existing_city
        skipped_count += 1
        next
      end
      
      # Создаем новую запись
      City.create!(
        zip_code: zip_code,
        name: city_name,
        state: state,
        country: 'Germany'
      )
      
      imported_count += 1
      
      # Выводим прогресс каждые 1000 записей
      if imported_count % 1000 == 0
        puts "📦 Импортировано #{imported_count} городов..."
      end
      
    rescue => e
      error_count += 1
      puts "❌ Ошибка при импорте #{zip_code} - #{city_name}: #{e.message}"
      next
    end
  end
  
  end_time = Time.now
  duration = end_time - start_time
  
  puts ""
  puts "✅ Импорт завершен!"
  puts "=========================================="
  puts "📊 Статистика:"
  puts "   Импортировано: #{imported_count} городов"
  puts "   Пропущено (дубликаты): #{skipped_count}"
  puts "   Ошибок: #{error_count}"
  puts "   Всего в базе: #{City.count} городов"
  puts "   Время выполнения: #{duration.round(2)} секунд"
  puts "   Скорость: #{(imported_count / duration).round(2)} городов/сек" if duration > 0
  puts "=========================================="
  
  true
end

def show_stats
  puts ""
  puts "📈 Статистика базы данных:"
  puts "   Всего городов: #{City.count}"
  puts "   Уникальных почтовых индексов: #{City.distinct.count(:zip_code)}"
  puts "   Уникальных названий городов: #{City.distinct.count(:name)}"
  
  # Примеры данных
  puts ""
  puts "🏙️  Примеры импортированных городов:"
  City.limit(5).each do |city|
    puts "   #{city.zip_code} - #{city.name} (#{city.state})"
  end
end

# Основная логика выполнения
if __FILE__ == $0
  begin
    puts "🔍 Проверяем подключение к базе данных..."
    
    # Проверяем, существует ли модель City
    
    # Проверяем подключение к БД
    City.count
    puts "✅ Подключение к базе данных успешно"
    
    # Запускаем импорт
    success = import_german_cities
    
    if success
      show_stats
      puts ""
      puts "🎉 Скрипт выполнен успешно!"
    else
      puts ""
      puts "❌ Скрипт завершился с ошибками"
      exit 1
    end
    
  rescue => e
    puts "💥 Критическая ошибка: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end