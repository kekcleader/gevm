![GEVM screenshot](https://github.com/kekcleader/gevm/blob/master/screenshot.png)

# GEVM
Hypothetical Computer emulator that allows user to edit its memory and register and run programs on it.

# Installation
To compile GEVM, you need to have [Free Oberon](https://github.com/kekcleader/FreeOberon) installed. It is available for Windows and GNU/Linux.

1. Copy `GEVM.Mod` to `FreeOberon/Programs` directory.
2. Open Free Oberon, press F3 and type `GEVM.Mod`. The file should open.
3. Press F9 to compile and run.

You can also edit the source code if you like!

# Documentation
Visual GEVM (Hypothetical Computer) emulator.
GEVM consists of a 256 byte random access memory and a register called
"program counter". Move from cell to cell using arrow keys, input cell values
using the digits from 0 to 9 and letters from A to F. Green color represents
hexadecimal numbers, red represents decimal numbers.
Keys:
Tab - move cursor to the next cell and set it to zero.
P - move cursor to the program counter (or back).
R - run an instruction (the processor will process a single tick).
X - switch number system base in the current cell from 10 to 16 (or back).
Y - switch number system base of the cell addresses.
[ - set number system base in all cells to the base of cell addresses.
] - reset GEVM.
Escape - close the emulator.

GEVM Instructions:
E4 - add two numbers, the addresses of which are given in the first two
     parameters, and put the sum in the cell, which address lies in the
     third parameter.
A1 - unconditional transfer to the address, given in the [single] parameter.
B4 - decrease value of the cell, which address is given in the parameter.
A2 - if value which is pointed by the first parameter equals zero, go to
     the address given in the second parameter.
00 - end program.

# ГЭВМ
Эмулятор Гипотетической Электронно-Вычислительной Машины, в котором можно редактировать память и регистр и запускать программы.

# Установка
Чтобы скомпилировать ГЭВМ, Вам необходим [Free Oberon](https://github.com/kekcleader/FreeOberon). Он доступен для установки под операционными системами Windows и GNU/Linux.

1. Скопируйте `GEVM.Mod` в каталог `FreeOberon/Programs`.
2. Запустите Free Oberon, нажмите F3 и наберите `GEVM.Mod`. Должен открыться файл.
3. Для компиляции и запуска игры нажмите F9.

Редактируйте исходник на здоровье!

# Документация
Визуальный эмулятор ГЭВМ - Гипотетической электронно-вычислительной машины.
ГЭВМ состоит из оперативной памяти на 256 байтов и регистра "программный счётчик".
Перемещайтесь по ячейкам памяти с помощью клавиш со стрелками, вводите значения
ячеек памяти при помощи цифр от 0 до 9 и букв от A до F.
Зелёным цветом изображаются шестнадцатеричные числа, красным - десятичные.
Клавиши:
Табуляция - переставить курсор на следующую ячейку памяти и обнулить её.
P - переключить курсор на программный счётчик (или обратно).
R - выполнить инструкцию (процессор прорабатывает один такт).
X - сменить основание системы счисления в данной ячейке с 10 на 16 (или обратно).
Y - сменить основание системы счисления для вывода адресов ячеек.
[ - привести основание системы счисления во всех ячейках к основанию адресов.
] - перезагрузить ГЭВМ.
Escape - закрыть эмулятор.

Инструкции ГЭВМ:
E4 - сложить два числа, адреса которых даны в первых двух параметрах,
     и записать результат в ячейку по адресу, данному в третьем параметре.
A1 - безусловный переход на адрес, данный в [единственном] параметре.
B4 - уменьшить значение ячейки, адрес которой дан в параметре, на единицу.
A2 - если значение по адресу, данному в первом параметре, равно нулю, перейти на
     адрес, данный во втором параметре.
00 - останов.
