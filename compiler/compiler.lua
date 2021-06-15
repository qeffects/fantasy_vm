--[[qfxLang
Meant to be compiled straight to qfxASM

Features:

Variable types:
Simple types:
Boolean --stored in memory as 0 or 1
Number --floats
String

func name (var1, var2, var3) {

};

function(var);

if (expression) {

} else {

}

for (num i=1; i=i+1; i<10;){

}

]]

local compiler = {}
compiler.__index = compiler


return compiler