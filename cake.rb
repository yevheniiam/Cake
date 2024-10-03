# Пошук родзинок на торті
def find_raisins(cake)
  raisins = []
  cake.each_with_index do |row, i|
    row.chars.each_with_index do |cell, j|
      raisins << [i, j] if cell == 'o' # Додаємо позицію родзинки
    end
  end
  raisins
end

# Перевірка, чи є рівно одна родзинка в прямокутнику
def count_raisins_in_rectangle(cake, x1, y1, x2, y2)
  count = 0
  (x1..x2).each do |i|
    (y1..y2).each do |j|
      count += 1 if cake[i][j] == 'o' # Рахуємо родзинки
    end
  end
  count == 1 # Перевіряємо, чи рівно одна
end

# Генерація горизонтальних розрізів
def horizontal_cuts(cake, raisins)
  rectangles = []
  start_row = 0

  raisins.each_with_index do |(x, _), index|
    end_row = index == raisins.length - 1 ? cake.length - 1 : x # Останній шматок до кінця
    rectangles << cake[start_row..end_row]
    start_row = end_row + 1
  end
  rectangles
end

# Генерація вертикальних розрізів
def vertical_cuts(cake, raisins)
  columns = cake[0].length
  pieces = Array.new(columns) { [] }

  (0...cake.length).each do |row|
    (0...columns).each do |col|
      pieces[col] << cake[row][col] # Додаємо символи по стовпцях
    end
  end

  rectangles = []
  start_col = 0

  raisins.each_with_index do |(_, y), index|
    end_col = index == raisins.length - 1 ? columns - 1 : y # Останній шматок до кінця
    rectangles << pieces[start_col..end_col].map(&:join)
    start_col = end_col + 1
  end

  rectangles
end

# Генерація діагональних розрізів (коригуємо для прямокутних тортів)
def diagonal_cuts(cake, raisins)
  diagonal_rectangles = []
  n = cake.length
  m = cake[0].length

  # Основна діагональ (i == j)
  (0...n).each do |i|
    diagonal_piece = []
    (0...[n, m].min).each do |j|
      diagonal_piece << cake[i + j][j] if (i + j) < n && j < m
    end
    diagonal_rectangles << diagonal_piece.join unless diagonal_piece.empty?
  end

  diagonal_rectangles
end

# Комбіновані розрізи
def mixed_cuts(cake, raisins)
  horizontal_solution = horizontal_cuts(cake, raisins)
  vertical_solution = vertical_cuts(cake, raisins)
  diagonal_solution = diagonal_cuts(cake, raisins)

  [horizontal_solution, vertical_solution, diagonal_solution]
end

# Перевірка можливості поділу на шматки з однією родзинкою в кожному
def is_valid_cut(cake, raisins, solution)
  solution.each do |piece|
    # Якщо шматок представлений рядками (наприклад, для горизонтальних або вертикальних розрізів)
    if piece.is_a?(Array)
      raisin_count = piece.map { |row| row.count('o') }.sum
    else
      raisin_count = piece.count('o') # Для рядків
    end

    return false if raisin_count != 1 # Якщо не рівно одна родзинка, розріз невдалий
  end
  true
end

# Основна функція для розрізу торта
def cut_cake(cake)
  raisins = find_raisins(cake)

  return "Неможливо розрізати торт!" if raisins.empty? || raisins.size < 2

  # Генеруємо всі можливі розрізи
  horizontal_solution = horizontal_cuts(cake, raisins)
  vertical_solution = vertical_cuts(cake, raisins)
  diagonal_solution = diagonal_cuts(cake, raisins)
  mixed_solutions = mixed_cuts(cake, raisins)

  all_solutions = [horizontal_solution, vertical_solution, diagonal_solution] + mixed_solutions

  # Фільтруємо валідні розрізи
  valid_solutions = all_solutions.select { |solution| is_valid_cut(cake, raisins, solution) }

  return "Немає можливих розрізів!" if valid_solutions.empty?

  valid_solutions
end

# Вибір рішення з найбільшою шириною першого шматка
def find_best_solution(solutions)
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

rectangles = cut_cake(cake)
if rectangles.is_a?(String)
  puts rectangles # Якщо немає можливості розрізати торт
else
  best_solution = find_best_solution(rectangles)

  puts "Best solution:"
  best_solution.each_with_index do |rect, index|
    puts "Piece #{index + 1}:"
    rect.each { |line| puts line } # Виводимо кожен шматок
    puts "---"
  end
end
