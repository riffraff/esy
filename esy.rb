# coding: utf-8
Stack = [0]
Dict = {}
BINOPS =  %w[+ - * / & | ^]
START_DEF, END_DEF, START_IF, END_IF, OUTC, POP, SWAP, DUP = '☊', '☋', '☾', '☽', '☿', '♁', '☍', '♊'

$def = $skip = nil

def meval l
  return :skip if $skip && l != END_IF
  return $def << l if $def &&  l != END_DEF
  case l
  when /\A\d+\Z/
    Stack.push l.to_i
  when *BINOPS
    Stack.push eval("#{Stack.pop} #{l} #{Stack.pop}")
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
