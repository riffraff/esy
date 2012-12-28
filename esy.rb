# coding: utf-8
Stack = [0]
Dict = {}
BINOPS =  %w[+ - * / & | ^]
START_DEF, END_DEF, START_IF, START_ELSE, END_IF, OUTC, ORD, CHR, POP, SWAP, DUP = 
'☊',       '☋',     '☾',      '☉',        '☽',    '☿',  '♃', '♅', '♁', '☍',  '♊'

$def = $skip = nil

def meval l
  return :skip if $skip && ![END_IF, START_ELSE].include?(l)
  return $def << l if $def &&  l != END_DEF
  case l
  when /[a-z']+/i
    Stack.push(l.chars.inject(0) {|acc, el| acc + el.ord } / l.chars.to_a.size / 2)
  when /\A\d+\Z/
    Stack.push l.to_i
  when *BINOPS
    a, b = Stack.pop, Stack.pop
    Stack.push eval("#{b} #{l} #{a}")
  when ORD
    Stack.push Stack.pop.to_s.ord
  when CHR
    Stack.push Stack.pop.chr.to_i
  when OUTC
    print Stack.pop.chr
  when POP
    Stack.pop || 0
  when SWAP
    Stack[-2], Stack[-1] = Stack[-1], Stack[-2]
  when DUP
    Stack.push Stack.last
  when START_IF
    $skip = Stack.pop == 0
  when START_ELSE
    $skip = !$skip
  when END_IF
    $skip = false
  when START_DEF
    $def = []
  when END_DEF
    name, *code = $def
    Dict[name] = lambda { code.each {|op| meval op } }
    $def = nil
  else 
    Dict[l].call
  end
end

ARGF.read.scan(/\S+/) { |word|  meval word }
