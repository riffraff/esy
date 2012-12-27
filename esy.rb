# coding: utf-8
Stack = []
Dict = {}
BINOPS =  %w[+ - * / & | ^]

if ENV['MODE'] == 'readable'
  START_DEF, END_DEF = 'def', 'fed'
  START_IF, END_IF   = 'ifnot0', '0tonfi'
  OUTC = 'outc'
  POP  = 'pop'
  SWAP = 'swap'
  DUP  = 'dup'
else
  START_DEF, END_DEF = '☊', '☋'
  START_IF, END_IF   = '☾', '☽'
  OUTC = '☿'
  POP  = '♁'
  SWAP = '☍'
  DUP  = '♊'
end


$def = $skip = nil

$stacklevel = 0
def d *args
  return unless $DEBUG
  print " " * $stacklevel
  p args 
end

def pop! 
  Stack.pop || 0
end
def push! a
  Stack.push a
end
def top
  Stack.last
end

def meval l
  d l
  if $skip && l != END_IF
    return :skip
  end
  if $def &&  l != END_DEF
    $def << l
    return $def
  end
  case l
  when /\A\d+\Z/
    push! l.to_i
  when *BINOPS
    str = "#{pop!} #{l} #{pop!}"
    push! eval(str)
  when OUTC
    print pop!.chr
  when POP
    pop!
  when SWAP
    a = pop!
    b = pop!
    push! a
    push! b
  when DUP
    push! top
  when START_IF
    if pop! == 0
      $skip = true
    end
  when END_IF
    $skip = false
  when START_DEF
    $def = []
  when END_DEF
    name, *code = $def
    Dict[name] = lambda { code.each {|op| meval op } }
    $def = nil
  when /ruby (.*)/
    eval $1
  when "exit"
    exit
  else 
    if Dict[l]
      $stacklevel +=1
      Dict[l].call
      $stacklevel -=1
    else
      raise "unknown op #{l.inspect}"
    end
  end
end

def interp! 
  while true
    print "D:#{Dict.keys} :: S:#{Stack.inspect} #{$def ? "!" : ">"} " 
    res = meval gets.chomp
    puts "=> #{res}" 
  end
end

if __FILE__ == $0 and ARGV.empty?
  interp!
end


ARGF.read.scan(/\S+/) do |word|
  d(:word, word, $skip, $def)
  d({dict: Dict, stack: Stack})
  meval word
end
