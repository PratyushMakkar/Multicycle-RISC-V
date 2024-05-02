## :pushpin: Documentation
The project is currently a work in progress however all modules in the makefile can be synthesized. To select a module, and compile its testbench with CocoTB, use 

```bash
cd tb/
make TOP=tb_multiplier_shift_controlpath MY_TEST=_ 
```

Only testbenches with a o_clk interface can be compiled with MY_TEST=_. register_file_wrapper must be compiled with register_file_test and so on. 

 
## :scroll: License
The library is licensed under <kbd>GNU GENERAL PUBLIC LICENSE</kbd>