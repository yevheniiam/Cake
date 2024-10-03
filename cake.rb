# Пошук місцезнаходжень родзинок на торті
def find_raisins(cake)
  raisin_positions = []
  cake.each_with_index do |row, row_index|
    row.chars.each_with_index do |cell, col_index|
      raisin_positions << [row_index, col_index] if cell == 'o' # Додаємо позицію родзинки
    end
  end
  raisin_positions
end

# Перевірка, чи є рівно одна родзинка у прямокутнику
def has_single_raisin(cake, x1, y1, x2, y2)
  raisin_count = 0
  (x1..x2).each do |i|
    (y1..y2).each do |j|
      raisin_count += 1 if cake[i][j] == 'o' # Підраховуємо родзинки
    end
  end
  raisin_count == 1 # Перевіряємо, чи рівно одна
end

# Генерація горизонтальних розрізів
def generate_horizontal_slices(cake, raisins)
  horizontal_pieces = []
  start_row = 0

  raisins.each_with_index do |(x, _), index|
    end_row = index == raisins.length - 1 ? cake.length - 1 : x # Останній шматок до кінця
    horizontal_pieces << cake[start_row..end_row]
    start_row = end_row + 1
  end
  horizontal_pieces
end

# Генерація вертикальних розрізів
def generate_vertical_slices(cake, raisins)
  column_count = cake[0].length
  pieces_by_column = Array.new(column_count) { [] }

  (0...cake.length).each do |row|
    (0...column_count).each do |col|
      pieces_by_column[col] << cake[row][col] # Додаємо символи по стовпцях
    end
  end

  vertical_pieces = []
  start_col = 0

  raisins.each_with_index do |(_, y), index|
    end_col = index == raisins.length - 1 ? column_count - 1 : y # Останній шматок до кінця
    vertical_pieces << pieces_by_column[start_col..end_col].map(&:join)
    start_col = end_col + 1
  end

  vertical_pieces
end

# Генерація діагональних розрізів (корекція для прямокутних тортів)
def generate_diagonal_slices(cake, raisins)
  diagonal_pieces = []
  row_count = cake.length
  col_count = cake[0].length

  # Основна діагональ (i == j)
  (0...row_count).each do |i|
    diagonal_piece = []
    (0...[row_count, col_count].min).each do |j|
      diagonal_piece << cake[i + j][j] if (i + j) < row_count && j < col_count
    end
    diagonal_pieces << diagonal_piece.join unless diagonal_piece.empty?
  end

  diagonal_pieces
end

# Комбіновані розрізи
def generate_mixed_slices(cake, raisins)
  horizontal = generate_horizontal_slices(cake, raisins)
  vertical = generate_vertical_slices(cake, raisins)
  diagonal = generate_diagonal_slices(cake, raisins)

  [horizontal, vertical, diagonal]
end

# Перевірка на можливість розрізу з однією родзинкою на кожному шматку і однаковими розмірами
def valid_slice?(cake, raisins, slices)
  # Отримуємо довжину першого шматка для порівняння
  first_piece_size = slices[0].is_a?(Array) ? slices[0].length : slices[0].size

  slices.each do |slice|
    # Якщо шматок представлений рядами (наприклад, для горизонтальних або вертикальних розрізів)
    raisin_count = if slice.is_a?(Array)
                     slice.map { |row| row.count('o') }.sum
                   else
                     slice.count('o') # Для рядків
                   end

    # Перевірка на кількість родзинок
    return false if raisin_count != 1 # Якщо не рівно одна родзинка, розріз недійсний

    # Перевірка на однаковий розмір шматків
    current_piece_size = slice.is_a?(Array) ? slice.length : slice.size
    return false if current_piece_size != first_piece_size # Якщо розмір шматка не співпадає
  end
  true
end

# Основна функція для розрізу торта
def slice_cake(cake)
  raisins = find_raisins(cake)

  return "Неможливо розрізати торт!" if raisins.empty? || raisins.size < 2

  # Генерація всіх можливих розрізів
  horizontal_slices = generate_horizontal_slices(cake, raisins)
  vertical_slices = generate_vertical_slices(cake, raisins)
  diagonal_slices = generate_diagonal_slices(cake, raisins)
  mixed_slices = generate_mixed_slices(cake, raisins)

  all_slices = [horizontal_slices, vertical_slices, diagonal_slices] + mixed_slices

  # Фільтрація валідних розрізів
  valid_slices = all_slices.select { |slices| valid_slice?(cake, raisins, slices) }

  return "Немає можливих розрізів!" if valid_slices.empty?

  valid_slices
end

# Вибір рішення з найбільшою шириною першого шматка
def find_best_slice_solution(solutions)
  best_solution = nil
  max_width = 0

  solutions.each do |solution|
    first_piece = solution[0]
    width = first_piece.is_a?(Array) ? first_piece[0].length : first_piece.length # Перевіряємо тип
    if width > max_width
      max_width = width
      best_solution = solution
    end
  end

  best_solution
end

# Основна програма
cake = [
  "........",
  "..o.....",
  "...o....",
  "........"
]

slices = slice_cake(cake)
if slices.is_a?(String)
  puts slices # Якщо немає можливості розрізати торт
else
  best_solution = find_best_slice_solution(slices)

  puts "Найкраще рішення:"
  best_solution.each_with_index do |slice, index|
    puts "Шматок #{index + 1}:"
    slice.each { |line| puts line } # Виводимо кожен шматок
    puts "---"
  end
end
