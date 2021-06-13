## A VM for a fantasy CPU in lua/love

### Features:
- Stacks
- Registers
- External device communication (so you can interface with code outside the VM very easily)
- Extremely simple instruction definition

### Fibonacci

![Fibonacci](https://j.gifs.com/vQgpnM.gif)

### Communication with external 'device'

![Fibonacci](https://j.gifs.com/A6nYRp.gif)

The instruction set is defined in is.lua
While the cpu's 'functionality' is defined in cpu.lua

**"Types" for the instruction arguments are as follows:**

**Alias** 

A registers address, for example R10

**Number**

 A numeric type, for example 0.1

**String**

A weird choice for a VM, it exists nonetheless, strings are surrounded by "", like "Hello World"

**Any** 

A compound type, acts like a union between all the first 3, mostly meant for math operations so you can 

ADDR:10,10,R10

rather than storing the numbers in seperate registries

### Syntax

The instruction syntax is very simple

multi argument instructions    
```INSTRUCTION:ARGUMENT1,ARGUMENT2```    
e.g    
```SET:R1,"Hello world"```    


single argument instructions:    
```INSTRUCTION:ARGUMENT1```    
e.g    
```SLP:0.5```   


no argument instruction (none currently present)    
```INSTRUCTION```    

and a special case for the 'instruction' of the label    
```{LABEL_NAME}```    
and later can be referenced in jmp instructions like    
```JMP:LABEL_NAME```    


### Current instruction set is

**SET**:ALIAS,ANY X | Sets the value of ALIAS to ANY X

**ADDR**:ANY X,ANY Y,ALIAS | Adds the values of x and y, sets result in to ALIAS

**DIV**:ANY X,ANY Y,ALIAS | Divides x by y, stores the result in ALIAS

**MOD**:ANY X,ANY Y,ALIAS | Modulo of x/y, result stored in ALIAS

**ADD**:ALIAS, ANY X | Adds x to value already in alias

**MOV**:ALIAS X, ALIAS Y | Moves the value of registry x to registry y

**JMP**:LABEL | Unconditional Jump to {LABEL}

**JMPL**:ANY X, ANY Y, LABEL | jumps to {LABEL} if x > y

**JMPI**:ANY X, LABEL | Jumps to {LABEL} if x > 0

**CMPL**:ANY X, ANY Y, ANY Z, ALIAS A | Sets the value of a to z if x>y

**CMPE**:ANY X, ANY Y, ANY Z, ALIAS A | Sets the value of a to z if x==y

**CMPN**:ANY X, ANY Y, ANY Z, ALIAS A | Sets the value of a to z if x!=y

**SLP**:ANY X | Sets the CPU to sleep for value of x

**PUSH**:ANY A, ANY B, ANY C, ANY D, ANY E, ANY F | Pushes [a, b, c, d, e, f] on to the stack (values after A are optional)

**POP**:ALIAS A, ALIAS B, ALIAS C, ALIAS D, ALIAS E, ALIAS F | Retrieves the [a, b, c, d, e, f] from the stack (aliases after A are optional)

**CCAT**:ALIAS A | Concatenates the current stack and places the result in to A

**SUM**:ALIAS A | Sums the value of the stack and places the result in to A