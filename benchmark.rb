require 'benchmark'
require 'mathn'

iterations = 100_000

# avoid printing to console
class NullStream
  def <<(o)
    self
  end
end

def puts(s)
  null_stream = NullStream.new
  null_stream.<< s
end

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

def count_high
  100_000.times {}
end

class Toggle
    def initialize(start_state)
        @bool = start_state
    end

    def value
        @bool
    end

    def activate
        @bool = !@bool
        self
    end
end

class NthToggle < Toggle
    def initialize(start_state, max_counter)
        super start_state
        @count_max = max_counter
        @counter = 0
    end

    def activate
        @counter += 1
        if @counter >= @count_max
            @bool = !@bool
            @counter = 0
        end
        self
    end
end

def run_toggle(n)
  toggle = Toggle.new(1)
  5.times do
      toggle.activate.value ? 'true' : 'false'
  end

  n.times do
      toggle = Toggle.new(1)
  end

  ntoggle = NthToggle.new(1, 3)

  8.times do
      ntoggle.activate.value ? 'true' : 'false'
  end

  n.times do
      ntoggle = NthToggle.new(1, 3)
  end
end

class Array
  def qsort
    return [] if self.empty?

    pivot, *tail = self
    (tail.select {|el| el < pivot}).qsort + [pivot] +
      (tail.select {|el| el >= pivot}).qsort
  end

  def msort
    len = self.length
    return self if len <= 1
    middle = len / 2
    left = self.slice(0, middle).msort
    right = self.slice(middle, len - middle).msort
    merge(left, right)
  end

  protected

  def merge(left, right)
    result = []

    while (left.length > 0 && right.length > 0)
      if (left.first < right.first)
        result.push(left.shift)
      else
        result.push(right.shift)
      end
    end

    if left.length > 0
      result += left
    end

    if right.length > 0
      result += right
    end

    result
  end
end

def test_lists(size)
  # create a list of integers (Li1) from 1 to SIZE
  li1 = (1..size).to_a
  # copy the list to li2 (not by individual items)
  li2 = li1.dup
  # remove each individual item from left side of li2 and
  # append to right side of li3 (preserving order)
  li3 = Array.new
  while (not li2.empty?)
    li3.push(li2.shift)
  end
  # li2 must now be empty
  # remove each individual item from right side of li3 and
  # append to right side of li2 (reversing list)
  while (not li3.empty?)
    li2.push(li3.pop)
  end
  # li3 must now be empty
  # reverse li1 in place
  li1.reverse!
  # check that first item is now SIZE
  if li1[0] != size then
    p "not size"
    0
  else
    # compare li1 and li2 for equality
    if li1 != li2 then
      return(0)
    else
      # return the length of the list
      li1.length
    end
  end
end

Benchmark.bm(35) do |bm|
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

  bm.report("binary trees (10 iterations)") do
    10.times do
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

  bm.report("multithreaded count (100 iterations)") do
    100.times do
      [1, 2, 4, 8, 16].each do |n|
        threads = []
        n.times { threads << Thread.new { count_high }}
        threads.each {|t| t.join}
      end
    end
  end

  bm.report("regex dna") do
    20.times do
      fname = File.dirname(__FILE__) + "/fasta.input"
      seq = File.read(fname)
      ilen = seq.size

      seq.gsub!(/>.*\n|\n/, "")
      clen = seq.length

      [
        /agggtaaa|tttaccct/i,
        /[cgt]gggtaaa|tttaccc[acg]/i,
        /a[act]ggtaaa|tttacc[agt]t/i,
        /ag[act]gtaaa|tttac[agt]ct/i,
        /agg[act]taaa|ttta[agt]cct/i,
        /aggg[acg]aaa|ttt[cgt]ccct/i,
        /agggt[cgt]aa|tt[acg]accct/i,
        /agggta[cgt]a|t[acg]taccct/i,
        /agggtaa[cgt]|[acg]ttaccct/i
      ].each {|f| puts "#{f.source} #{seq.scan(f).size}"}

      {
        'B' => '(c|g|t)', 'D' => '(a|g|t)', 'H' => '(a|c|t)', 'K' => '(g|t)',
        'M' => '(a|c)', 'N' => '(a|c|g|t)', 'R' => '(a|g)', 'S' => '(c|t)',
        'V' => '(a|c|g)', 'W' => '(a|t)', 'Y' => '(c|t)'
      }.each {|f,r| seq.gsub!(f,r)}

      puts ""
      puts ilen
      puts clen
      puts seq.length
    end
  end

  bm.report("object toggling") do
    [500_000, 1_000_000, 1_500_000].each do |n|
      puts run_toggle(n)
    end
  end

  bm.report("prime number generation") do
    [3_000, 30_000, 300_000, 3_000_000].each do |n|
      p = Prime::EratosthenesGenerator.new
      n.times { p.succ }
    end
  end

  bm.report("quicksort") do
    array = iterations.times.map {|n| rand(1..iterations)}
    puts "Quicksort verified." if array.qsort == array.sort
  end

  bm.report("mergesort") do
    array = iterations.times.map {|n| rand(1..iterations)}
    puts "Mergesort verified." if array.msort == array.sort
  end

  bm.report("list manipulation") do
    1_000.times do
      test_lists(10_000)
    end
  end
end
