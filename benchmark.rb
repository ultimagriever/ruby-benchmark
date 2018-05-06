require 'benchmark'

iterations = 100_000

def fact(n)
  if (n > 1)
    n * fact(n - 1)
  else
    n
  end
end

def fib(n)
  if (n > 2)
    n
  else
    fib(n-1) + fib(n-2)
  end
end

def item_check(tree)
  if tree[0] == nil
    tree[1]
  else
    tree[1] + item_check(tree[0]) - item_check(tree[2])
  end
end

def bottom_up_tree(item, depth)
 if depth > 0
  item_item = 2 * item
  depth -= 1
  [bottom_up_tree(item_item - 1, depth), item, bottom_up_tree(item_item, depth)]
 else
  [nil, item, nil]
 end
end

Benchmark.bmbm(27) do |bm|
  bm.report("joining array of strings") do
    iterations.times do
      ["The", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog"].join(" ")
    end
  end

  bm.report("string interpolation") do
    iterations.times do
      "The current time is #{Time.now}"
    end
  end

  bm.report("factorial") do
    iterations.times do
      [50, 100, 200].each do |n|
        fact(n)
      end
    end
  end

  bm.report("fibonacci") do
    iterations.times do
      [30, 35].each do |n|
        fib(n)
      end
    end
  end

  bm.report("binary trees (1 iteration)") do
    max_depth = 16
    min_depth = 4
    max_depth = min_depth + 2 if min_depth + 2 > max_depth

    stretch_depth = max_depth + 1
    stretch_tree = bottom_up_tree(0, stretch_depth)

    # puts "stretch tree of depth #{stretch_depth}\t check: #{item_check(stretch_tree)}"
    stretch_tree = nil

    long_lived_tree = bottom_up_tree(0, max_depth)
    min_depth.step(max_depth + 1, 2) do |depth|
      its = 2 ** (max_depth - depth + min_depth)

      check = 0

      for i in 1..its
        temp_tree = bottom_up_tree(i, depth)
        check += item_check(temp_tree)

        temp_tree = bottom_up_tree(-i, depth)
        check += item_check(temp_tree)
      end

      # puts "#{its * 2}\t trees of depth #{depth}\t check: #{check}"
    end

    # puts "long lived tree of depth #{max_depth}\t check: #{item_check(long_lived_tree)}"
  end
end
