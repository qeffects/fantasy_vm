local concat = {
    'SET:R1,0',
    '{CONCAT}',
    'ADD:R1,1',
    'PUSH:" World"',
    'PUSH:R1',
    'PUSH:" Hello "',
    'PUSH:10',
    'CCAT:R2',
    'JMPL:10,R1,CONCAT',
}