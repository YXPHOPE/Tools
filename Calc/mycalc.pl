use strict;
use warnings;
use utf8;
eval('use open":encoding(gbk)",":std";')if$^O eq 'MSWin32';
use Module::Load;
use Getopt::Long;     ##S带参数运行E##
use Math::Complex;    ##S数学函数E##
use Math::Trig;       ##S三角E##
use POSIX;            ##Sfloor、ceil 函数E##
use Carp;             ##S错误回溯E##
use Carp qw(cluck);
use Term::ANSIColor;                ##S带颜色输出E##
use Term::ANSIColor qw(:constants);
use Time::HiRes qw/time/;
use Term::ReadKey qw/GetTerminalSize/;
# 解决打包后无法显示中文的问题
use Encode;
use Encode::CN;
$Term::ANSIColor::AUTORESET = 1;    ##S自动为下一句去除颜色设定E##
# 解决cmd运行时出现的无法显示颜色的问题
if    ( $^O eq 'linux' )   { system('clear'); }
elsif ( $^O eq 'MSWin32' ) { system("cls"); }
our $TERM_SK = eval('load Term::Sk;1;') ? 1 : 0;
our $DEBUG = 1;
our $dataFileName = 'mycalc.data.txt';
if ($TERM_SK) { eval('use Term::Sk;'); }
else {
    print RED
"Unable to load Term::Sk module, please install it! Or you can't see the process of getprime and permutation.\n";
}
our @PRIME  = getprime(10000);                    ##S质数表E##
our %chains = ( 'gene0' => "我就知道你会看的~HAHA" );    ##S基因序列E##
our %MATRIX =
  ( 'E', [1], 'A', [ [ 1, 2 ], [ 2, 1 ] ], 'B', [ [ 0, 2 ], [ 1, 3 ] ], )
  ;    ##S矩阵对象,请不要在此修改或者在运行时输入E，因为一旦修改，将无法自动匹配E的大小E##
our @TMP;
our %MATH = (
    "e",  2.718281828459045,     'c',  299792458,
    'F',96485,'T',273.15,
    'N',  6.02214076 * 10**23,   'R',  8.314462618,
    'PI', 3.14159265358979,      'e0', 8.854187817 * 10**-12,
    'u0', 12.566370614 * 10**-7, 'G',  6.6743 * 10**-11,
    'h',  6.62607015 * 10**-34,  'b',  0.002897771955,
    'sb', 5.670374419 * 10**-8,  'ev', 1.602176634 * 10**-19,
    'nm', 10**-9,                'q',  1.602176634 * 10**-19,
    'pi', 3.14159265358979,
);     ##S数学对象E##
our %STYLE = (
    'b',   'bold',      'i', 'italic',
    'u',   'underline', 'c', 'cyan',
    'l',   'blue',      'h', 'black',
    'y',   'yellow',    'g', 'green',
    'r',   'red',       'm', 'magenta',
    'w',   'white',    ##S以上为文字属性、颜色，以下为背景颜色E##
    'bb',  'bright_black',    'br',  'bright_red',
    'bg',  'bright_green',    'by',  'bright_yellow',
    'bl',  'bright_blue',     'bm',  'bright_magenta',
    'bc',  'bright_cyan',     'bw',  'bright_white',
    'ob',  'on_black',        'or',  'on_red',
    'og',  'on_green',        'oy',  'on_yellow',
    'ol',  'on_blue',         'om',  'on_magenta',
    'oc',  'on_cyan',         'ow',  'on_white',
    'obb', 'on_bright_black', 'obr', 'on_bright_red',
    'obg', 'on_bright_green', 'oby', 'on_bright_yellow',
    'obl', 'on_bright_blue',  'obm', 'on_bright_magenta',
    'obc', 'on_bright_cyan',  'obw', 'on_bright_white',
);    ##S颜色属性的简写，用于&prtfmt E##
our %GRAPH = ( 'area' => [ -10, 10, -10, 10, 0.2, 0.5 ], );    ##S函数图像E##
our %ELEM  = (
    ##S symbol chinesename engname (standard atomic weight) 来自IUPAC网站E##
    1,
    { "sym", "H", "ch", "氢", "en", "hydrogen", "saw", 1.00794, "ec", "1s1" },
    2,
    { "sym", "He", "ch", "氦", "en", "helium", "saw", 4.002602, "ec", "1s2" },
    3,
    { "sym", "Li", "ch", "锂", "en", "lithium", "saw", 6.941, "ec", "1s2.2s1" },
    4,
    {
        "sym", "Be",     "ch", "铍", "en", "beryllium",
        "saw", 9.012182, "ec", "[He]2s2"
    },
    5,
    {
        "sym", "B", "ch", "硼", "en", "boron", "saw", 10.811, "ec",
        "[He]2s2.2p1"
    },
    6,
    {
        "sym", "C",     "ch", "碳", "en", "carbon",
        "saw", 12.0107, "ec", "[He]2s2.2p2"
    },
    7,
    {
        "sym", "N",     "ch", "氮", "en", "nitrogen",
        "saw", 14.0067, "ec", "[He]2s2.2p3"
    },
    8,
    {
        "sym", "O",     "ch", "氧", "en", "oxygen",
        "saw", 15.9994, "ec", "[He]2s2.2p4"
    },
    9,
    {
        "sym", "F",        "ch", "氟", "en", "fluorine",
        "saw", 18.9984032, "ec", "[He]2s2.2p5"
    },
    10,
    {
        "sym", "Ne",    "ch", "氖", "en", "neon",
        "saw", 20.1797, "ec", "[He]2s2.2p6"
    },
    11,
    {
        "sym", "Na",        "ch", "钠", "en", "sodium",
        "saw", 22.98976928, "ec", "[Ne]3s1"
    },
    12,
    {
        "sym", "Mg",    "ch", "镁", "en", "magnesium",
        "saw", 24.3050, "ec", "[Ne]3s2"
    },
    13,
    {
        "sym", "Al",       "ch", "铝", "en", "aluminium",
        "saw", 26.9815386, "ec", "[Ne]3s2.3p1"
    },
    14,
    {
        "sym", "Si",    "ch", "硅", "en", "silicon",
        "saw", 28.0855, "ec", "[Ne]3s2.3p2"
    },
    15,
    {
        "sym", "P",       "ch", "磷", "en", "phosphorus",
        "saw", 30.973762, "ec", "[Ne]3s2.3p3"
    },
    16,
    {
        "sym", "S",    "ch", "硫", "en", "sulfur",
        "saw", 32.065, "ec", "[Ne]3s2.3p4"
    },
    17,
    {
        "sym", "Cl",   "ch", "氯", "en", "chlorine",
        "saw", 35.453, "ec", "[Ne]3s2.3p5"
    },
    18,
    {
        "sym", "Ar",   "ch", "氩", "en", "argon",
        "saw", 39.948, "ec", "[Ne]3s2.3p6"
    },
    19,
    {
        "sym", "K",     "ch", "钾", "en", "potassium",
        "saw", 39.0983, "ec", "[Ar]4s1"
    },
    20,
    { "sym", "Ca", "ch", "钙", "en", "calcium", "saw", 40.078, "ec", "[Ar]4s2" },
    21,
    {
        "sym", "Sc",      "ch", "钪", "en", "scandium",
        "saw", 44.955912, "ec", "[Ar]3d1.4s2"
    },
    22,
    {
        "sym", "Ti",   "ch", "钛", "en", "titanium",
        "saw", 47.867, "ec", "[Ar]3d2.4s2"
    },
    23,
    {
        "sym", "V",     "ch", "钒", "en", "vanadium",
        "saw", 50.9415, "ec", "[Ar]3d3.4s2"
    },
    24,
    {
        "sym", "Cr",    "ch", "铬", "en", "chromium",
        "saw", 51.9961, "ec", "[Ar]3d5.4s1"
    },
    25,
    {
        "sym", "Mn",      "ch", "锰", "en", "manganese",
        "saw", 54.938045, "ec", "[Ar]3d5.4s2"
    },
    26,
    {
        "sym", "Fe", "ch", "铁", "en", "iron", "saw", 55.845, "ec",
        "[Ar]3d6.4s2"
    },
    27,
    {
        "sym", "Co",      "ch", "钴", "en", "cobalt",
        "saw", 58.933195, "ec", "[Ar]3d7.4s2"
    },
    28,
    {
        "sym", "Ni",    "ch", "镍", "en", "nickel",
        "saw", 58.6934, "ec", "[Ar]3d8.4s2"
    },
    29,
    {
        "sym", "Cu",   "ch", "铜", "en", "copper",
        "saw", 63.546, "ec", "[Ar]3d10.4s1"
    },
    30,
    {
        "sym", "Zn", "ch", "锌", "en", "zinc", "saw", 65.38, "ec",
        "[Ar]3d10.4s2"
    },
    31,
    {
        "sym", "Ga",      "ch",  "镓",
        "en",  "gallium", "saw", 69.723,
        "ec",  "[Ar]3d10.4s2.4p1"
    },
    32,
    {
        "sym", "Ge",        "ch",  "锗",
        "en",  "germanium", "saw", 72.64,
        "ec",  "[Ar]3d10.4s2.4p2"
    },
    33,
    {
        "sym", "As",      "ch",  "砷",
        "en",  "arsenic", "saw", 74.92160,
        "ec",  "[Ar]3d10.4s2.4p3"
    },
    34,
    {
        "sym", "Se",       "ch",  "硒",
        "en",  "selenium", "saw", 78.96,
        "ec",  "[Ar]3d10.4s2.4p4"
    },
    35,
    {
        "sym", "Br",      "ch",  "溴",
        "en",  "bromine", "saw", 79.904,
        "ec",  "[Ar]3d10.4s2.4p5"
    },
    36,
    {
        "sym", "Kr",      "ch",  "氪",
        "en",  "krypton", "saw", 83.798,
        "ec",  "[Ar]3d10.4s2.4p6"
    },
    37,
    {
        "sym", "Rb",    "ch", "铷", "en", "rubidium",
        "saw", 85.4678, "ec", "[Kr]5s1"
    },
    38,
    {
        "sym", "Sr", "ch", "锶", "en", "strontium", "saw", 87.62, "ec",
        "[Kr]5s2"
    },
    39,
    {
        "sym", "Y",      "ch", "钇", "en", "yttrium",
        "saw", 88.90585, "ec", "[Kr]4d1.5s2"
    },
    40,
    {
        "sym", "Zr",   "ch", "锆", "en", "zirconium",
        "saw", 91.224, "ec", "[Kr]4d2.5s2"
    },
    41,
    {
        "sym", "Nb",     "ch", "铌", "en", "niobium",
        "saw", 92.90638, "ec", "[Kr]4d4.5s1"
    },
    42,
    {
        "sym", "Mo",  "ch", "钼", "en", "molybdenum",
        "saw", 95.94, "ec", "[Kr]4d5.5s1"
    },
    43,
    {
        "sym", "Tc",    "ch", "锝", "en", "technetium",
        "saw", 97.9072, "ec", "[Kr]4d5.5s2"
    },
    44,
    {
        "sym", "Ru",   "ch", "钌", "en", "ruthenium",
        "saw", 101.07, "ec", "[Kr]4d7.5s1"
    },
    45,
    {
        "sym", "Rh",      "ch", "铑", "en", "rhodium",
        "saw", 102.90550, "ec", "[Kr]4d8.5s1"
    },
    46,
    {
        "sym", "Pd",   "ch", "钯", "en", "palladium",
        "saw", 106.42, "ec", "[Kr]4d10"
    },
    47,
    {
        "sym", "Ag",     "ch", "银", "en", "silver",
        "saw", 107.8682, "ec", "[Kr]4d10.5s1"
    },
    48,
    {
        "sym", "Cd",    "ch", "镉", "en", "cadmium",
        "saw", 112.411, "ec", "[Kr]4d10.5s2"
    },
    49,
    {
        "sym", "In",     "ch",  "铟",
        "en",  "indium", "saw", 114.818,
        "ec",  "[Kr]4d10.5s2.5p1"
    },
    50,
    {
        "sym", "Sn", "ch", "锡", "en", "tin", "saw", 118.710, "ec",
        "[Kr]4d10.5s2.5p2"
    },
    51,
    {
        "sym", "Sb",       "ch",  "锑",
        "en",  "antimony", "saw", 121.760,
        "ec",  "[Kr]4d10.5s2.5p3"
    },
    52,
    {
        "sym", "Te",        "ch",  "碲",
        "en",  "tellurium", "saw", 127.60,
        "ec",  "[Kr]4d10.5s2.5p4"
    },
    53,
    {
        "sym", "I",      "ch",  "碘",
        "en",  "iodine", "saw", 126.90447,
        "ec",  "[Kr]4d10.5s2.5p5"
    },
    54,
    {
        "sym", "Xe",    "ch",  "氙",
        "en",  "xenon", "saw", 131.293,
        "ec",  "[Kr]4d10.5s2.5p6"
    },
    55,
    {
        "sym", "Cs",        "ch", "铯", "en", "caesium",
        "saw", 132.9054519, "ec", "[Xe]6s1"
    },
    56,
    { "sym", "Ba", "ch", "钡", "en", "barium", "saw", 137.327, "ec", "[Xe]6s2" },
    57,
    {
        "sym", "La",      "ch", "镧", "en", "lanthanum",
        "saw", 138.90547, "ec", "[Xe]5d1.6s2"
    },
    58,
    {
        "sym", "Ce",     "ch",  "铈",
        "en",  "cerium", "saw", 140.116,
        "ec",  "[Xe]4f1.5d1.6s2"
    },
    59,
    {
        "sym", "Pr",      "ch", "镨", "en", "praseodymium",
        "saw", 140.90765, "ec", "[Xe]4f3.6s2"
    },
    60,
    {
        "sym", "Nd",    "ch", "钕", "en", "neodymium",
        "saw", 144.242, "ec", "[Xe]4f4.6s2"
    },
    61,
    {
        "sym", "Pm", "ch", "钷", "en", "promethium",
        "saw", 145,  "ec", "[Xe]4f5.6s2"
    },
    62,
    {
        "sym", "Sm",   "ch", "钐", "en", "samarium",
        "saw", 150.36, "ec", "[Xe]4f6.6s2"
    },
    63,
    {
        "sym", "Eu",    "ch", "铕", "en", "europium",
        "saw", 151.964, "ec", "[Xe]4f7.6s2"
    },
    64,
    {
        "sym", "Gd",         "ch",  "钆",
        "en",  "gadolinium", "saw", 157.25,
        "ec",  "[Xe]4f7.5d1.6s2"
    },
    65,
    {
        "sym", "Tb",      "ch", "铽", "en", "terbium",
        "saw", 158.92535, "ec", "[Xe]4f9.6s2"
    },
    66,
    {
        "sym", "Dy",    "ch", "镝", "en", "dysprosium",
        "saw", 162.500, "ec", "[Xe]4f10.5s2"
    },
    67,
    {
        "sym", "Ho",      "ch", "钬", "en", "holmium",
        "saw", 164.93032, "ec", "[Xe]4f11.6s2"
    },
    68,
    {
        "sym", "Er",    "ch", "铒", "en", "erbium",
        "saw", 167.259, "ec", "[Xe]4f12.6s2"
    },
    69,
    {
        "sym", "Tm",      "ch", "铥", "en", "thulium",
        "saw", 168.93421, "ec", "[Xe]4f13.6s2"
    },
    70,
    {
        "sym", "Yb",   "ch", "镱", "en", "ytterbium",
        "saw", 173.04, "ec", "[Xe]4f14.6s2"
    },
    71,
    {
        "sym", "Lu",       "ch",  "镥",
        "en",  "lutetium", "saw", 174.967,
        "ec",  "[Xe]4f14.5d1.6s2"
    },
    72,
    {
        "sym", "Hf",      "ch",  "铪",
        "en",  "hafnium", "saw", 178.49,
        "ec",  "[Xe]4f14.5d2.6s2"
    },
    73,
    {
        "sym", "Ta",       "ch",  "钽",
        "en",  "tantalum", "saw", 180.94788,
        "ec",  "[Xe]4f14.5d3.6s2"
    },
    74,
    {
        "sym", "W",        "ch",  "钨",
        "en",  "tungsten", "saw", 183.84,
        "ec",  "[Xe]4f14.5d4.6s2"
    },
    75,
    {
        "sym", "Re",      "ch",  "铼",
        "en",  "rhenium", "saw", 186.207,
        "ec",  "[Xe]4f14.5d5.6s2"
    },
    76,
    {
        "sym", "Os",     "ch",  "锇",
        "en",  "osmium", "saw", 190.23,
        "ec",  "[Xe]4f14.5d6.6s2"
    },
    77,
    {
        "sym", "Ir",      "ch",  "铱",
        "en",  "iridium", "saw", 192.217,
        "ec",  "[Xe]4f14.5d7.6s2"
    },
    78,
    {
        "sym", "Pt",       "ch",  "铂",
        "en",  "platinum", "saw", 195.084,
        "ec",  "[Xe]4f14.5d9.6s1"
    },
    79,
    {
        "sym", "Au",   "ch",  "金",
        "en",  "gold", "saw", 196.966569,
        "ec",  "[Xe]4f14.5d10.6s1"
    },
    80,
    {
        "sym", "Hg",      "ch",  "汞",
        "en",  "mercury", "saw", 200.59,
        "ec",  "[Xe]4f14.5d10.6s2"
    },
    81,
    {
        "sym", "Tl", "ch", "铊", "en", "thallium", "saw", 204.3833, "ec",
        "[Xe]4f14.5d10.6s2.6p1"
    },
    82,
    {
        "sym", "Pb", "ch", "铅", "en", "lead", "saw", 207.2, "ec",
        "[Xe]4f14.5d10.6s2.6p2"
    },
    83,
    {
        "sym", "Bi", "ch", "铋", "en", "bismuth", "saw", 208.98040, "ec",
        "[Xe]4f14.5d10.6s2.6p3"
    },
    84,
    {
        "sym", "Po", "ch", "钋", "en", "polonium", "saw", 208.9824, "ec",
        "[Xe]4f14.5d10.6s2.6p4"
    },
    85,
    {
        "sym", "At", "ch", "砹", "en", "astatine", "saw", 209.9871, "ec",
        "[Xe]4f14.5d10.6s2.6p5"
    },
    86,
    {
        "sym", "Rn", "ch", "氡", "en", "radon", "saw", 222.0176, "ec",
        "[Xe]4f14.5d10.6s2.6p6"
    },
    87,
    { "sym", "Fr", "ch", "钫", "en", "francium", "saw", 223, "ec", "[Rn]7s1" },
    88,
    { "sym", "Ra", "ch", "镭", "en", "radium", "saw", 226, "ec", "[Rn]7s2" },
    89,
    {
        "sym", "Ac", "ch", "锕", "en", "actinium",
        "saw", 227,  "ec", "[Rn]6d1.7s2"
    },
    90,
    {
        "sym", "Th",      "ch", "钍", "en", "thorium",
        "saw", 232.03806, "ec", "[Rn]6d2.7s2"
    },
    91,
    {
        "sym", "Pa",           "ch",  "镤",
        "en",  "protactinium", "saw", 231.03588,
        "ec",  "[Rn]5f2.6d1.7s2"
    },
    92,
    {
        "sym", "U",       "ch",  "铀",
        "en",  "uranium", "saw", 238.02891,
        "ec",  "[Rn]5f3.6d1.7s2"
    },
    93,
    {
        "sym", "Np",        "ch",  "镎",
        "en",  "neptunium", "saw", 238.8486,
        "ec",  "[Rn]5f4.6d1.7s2"
    },
    94,
    {
        "sym", "Pu",     "ch", "钚", "en", "plutonium",
        "saw", 242.8798, "ec", "[Rn]5f6.7s2"
    },
    95,
    {
        "sym", "Am",     "ch", "镅", "en", "americium",
        "saw", 244.8594, "ec", "[Rn]5f7.7s2"
    },
    96,
    {
        "sym", "Cm",     "ch",  "锔",
        "en",  "curium", "saw", 246.911,
        "ec",  "[Rn]5f7.6d1.7s2"
    },
    97,
    {
        "sym", "Bk",     "ch", "锫", "en", "berkelium",
        "saw", 248.9266, "ec", "[Rn]5f9.7s2"
    },
    98,
    {
        "sym", "Cf",     "ch", "锎", "en", "californium",
        "saw", 252.9578, "ec", "[Rn]5f10.7s2"
    },
    99,
    {
        "sym", "Es",     "ch", "锿", "en", "einsteinium",
        "saw", 253.9656, "ec", "[Rn]5f11.7s2"
    },
    100,
    {
        "sym", "Fm",     "ch", "镄", "en", "fermium",
        "saw", 259.0046, "ec", "[Rn]5f12.7s2"
    },
    101,
    {
        "sym", "Md",     "ch", "钔", "en", "mendelevium",
        "saw", 260.0124, "ec", "[Rn]5f13.7s2"
    },
    102,
    {
        "sym", "No",     "ch", "锘", "en", "nobelium",
        "saw", 261.0202, "ec", "[Rn]5f14.7s2"
    },
    103,
    {
        "sym", "Lr",         "ch",  "铹",
        "en",  "lawrencium", "saw", 264.0436,
        "ec",  "[Rn]5f14.6d1.7s2"
    },
    104,
    {
        "sym", "Rf",            "ch",  "钅卢",
        "en",  "rutherfordium", "saw", 269.0826,
        "ec",  "[Rn]5f14.6d2.7s2"
    },
    105,
    {
        "sym", "Db",      "ch",  "钅杜",
        "en",  "dubnium", "saw", 270.0904,
        "ec",  "[Rn]5f14.6d3.7s2"
    },
    106,
    {
        "sym", "Sg",         "ch",  "钅喜",
        "en",  "seaborgium", "saw", 273.1138,
        "ec",  "[Rn]5f14.6d4.7s2"
    },
    107,
    {
        "sym", "Bh",      "ch",  "钅波",
        "en",  "bohrium", "saw", 274.1216,
        "ec",  "[Rn]5f14.6d5.7s2"
    },
    108,
    {
        "sym", "Hs",      "ch",  "钅黑",
        "en",  "hassium", "saw", 272.106,
        "ec",  "[Rn]5f14.6d6.7s2"
    },
    109,
    {
        "sym", "Mt",         "ch",  "钅麦",
        "en",  "meitnerium", "saw", 278.1528,
        "ec",  "[Rn]5f14.6d7.7s2"
    },
    110,
    {
        "sym", "Ds", "ch", "鐽", "en", "darmstadtium", "saw", 283.1918, "ec",
        "[Rn]5f14.6d8.7s2(predicted)"
    },
    111,
    { "sym", "Rg", "ch", "錀", "en", "roentgenium ", "saw", 282.184, "ec", "" },
    112,
    { "sym", "Cn", "ch", "鎶", "en", "copernicium", "saw", 287.223, "ec", "" },
    113,
    { "sym", "Nh", "ch", "钅尔", "en", "nihonium", "saw", 286.2152, "ec", "" },
    114,
    { "sym", "Fl", "ch", "鈇", "en", "flerovium", "saw", 291.1964, "ec", "" },
    115,
    { "sym", "Mc", "ch", "镆", "en", "moscovium", "saw", 290.1888, "ec", "" },
    116,
    { "sym", "Lv", "ch", "鉝", "en", "livermorium", "saw", 295.2268, "ec", "" },
    117,
    { "sym", "Ts", "ch", "石田", "en", "tennessine", "saw", 293.2116, "ec", "" },
    118,
    {
        "sym", "Os",     "ch", "Oganesson", "en", "oganesson",
        "saw", 299.2572, "ec", ""
    },
);
our ($Wchar,$Hchar) = GetTerminalSize();
our $maxTab = int $Hchar/8;
# 矩阵求解，求特征值，特征向量，求
our ( $ANIMATE, $PROCESS ) = ( 0, 0 );
our ( @symbol, @chname, @enname, @weight, @econf );
foreach ( 0 .. 117 ) {
    my %x = %{ $ELEM{$_+1} };
    $symbol[ $_ ] = $x{'sym'};
    $chname[ $_ ] = $x{'ch'};
    $enname[ $_ ] = $x{'en'};
    $weight[ $_ ] = $x{'saw'};
}

# print "en=@enname\n";
sub chemistry {
    print GREEN "欢迎使用化学计算器！功能及详细讲解请在运行时添加参数 -h 6 或现在键入help\n";
    my $input = substr( <>, 0, -1 );
    logres( $input, 'in' );
    while (1) {
        $input = quit()       if $input eq "";
        last                  if $input eq ">exit";
        $input = dsphelp("6") if $input eq "help";
        if ( $input =~ /=/ ) {
            print "you=\n";
        }
        elsif ( $input =~ /[A-Z][1-9]/ ) {

            # 先切割再计算每块东西
        }
        else {
            my $judge  = indexof( $input, \@symbol );
            my @arr    = ( 1 .. 118 );
            my $search = uc( substr( $input, 0, 1 ) ) . substr( $input, 1 );
            if ( indexof( $input, \@arr ) != -1 ) { prtele( $input - 1 ); }
            elsif (
                (
                    $judge = $judge != -1 ? $judge : indexof( $search, \@symbol )
                ) != -1
              )
            {
                prtele($judge);
            }
            elsif ( ( $judge = indexof( $input, \@chname ) ) != -1 ) {
                print CYAN "$input 是 $symbol[$judge] 的中文名。\n";
                prtele($judge);
            }
            elsif (
                ( $judge = indexof( lc($input), \@enname, 'false' ) ) != -1 )
            {
                prtfmt( "$input 应该是 $symbol[$judge] 的英文名 $enname[$judge].\n",
                    'c', lc($input) . " y&b" );
                prtele($judge);
            }
        }
        $input = substr( <>, 0, -1 );
    }
}

sub prtele {
    $_ = shift;
    my $str =
"{y&b}|+|$symbol[$_]|+| 中文名：$chname[$_] 英文名：$enname[$_]\n标准原子量：$weight[$_]\n电子排布式：$ELEM{$_+1}{'ec'}\n";
    prtfmt( $str, 'c' );
}
our %HELP = (
    'break' => ( "=" x 90 ) . "\n",
    "help"  =>
"{b&u&y}|+|usage:\n|+|{b&c}-n [1-6]|+|      : 预先选择所要使用的功能\n|+|{b&c}-f|+|            : 不显示封面图片\n|+|{b&c}-h|-help|-?|+|   : 帮助文档\n多数情况下, 输入0或者Enter均为返回上一级\n更多帮助请输入以下选项: \n|+|{b&c}-h 1|+|          : 查看关于|+|{u}<数学计算器>|+|的帮助\n|+|{b&c}-h 2|+|          : 查看关于|+|{u}<矩阵运算>|+|的帮助\n|+|{b&c}-h 3|+|          : 查看关于|+|{u}<基因>|+|的帮助\n|+|{b&c}-h 4|+|          : 查看关于|+|{u}<函数图像>|+|的帮助\n|+|{b&c}-h 5|+|          : 查看关于|+|{u}<自由模式>|+|的帮助\n|+|{b&c}-h style|+|      : 查看关于|+|{u}<样式>|+|的帮助\n",
    '1' =>
"{b&u&y}|+|计算器使用说明:  (0、Enter x 2返回上一级) \n|+|本计算器含有丰富而强大的功能, 在这里, 你可以自由输入各种算式, 并存储为变量, 之后调用他们继续运算。\n时刻注意: |+|{b&r}【乘号不能省略！】用*表示乘法。但是前为数字后为字母时可以省略*号|+|表示运算顺序请勿使用中括号大括号, 一律使用圆括号。\n1.变量的保存与调用|+|\n    只能使用|+|{b}[a-zA-Z]([a-zA-Z0-9]+)?|+|组成的名称作为变量名\n    注: 常量e保存在本地, 建议不要修改, pi则是作为常量存在; 此外还预先添加了许多物理常数\n    保存: a=1\n    调用: \\a\\  对于|+|{b&y}单个小写字母|+|, 可以不写反斜杠, 直接使用a-z\n    输出: a\n2.固定表达式\n    输出结果均为数组, 不能保存为变量(D、P可以), 且一次只能使用单个, 参数可灵活表达\n        大写字母(参数)\n    大写字母有R D F P PMT\n    |+|{b&y}R|+|(整数分子,整数分母) 分数约分【受质数表限制, 最大值请在prime变量中修改getprime的值, D、F同, 可增大质数表来提高上限】\n    |+|{b&y}D|+|(整数)             分解质因数\n    |+|{b&y}F|+|(数)               数化为分数(由于未使用十进制, 只能处理比较简单的循环小数, 非循环或者循环体较长的效果不佳)\n    |+|{b&y}P|+|(正整数)           2-正整数的所有质数表\n    |+|{b&y}PMT|+|(正整数)         1-正整数的全排列\n    定义数组 X=[1,2,3],调用时使用 【|+|{b&r}[\\X\\]|+|】, 其他方式保存的数组也是这样调用\n3.全局表达式\n    可在全局使用的表达式, 如算式、全局函数\n    算式: 不能除以0, 请多加括号避免出现运算顺序问题\n        |+|{b&r}+-*/%^(**)!|+|逻辑操作符或|+|{b&r}|||+|与|+|{b&r}&&|+|非|+|{b&r}！=|+|皆可运算(！阶乘只能使用正整数, 不能调用)\n        |+|{b&r}(n1..n2)|+|代表从n1-n2, 以1为公差的列表, 等价于arr(n1,n2)\n        |+|{b&r}arr(s,e,d)|+|代表从s-e, 以d为公差的列表。列表可作为有多个参数的函数的参数,|+|\n        列表一般不能参与运算, 也不能保存, 强行运算或保存只保留列表中的最后一个值\n    函数列表: \n        max(列表或若干个参数)求最大值\n        min(列表或若干个参数)求最小值\n        sum(列表或若干个参数)求累和\n        avr(列表或若干个参数)求平均值\n        mul(列表或若干个参数)求累积\n        sin cos tan cot cos sec arcsin arccos arctan arcsec arccot arccsc (使用弧度制, 角度请输入deg(90))\n        注: sinpi本应为0, 但是结果不是, 为bug, 同时还存在其他未知三角函数问题\n        lgy lny logx{y} exp(n) |+|【|+|{b&y}logx{y}必须以花括号{}包围真数|+|】\n        |+|{b&r}[^x]|+| 表示*10^x,前面只要数, 不要符号*\n    |+|{y&b}绘制函数: |+|\n        x1,x2,y1,y2,dx,dy\t重定义坐标格\n        f:y=f(x)    前缀f:不能少, f(x)中可以引用变量值\n        |+|{y&b}f:1|+| => 显示图像\n4.一些实例\n    G => |+|{c}G = 6.67430000000001e-11|+|\n    a=sin(deg(30))*cos(deg(60))【注意乘号*】 => |+|{c}a=sin(deg(30))*cos(deg(60)) = 0.25|+|\n    a => |+|{c}a = 0.25|+| 【查询a的值】\n    b=sin0.5*pi => |+|{c}b=sin0.5*pi = 1|+|\n    c=\\a\\+\\b\\ => |+|{c}c=\\a\\+\\b\\ = 1.25|+| 【\\a\\和\\b\\表示引用】\n    d=(lg1000)-log3(9)或lg(1000)-log3(9)不能是lg1000-log3(9) => |+|{c}lg(1000)-log3(9) = 1|+|\n    e => |+|{c}e = 2.71828182845905|+|\n    f=mul(arr(1,9,2))【1*3*5*7不含9】 => |+|{c}f=mul(arr(1,9,2)) = 105|+|\n    D(120) =>\n    |+|{c}质数:   2       3       5\n    次方:   3       1       1|+|\n    A=P(100) => \n    |+|{c}2       3       5       7       11      13      17      19      23      29\n    31      37      41      43      47      53      59      61      67      71\n    73      79      83      89      97|+|\n    A => |+|{c}A = [ 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 ]|+|\n    sum([\\A\\]) => |+|{c}sum([\\A\\]) = 1060|+|\n",
    '2' =>
"{b&u&y}|+|矩阵使用说明: |+|\n可以输入以下三种情况:  (0直接返回上一级, Enter需返回确认) \n|+|{y&b}1.名称(ABCDF-Z)=或Enter行数(1,2,3-INF)Enter第一行Enter第二行-……-第n行 |+|=>下一次循环\n    名称: |+|{r&b}A-Z的一个大写字母|+|\n    行数: 正整数\n    第n行: |+|{r&b}以空格或者逗号隔开元素|+|\n2.|+|{y&b}[A-Z]=num-第一行-…第num行|+|\n3.算式: \n    1)临时计算: \n        |+|{y&b}tA|+|\tA的转置transition\n        |+|{y&b}nB|+|\tA的数乘\n        |+|{y&b}AB|+|\tA与B的乘积,也可写作AxB,A*B\n        |+|{y&b}A+/-B|+|\tA与B的和差\n        |+|{y&b}dA|+|\tA的行列式det\n        |+|{y&b}iA|+|\tA的逆矩阵inverse\n        |+|{y&b}rA|+|\tA的秩rank\n        |+|{y&b}sA|+|\tA的行简化结果simplify(|+|{y}+p|+|开启过程演示,|+|{y}-p|+|关闭过程显示)\n    2)保存结果: X=算式(不写X=则默认保存在|+|{y&b}O|+|中,故不建议使用O作为名称)\n4.一些例子: \n    A=3\n    1,2,3\n    1,,4\n    3,2,\n    A =>\n    [[1     2       3]\n     [1     0       4]\n     [3     2       0]]\n    覆盖请再次输入 A ,输入其他则继续: dA =>\n    22\n    B=tA\n    C=A+B =>\n    [[2     3       6]\n     [3     0       6]\n     [6     6       0]]\n",
    '3' =>
"{y&b&u}|+|欢迎使用基因！！！|+|\n基因具有以下五项功能: 1.中心法则 2.碱基频率 3.基因的相似度 4.基因的比较 5.基因的存入\n在使用过程中输入0即返回上一步, 直接键入Enter会发出询问,某些情况下Enter具有特殊用法\n在输入过程中系统会提示, |+|{r&b}碱基不能小写|+|, 输入内容不符合会提示错误, 此时可重新输入\n|+|{l&b}1)中心法则: |+|\n  中心法则用于转换原始链为你需要的新链, 输入过程中会发出提示, 值得一提的是由于密码子的简并性, 在选择原始\n  链类型时只提供1-3的可选类型, 注意当mRNA作为原始链时, 输入的链必须含有U, 否则会被认定为DNA；\n|+|{l&b}2)碱基频率: |+|\n  碱基频率用于计算基因中核苷酸或核苷酸片段出现的频率,计算方式为【片段出现的次数】/ (【基因长度】-【片段长\n  度】；\n|+|{l&b}3)基因的相似度:|+|\n  输入两段DNA即可求出相似度, 相似度越大两段基因的重复部分越多, 相似度不会超过【较短基因的长度】/【较长基\n  因的长度】；\n|+|{l&b}4)基因的比较:|+|\n  基因的比较功能能突出显示两端DNA的相同部分, 偏移量可以为任意整数, 表现为下方的链相对向右偏移【偏移量】个\n  单位, 负数则相对上方链向左, 为便于输入, 在偏移量处点Enter表示偏移量加1, 与之相对的是使用Tab+Enter时表示\n  偏移量减1, 在没有输入时偏移量默认为-1, 所以你可以连续键入Enter得到偏移量为0的结果, 当输入错误时偏移量会\n  变为默认值-1, 每行至多打印150个碱基, |+|{r}受输出面板缓冲的限制, 可能不能得出预期的结果；\n|+|{l&b}5)基因的存入: |+|\n  基因的存入功能需要你键入参数5来实现, 存储的基因可以通过索引值[gene整数]来调用, 程序结束时存储的基因会\n  全部清空, 每次退出时会询问是否查看已存储的基因, 按Enter进行查看, 输入索引值以查看基因的详细内容, 调用\n  不存在或不合理的基因会提示[输入错误]并需要重新输入, |+|{r}注意ATCG组成的字符串也会被当成索引值处理, 并调用它\n  本身, 只支持存入DNA；\n",
    '4' =>
"{b&u&y}|+|函数图像绘制器说明: |+|\n可以输入的有: \n\t1.绘制区域: 格式为 |+|{y&b}x1,x2,y1,y2,dx,dy|+|\n\t\t默认区域为-10,10,-10,10,0.2,0.5, 可以不输入直接输函数\n\t\t建议的比值为2:5\n\t2,绘制函数: |+|{y&b}y=x(x>-2&&x<3);#h;*c|+|\n\t\ty=f(x)为必选项, 且只能是y对x的函数, 后面的括号内跟定义域\n\t\t#h代表样式, 为可选项, 第一个为绘制所用字符, 必须为半角字符！后面的为样式, 样式请查看\%STYLE, 每个样式使用&符号分隔\n\t\t默认样式为#g (用#绘制, 颜色为green) \n\t\t*c代表交点样式, 默认为#ob. 若指定样式, 则必须指定一个以上的样式否则出错！！千万不能指定汉字为样式否则无法对齐！！\n\t3.输入1为绘制图像。已内置函数y=0, 已画好y轴\n\t4.|+|{y&b}a|+|开启动画|+|{y&b}-a|+|关闭动画\n# 有时系统可能出错, 导致绘制出的图像有些小问题\n已知bug: 输入y=x+n时会莫名退出, 但是其实会绘制y=x+n, 只要再次进入功能即可\n",
    '5'     => "{b&y}|+|ENJOY!\n",
    'style' => "样式说明: \n\t样式表详见\%STYLE\n\t使用示例: "
      . '$str="{y&b}头|+|中间|+|{b&ol}结尾";prtfmt($str,"g");'
      . "\n\t\t {} 内为样式, 每个样式使用\%STYLE中的缩写, 使用 & 隔开样式,  |+| 为分界符, 开头和结尾不用分界符, \n\t\t prtfmt 为打印, 第二个参数为对第一个字符串全局使用的样式, 优先级小于字符串中的行内样式\n\t在函数绘制中的使用方法: \n\t\ty=f(x);sy\n\t\t;分开函数与样式, 样式第一个字符s为绘制曲线时所用的字符 (不能为中文全角, 因为无法对齐) \n\t\t后面的字符遵循上面的样式表达式, 即y&ol等\n",
);    ##S帮助文档E##
our ( $o_n, $o_f, $o_h, $o_help, $o_t ) = ( '', 0, 0, '', 0 );    #运行参数
GetOptions(
    "n|N=s"        => \$o_n,      ##S直接运行第n个功能E##
    "f|F"          => \$o_f,      ##S是否展示开始的背景图像E##
    "h|H|help|?=s" => \$o_h,
    "help|?"       => \$o_help,
    "t|T"          => \$o_t,      ##S test测试用，开启测试则不启动initial函数E##
);

if ($o_help) {
    prtfmt( $HELP{"help"}, 'g' );
    print CYAN $HELP{"break"};
}    ##S运行时显示帮助E##
if ($o_h) {
    if    ($o_n)                { prtfmt( $HELP{$o_n}, 'g' ); }
    elsif ( $o_h =~ /^[1-6]$/ ) { prtfmt( $HELP{$o_h}, 'g' ); }
    elsif ( $o_h eq "style" )   { print GREEN $HELP{'style'}; }
    else                        { cluck RED "参数 $o_h 错误,应为1-6的整数\n"; }
    print CYAN $HELP{"break"};
}
our ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);    #时间
$year += 1900;        ##S大多是从1900年作为系统起始年，故加1900E##
$mon  += 1;           ##S一月为0E##
my @weekday    = qw/日 一 二 三 四 五 六/;
my @enweekdays = qw/Sun Mon Tue Wed Thu Fri Sat/;    #用于log
my @period     = qw/三更半夜好，还不去睡觉？ 上午好！ 下午好！ 晚上好！/;
prtfmt(    ##S因为$后面必须要跟空格才能让变量名不粘连中文，为不出现空格，故使用 . 连接E##
    "Hello! "
      . $period[ int( $hour / 6 ) ]
      . "现在时间是 |+|{b}"
      . $year . "年"
      . $mon . "月"
      . $mday . "日 "
      . $hour . "时"
      . $min
      . "分 星期$weekday[$wday].\n",
    'c'
);
background() if !$o_help && !$o_h && !$o_f && $o_n !~ /[1-6]/ && !$o_h && $o_t ne '1';
##S是否显示背景图E##
sub b {    ##S空格x数量E##
    " " x $_[0];
}

sub background {    ##S小写一条链，大写另一条链，遍历输出不同颜色E##
    my $background =
"acatca\n6cgtg\n92agtc\nA94a\n TTC93a\n    ACGTA7tgc  ATGCAT\n91AGCATGCAgCT6ATAT\n99at92GTA\n992ac93TG\n994tt93AT\n996gtat91TA\n7"
      . ( "#" x 10 )
      . "93aatggtgttggcAagcacatca1##\n5##9##995CG7cc##g\n5##9##997AG7##1agtc\n5##9##998A7##5a\n5##9##998TTC5##6a\n5"
      . ( "#" x 12 ) . "3"
      . ( "#" x 11 )
      . "4##3#######ACGTA##6tgc2ATGCAT\n5##92##91##4##1##92##GCATGCAgCT7ATAT\n5##92##91##6##93##8at92GTA\n5##92"
      . ( "#" x 13 )
      . "7##93##9ac93TG\n5##92##99##93##93tt93AT\n5##92##99##93##95gtat91TA\n5##94"
      . ( "#" x 12 )
      . "6##93####97aatggtgttggCaagct\n"
      . b(84) . "GC\n"
      . b(86) . "AT\n";
    my @str = split( "", $background );
    foreach (@str) {
        if    (/[1-9]/)  { print " " x $_; }
        elsif (/[ATCG]/) { print BOLD RED $_; }
        elsif (/[atcg]/) {
            print BOLD BLUE uc($_);
        }    ##S大写uc upper case E##
        elsif ("#") { print BOLD YELLOW $_; }
        else        { print $_; }
    }
}
our ( $fileisopen, $LOG, $VALUE, $FUNCTION ) =
  ( 1, "<-- $year/$mon/$mday $hour:$min $enweekdays[$wday] -->\n", "", "" );
##S用于日志记录E##

sub init {    ##S主启动程序E##
    my @area = @{ $GRAPH{'area'} };
    mkgraph( \@area );
    our $features = {
        "1" => [ "计算器",   "calculator()" ],
        "2" => [ "矩阵",    "matrix()" ],
        "3" => [ "基因",    "gene()" ],
        "4" => [ "函数图像",  "funcdraw()" ],
        "5" => [ "自由模式",  "gofree()" ],       ##S序号 名称 要启动的函数名称E##
        '6' => [ "化学计算器", 'chemistry()' ],
        '7' => [ '概率统计','statistic()'],
    };
    our @keys =
      sort { $a <=> $b } keys %$features;     ##S keys生成的数组为无序数组，每次都不同，故需给它排序E##
    open( DATA, ">>$dataFileName" )
      || ( cluck RED "Error: 无法在工作目录打开或者创建main.data.txt!请授权！$!\n",
        $fileisopen = 0 )
      ;    ##S cluck不会像die一样强制退出，而且用fileisopen全局变量表示了文件是否打开，后面判断即可E##
    if ( $o_n =~ /^[1-6]$/ ) {    ##S设置了-n n参数则使用此处先运行E##
        logres(
"used parameter -n $o_n to start function $$features{$keys[$o_n-1]}[1] named $$features{$keys[$o_n-1]}[0]",
            "info"
        );
        eval( $$features{ $keys[ $o_n - 1 ] }[1] );
        print YELLOW "$$features{ $keys[ $o_n - 1 ] }[0] 执行完毕,继续";
        logres(
"function $$features{$keys[$o_n-1]}[1] named $$features{$keys[$o_n-1]}[0] ended",
            "info"
        );
    }
    my $login = getlogin || getpwuid($<);
    prtfmt(
        "欢迎$login！请输入|+|{b}数字|+|以选择功能|+|{r} (输入0或enter结束) (输入help显示支持的命令行参数)\n",
        'y'
    );
    foreach ( 1 .. @keys ) { print CYAN "$_.$$features{$keys[$_-1]}[0]\n"; }
    my $feature = substr( <>, 0, -1 )
      ; ##S个人感觉substr比chomp（从字符串中删除尾随记录分隔符，返回从所有参数中删除的字符总数）、chop（截断字符串的最后一个字符并返回截断的字符）靠谱，susbstr( <>, 0, -1 )从0到倒数第一个（不包括倒数第一个）E##
    logres( "$feature", "in" );
    while ( $feature ne "0" ) {
        $feature = quit() if $feature eq "";      ##S如果再按Enter则返回>exit并在下一步退出E##
        last              if $feature eq ">exit";
        $feature = dsphelp("help") if $feature eq "help";
        if ( indexof( $feature, \@keys ) != -1 ) { ##S indexof自己编的数组索引，和其他语言的差不多
            logres(
"input $feature to start function $$features{$keys[$feature-1]}[1] named $$features{$keys[$feature-1]}[0]",
                "info"
            );
            eval( $$features{ $keys[ $feature - 1 ] }[1] )
              ;                                    ##S执行字符串的内容（直接运行perl语言）E##
            print YELLOW "$$features{ $keys[ $feature - 1 ] }[0] 执行完毕,请继续输入";
            logres(
"function $$features{$keys[$feature-1]}[1] named $$features{$keys[$feature-1]}[0] ended",
                "info"
            );
            prtfmt( "请输入|+|{b}数字|+|以选择功能|+|{r&b} (输入0或enter结束) \n", 'y' );
        }
        else { print RED "输入有误请重新输入！\n"; logres( "input error", "err" ); }
        $feature = substr( <>, 0, -1 );
        logres( "$feature", "in" );
    }
    logres( "exit program", 'info' );
    if ( $fileisopen == 1 && ( $LOG =~ s/\n/\n/g ) > 4 )
    {    ##E成功打开文件则记录（且要有实际输入内容）E##
        $VALUE .= 'our %MATH = (' . "\n" . logvalue( \%MATH ) . ");\n";
        $VALUE .= 'our %MATRIX = (' . "\n" . logvalue( \%MATRIX ) . ");\n";
        $VALUE .= 'our %chains = (' . "\n" . logvalue( \%chains ) . ");\n";
        no warnings;
        print DATA $LOG, "=" x 70, "\n$FUNCTION", "-" x 70, "\n$VALUE",
          "#" x 70, "\n";
        print DATA "now ".gettime();
        close DATA || cluck RED "无法关闭并保存main.data.txt文件";
    }
    print YELLOW "程序结束,欢迎下次使用！\n";
}

sub logres {    ##S日志记录，分4个级别输出为[时间] 等级 内容E##
    my ( $content, $level ) = @_;
    my $str = gettime();
    if    ( $level eq "in" )   { $str .= "<= " }
    elsif ( $level eq "out" )  { $str .= "=> " }
    elsif ( $level eq "err" )  { $str .= "!! " }
    elsif ( $level eq "info" ) { $str .= "== " }
    else                       { $str .= "   " }
    $str .= "$content\n";
    $LOG .= $str;
}

sub gettime {
    my @t = localtime(time);
    @t[ 4, 5 ] += ( 1, 1900 );
    @t = map { sprintf "%02s", $_ } @t;    ##S sprintf 格式化输出%代表第一个变量，s开头补0至2位E##
    my $str = "[ $t[5]-$t[4]-$t[3] $t[2]:$t[1]:$t[0] ] ";
    $str;
}

sub logfunc {    ##S函数的日志记录E##
    my ( $content, $func ) = @_;
    my $str = gettime();
    $str .= "F: $func  $content\n";
    $LOG .= $str;
}

sub logvalue {    ##S变量的日志记录E##
    my %x   = %{ $_[0] };
    my @key = sort sort ( keys %x );
    my $str = "";
    foreach (@key) {
        my $a = $x{$_};
        $str .= "\t$_ => ";
        if ( ref($a) eq "ARRAY" ) {
            if ( ref( @$a[0] ) eq "ARRAY" ) {
                $str .= "[ ";
                foreach (@$a) {
                    $str .= "[ " . join( ", ", @$_ ) . "],";
                }
                $str .= " ],\n";
            }
            else { $str .= "[ " . join( ", ", @$a ) . "],\n"; }
        }
        else { $str .= "$a,\n"; }
    }
    $str;
}
our @Tips = ('大写字母R reduce 约分，D decomp 分解质因数，F fraction 化为分数，P prime 质数表，PMT permutation 全排列'."\n".'后加 (x) 为调用该函数，而不会寻找变量！','[^n]等价于*10^n');
sub calculator {    ##S计算器主程序E##
    print GREEN "欢迎使用计算器！功能及详细讲解请在运行时添加参数 -h 1 或现在键入help\n";
    my $input = substr( <>, 0, -1 );
    logres( $input, 'in' );
    my %trsfun = (
        'deg', 'deg2rad', 'R', 'reduce',   'D',   'decomp',
        'F',   'tofrac',  'P', 'getprime', 'PMT', 'permutations',
        'arr', 'numarr',
    );
    while (1) {
        $input = quit()       if $input eq "";
        last                  if $input eq ">exit";
        $input = dsphelp("1") if $input eq "help";
        $input =~ s/=[ \t]*$//;    # 删去末尾的=
        my ( $o, $logstr ) = ( $input, "1<$input>" ); # 原始输入 和 输入转换日志
        $input =~ s/ {2,}/ /g;  # 去除所有的空格
        $input =~ s/ ([\+\-\*\/\(\)\{\}]*) /$1/g;
        $input = tohalfangle($input);                       ##S把中文全角字符转为英文半角E##
        $input =~ s/(\d)\\/$1\*\\/g;           # !!!             ##S变量and变量之间添加*乘号E##
        $input =~ s/\*?\[\^([0-9\.\-]+)\]/\*10\*\*\($1\)/g; ##S [^n]换为*10^nE##
        # $input =~ s/\/\^([^\/]+)\//\(\($1\)\*\*0.5\)/g;     ##S /^x/换为x的开平方E## 与除号 / 冲突 而且语义不明
        $input =~ s/log([^\{]+)\{([^\}]+)\}/logn\($2,$1\)/g;  ## log底数{真数} 变为 logn(底数，真数) 可为英文符号 可为数字
        $input =~ s/lg([^a-zA-Z])/log10 $1/g;
        $input =~ s/\^/**/g;
        $input =~ s/arc(.{3})/a$1 /g;
        $input =~ s/(sin|cos|tan|cot|sec|csc|ln) */$1 /g;
        map { $input =~ s/$_\(/$trsfun{$_}\(/g; } keys(%trsfun);
        $input =~ s/([0-9]+)!([^=])/mul\(1\.\.$1\)$2/g;     ##S 阶乘的转换E##
        $input =~ s/\[\\([a-zA-Z]([a-zA-Z0-9]+)?+)\\\]/\@\{\$MATH\{'$1'\}\}/g;
        $input =~ s/\\([a-zA-Z]([a-zA-Z0-9]+)?+)\\/\$MATH\{'$1'\}/g;
        $logstr .= " 2<$input>";

        if ( $input =~ /^([0-9\-\.]+,){5}[0-9\-\.]+$/ || $input =~ /^f:/ ) {
            $input =~ s/^f://;
            funcdraw($input);
            logres(
"input <$o> is transformed to <$input>, and executed as function draw",
                "info"
            );
            $input = substr( <>, 0, -1 );
            logres( $input, "in" );
            next;
        }
        $input =~ s/(\d)([a-zA-Z]+)/$1\*$2/g;    ##S数字and字母之间添加*乘号E##
        $input =~ s/^([\+\-\*\/\^])/ans$1/;      ##S开头为运算符则添加默认变量名ans E##
        $input =~
          s/([^a-zA-Z\\])([a-zD-Z])([^a-zA-Z0-9\\])/$1\$MATH\{'$2'\}$3/g;     ##S 单字母转换
        $input =~ s/([^a-zA-Z])([a-zA-Z]+)$/$1\$MATH\{'$2'\}/g;
        $input =~ s/^([a-zA-Z]+)([^a-zA-Z0-9=\(\{\[ \:])/\$MATH\{'$1'\}$2/g;
        $logstr .= " 3<$input>";
        $input =~ s/([\+\-\*\/])([a-zD-Z]{1,2})([^a-zA-Z ])/$1\$MATH\{'$2'\}$3/g;
        my @keysmath = keys %MATH;
        my ( $name, $str ) = ( 0, $input );

        if ( indexof( $input, \@keysmath ) != -1 ) {
            $input = '$MATH{' . $input . '}';
            $str   = $input;
        }
        else {
            if ( $input =~ /^[a-zA-Z][a-zA-Z0-9]*=/ ) {
                ( $name, $str ) = split( '=', $input, 2 );
                $input =~ s/^([a-zA-Z][a-zA-Z0-9]*)=/\$MATH\{'$1'\}=/;
            }
            else { $name = 'ans'; }
        }
        $logstr .= " 4<$input>";
        print $input."\n" if $DEBUG;
        logres( $logstr, 'info' );
        if ( $str =~ /\$MATH/ ) {
            my ( $check, $f ) = ( $str, 0 );
            $check =~ s/\$MATH\{['"]?([a-zA-Z0-9]+)["']?}/【$1】/g;
            $check =~ s/^[^【]*【//;
            $check =~ s/】[^【]*【/#/g;
            $check =~ s/】[^】]*$//;
            my @checkarr = split( '#', $check );
            foreach my $c (@checkarr) {
                if ( indexof( $c, \@keysmath ) == -1 ) {
                    print RED"Error: 未找到 $c 变量, 请重新输入: \n";
                    logres( "check:$check,$c not found", 'err' );
                    $input = substr( <>, 0, -1 );
                    $f     = 1;
                    last;
                }
            }
            next if $f == 1;
        }
        if ( $str =~ /reduce/ ) {
            if ( athead( $input, 'reduce', 'R' ) ) {
                $input = substr( <>, 0, -1 );
                next;
            }
            eval(   'my @res = '
                  . $input
                  . ';print CYAN $res[0]." / ".$res[1]."\n";logres($res[0]." / ".$res[1],"out");'
            );
        }
        elsif ( $str =~ /tofrac/ ) {
            if ( athead( $input, 'tofrac', 'F' ) ) {
                $input = substr( <>, 0, -1 );
                logres( $input, 'in' );
                next;
            }
            my @res = ();
            eval( '@res = ' . $input . ';' );
            my $r = "$res[0] / $res[1] 误差: $res[2]";
            print CYAN "$r\n";
            logres( $r, 'out' );
        }
        elsif ( $str =~ /getprime/ ) {
            my ( $out, @p ) = ( "", () );
            eval( '@p = ' . $str . ';' );
            $MATH{$name} = \@p if $name;
            if ( $str =~ /^getprime/ ) {
                foreach ( 0 .. $#p ) {
                    $out .= $p[$_] . "\t";
                    $out = ( substr( $out, 0, -1 ) . "\n  " )
                      if !( ( $_ + 1 ) % 10 );
                }
                $out = substr( $out, 0, -1 );
                $out = substr( $out, 0, -2 ) if !( @p % 10 );
                print CYAN "[ $out ]\n";
            }
            elsif ( $str =~ /^decomp/ ) { prtdecomp( \@p ); }
            else                        { prtres( $o, \@p ); }
            logres( "\n[ @p ]", "out" );
        }
        elsif ( $str =~ /permutations/ ) {
            if ( athead( $input, 'permu', 'PMT' ) ) {
                $input = substr( <>, 0, -1 );
                logres( $input, 'in' );
                next;
            }
            my @p = ();
            eval( '@p = ' . $input . ';' );
            logres( "\n[ here is the result of $input ]", 'out' );
            if ( @p > 40000 ) {
                foreach ( 0 .. $#p ) { print CYAN"@{$p[$_]}\n"; }
            }
            else { prtmatrix( \@p ); }
        }
        elsif ( $str =~ /decomp/ ) {
            my @times = ();
            if ( $str =~ /^decomp/ ) {
                eval( '@times=' . $str . ';' );
                $MATH{$name} = \@times if $name;
                logres( "\n[ @times ]", 'out' );
                prtdecomp( \@times );
            }
            else {
                my $out = eval($str);
                $MATH{$name} = $out if $name;
                prtres( $o, $out );
            }
        }
        elsif ( $str =~ /(^\([0-9\.,]+\)$)|(^numarr)/ ) {
            my @arr = ();
            eval( '@arr=' . $str . ';' );
            $MATH{$name} = \@arr if $name;
            prtres( $o, \@arr );
        }
        else {
            eval($input) if $input =~ /\\\@/;
            my $out = eval($str);
            $MATH{$name} = $out if $name && defined $out;
            prtres( $o, $out );
        }
        $input = substr( <>, 0, -1 );
        logres( $input, 'in' );
    }
    print YELLOW "退出计算器\n";
}
sub statistic {
    # 概率统计

}
sub Bernoulli{
    my ($p,$k) = @_;
    my ($E,$S2) = ($p,$p*(1-$p));
    my @x = (0,1);
    if(defined $k && indexof($k,\@x)>=0){return $k*$p;}
    print("X\t".join("\t",@x)."\n");
    print("p\t".join("\t",map{$_*$p}@x)."\n");

}
sub Binomial{
    my ($n,$p,$k) = @_;
    my $q = 1-$p;
    my @x = (0..$n);
    if(defined $k && indexof($k,\@x)>=0){return C($n,$k)*($p**$k)*($q**($n-$k));}
    print("X\t".join("\t",@x)."\n");
    
    printf("p\t".("%6.5f\t"x($n+1))."\n",map{C($n,$_)*($p**$_)*($q**($n-$_));}@x);
}
# Bernoulli(0.2);
print Binomial(10,1/70,3);
# my @xa = ();
# for(0..3){
#     push @xa,Binomial(103,0.015,$_);
#     # print("x=$_, p=$xa[$_]\n");
# }
# print sum(@xa);
sub A{
    my ($res,$sub,$sup)=(1,@_);
    for(0..$sup-1){
        $res*=$sub-$_;
    }
    $res;
}
sub C{
    my ($res,$sub,$sup)=(1,@_);
    A($sub,$sup)/A($sup,$sup);
}
sub tohalfangle {    ##S全角字符转为半角字符E##
    @_ = map {
        my $s = $_;
        $s =~ tr/！￥（）—【】、，。；：‘“’”/!$()\-[]\/,.;:'"'"/;
        $s
    } @_;
    @_ == 1 ? $_[0] : @_;
}

sub athead {
    my ( $input, $target, $abbr ) = @_;
    if ( $input !~ /^$target/ ) {
        print RED"$abbr 函数要写在开头！请重新输入: \n";
        logfunc( "!! R,F,PMT need to be at the head of input!", "athead" );
        return 1;
    }
}
sub qe { # 求解一元二次方程
    my($a,$b,$c)=@_;
    my $delt = $b*$b-4*$a*$c;
    if($delt<0){
        print"无解";
    }elsif($delt==0){
        return [-$b/(2*$a)];
    }
    elsif($delt>0){
        return [(-$b-$delt**0.5)/(2*$a),(-$b+$delt**0.5)/(2*$a)]
    }
}
sub prtres {    ##S printresult E##
    my ( $o, $out ) = ( $_[0], $_[1] );
    if ( !defined $out ) {
        logfunc(
"!! because of the following error, the result is undefined:\n1.zero 0 is put in the denominator\n2.quoted var but not in \\\\\n3.between number and word need a *\n4.the brackets is not matched",
            'err'
        );
        $out = "Error! 0作分母丨 变量不存在丨未加\\x\\丨 缺少*丨括号未成对 …… ";
        print RED "$o = " . $out . "\n";
    }
    elsif ( ( ref $out ) eq "ARRAY" ) {
        my @arr = @{$out};
        logres( "\n[ @arr ]", 'out' );
        print CYAN "$o = [ @arr ]\n";
    }
    else {
        logres( "$out", 'out' );
        print CYAN "$o = " . $out . "\n";
    }
}

sub prtdecomp {    ##S printdecomposition 打印分界质因数的结果 E##
    my @times = @{ $_[0] };
    my ( $a, $b, $out, $t ) = ( "质数:  ", "次方:  ", "", 0 );
    foreach ( 0 .. $#times ) {
        if ( $times[$_] ) {
            $t++;
            ( $a, $b ) = ( $a . "$PRIME[$_]\t", $b . "$times[$_]\t" );
            if ( $t - 10 == 0 ) {
                $out .= "$a\n$b\n";
                ( $t, $a, $b ) = ( 0, "质数:  ", "次方:  " );
            }
        }
    }
    $out .= "$a\n$b\n" if $t != 0;
    print CYAN "$out";
}

sub gofree {
    print GREEN "欢迎来到自由模式！功能及详细讲解请在运行时添加参数 -h 5 或现在键入help\n";
    my $input = substr( <>, 0, -1 );
    while ( $input ne "0" ) {
        if ( $input eq "help" ) {
            prtfmt( $HELP{5}, "g" );
            print CYAN $HELP{"break"};
            print YELLOW "请输入: \n";
            $input = substr( <>, 0, -1 );
        }
        $input = quit() if $input eq "";
        last            if $input eq ">exit";
        my $res = eval($input);
        defined $res
          ? print CYAN $res
          : print YELLOW"the result is undefined.\n";
        $input = substr( <>, 0, -1 );
    }
}

sub dsphelp {    ##S display help E##
    prtfmt( $HELP{ $_[0] }, 'g' );
    print CYAN $HELP{"break"};
    print YELLOW "请输入: \n";
    substr( <>, 0, -1 );
}

sub funcdraw {    ##S function draw 主程序E##
    print GREEN "欢迎使用函数图像绘制器!帮助请扣help\n" if !$_[0];
    my $input = $_[0] ? $_[0] : substr( <>, 0, -1 );
    while ( $input ne "0" ) {
        $input = quit() if $input eq "";
        last            if $input eq ">exit";
        $input = dsphelp('4') if $input eq "help";
        my $o = $input;
        $input = tohalfangle($input);
        $o .= " -> $input ";
        if ( $input =~ /^([0-9\-\.]+,){5}[0-9\-\.]+$/ ) {
            my @areai = ();
            eval( '@areai =(' . $input . ');' );

            $o .= ": area";
            print CYAN"坐标格已绘制, 范围为$input\n" if mkgraph( \@areai );
        }
        elsif ( $input =~ /^y\=/ ) {
            my @arr  = split( ";", $input, 2 );
            my $func = $arr[0];
            print CYAN "函数 $func 已导入\n";
            $func =~ s/(\([^\)]+[<>=][^\)]+\))$/ if $1/;
            my $sty = $#arr == 0 ? "#g" : $arr[1];
            drawfunction( $func, $sty );
            $o .= "func: $func, style :$sty";
        }
        elsif ( $input eq "1" ) {
            $o .= "displaying graph";
            prtfmt( "绘制完成, 如有未显示的函数, 说明该函数无效(|+|{y&b}注意加*乘号|+|)\n", 'g' )
              if displaygraph();
        }
        elsif ( $input eq "c" ) {
            my @area = @{ $GRAPH{"area"} };
            print CYAN"坐标格已清空\n" if mkgraph( \@area );
        }
        elsif ( $input eq "a" || $input eq "+a" ) {
            $ANIMATE = 1;
            print CYAN"已开启动画\n";
        }
        elsif ( $input eq "-a" ) {
            $ANIMATE = 0;
            print CYAN"已关闭动画\n";
        }
        else {
            $o .= "error: case not matched";
            print RED"Error: 输入有误,请重新输入,输入help查看帮助信息\n";
        }
        logres( $o, 'out' );
        return 1 if $_[0];
        $input = substr( <>, 0, -1 );
        logfunc( "$o -> $input", "funcdraw" );
    }
}

sub mkgraph {    ##S makegraph绘制坐标纸 E##
    my @area = @{ $_[0] };
    my ( $x1, $x2, $y1, $y2, $dx, $dy ) = @area;
    @area[ 1, 3 ] = ( $x2 + $dx, $y2 + $dy );
    %GRAPH = ();
    $GRAPH{'area'} = \@area;
    my @xdefined = numarr( $x1, $x2 + 2 * $dx, $dx );
    my @ydrawed  = numarr( $y1, $y2 + $dy,     $dy );
    my ( $x0, $y0 );
    $x0 = int( -$x1 / $dx ) if ( $x1 < 0 && $x2 > 0 );
    $y0 = int( -$y1 / $dy ) if ( $y1 < 0 && $y2 > 0 );
    my @y = ();
    foreach ( 0 .. $#xdefined - 1 ) { push @y, " "; }
    push @y, "|+|{h} |+|";

    if ($x0) {
        $y[$x0] = "|+|{c}||+|" if $x0 ne "" && $x0 - @xdefined != 0 && $y[$x0];
    }
    foreach ( 0 .. $#ydrawed ) { $GRAPH{$_} = \@y; }
    drawfunction( 'y=0', '-c' );
    1;
}

sub drawfunction {    ##S 将函数绘制到坐标纸上 E##
    my ( $fun, $styl, @area ) = ( $_[0], $_[1], @{ $GRAPH{'area'} } );
    my @sty    = split( ";", $styl );
    my $syb    = substr( $sty[0], 0, 1 );
    my @symbol = ( $syb, $sty[1] ? substr( $sty[1], 0, 1 ) : $syb );
    $styl = substr( $sty[0], 1 );
    @sty  = ( $styl, $sty[1] ? substr( $sty[1], 1 ) : $styl . "&oy" );
    $fun =~ s/([xy])/\$$1/g;
    my ( $yfloor, $yceil, $y ) = ( $area[2], $area[3], undef );
    my @xdefined = numarr( $area[0], $area[1], $area[4] );
    my @ydrawed  = numarr( $yfloor,  $yceil,   $area[5] );

    foreach my $i ( 0 .. $#xdefined ) {
        my $x = $xdefined[$i];
        eval($fun);
        if ( defined $y && $y >= $yfloor && $y <= $yceil ) {
            my $locationy = round( ( $y - $yfloor ) / $area[5] );
            my @tmp       = @{ $GRAPH{$locationy} };
            my $str =
              $tmp[$i] eq ' ' || $tmp[$i] eq '|+|{h} |+|'
              ? "|+|{$sty[0]}$symbol[0]|+|"
              : "|+|{$sty[1]}$symbol[1]|+|";
            $tmp[$i] = $str;
            $GRAPH{$locationy} = \@tmp;
            if ( $ANIMATE && $fun ne '$y=0' ) {
                if    ( $^O eq 'linux' )   { system('clear'); }
                elsif ( $^O eq 'MSWin32' ) { system("cls"); }
                displaygraph();
            }
        }
        $y = undef;
    }
    return 1;
}

sub displaygraph {
    my @area = @{ delete $GRAPH{"area"} };
    my @keys = sort { $a <=> $b } ( keys %GRAPH );
    my ( $xfloor, $xceil, $yfloor, $yceil, $dx, $dy ) = @area;
    my @ydrawed  = numarr( $yfloor, $yceil, $dy );
    my @xdefined = numarr( $xfloor, $xceil, $dx );
    my ( $ydecdig, $yint, $ylength ) = (
        length( $dy - int($dy) ) - 2,
        length( int( max( abs($yceil), abs($yfloor) ) ) )
    );
    my $y1neg = $yfloor < 0 ? 1 : 0;
    if ( @keys > 1 ) {
        foreach my $i ( numarr( $#keys, -1 ) ) {
            my @iy = @{ $GRAPH{ $keys[$i] } };
            my ( $str, $y ) = ( join( "", @iy ), $ydrawed[$i] );
            my $yneg = $y < 0 ? 1 : 0;
            $y = abs($y);
            my $y1 = sprintf "%0" . $yint . "dE", $y;
            $y1 = substr( $y1, 0, index( $y1, '.' ) );
            $y1 = " " . $y1 if ( $y1neg && !$yneg );
            $y1 = "-" . $y1 if $yneg;
            my $y2;
            if ( $ydecdig == -1 ) { $y2 = ""; }
            else {
                $y2 = ( sprintf "%*1\$.*f", $ydecdig, $y, 10 );
                $y2 = substr( $y2, index( $y2, '.' ) );
            }
            prtfmt( "{y}|+|$y1$y2 |+|" . $str . "\n" );
            $ylength = length("$y1$y2 ");
        }
    }
    my $maxlengthofx = max( length( $xfloor + $dx ), length( $xceil + $dx ) );
    foreach my $i ( 0 .. $maxlengthofx - 1 ) {
        my ( $n, $out ) = ( 0, " " x $ylength );
        while ( $n < @xdefined ) {
            if ( length( $xdefined[$n] ) > $i ) {
                $out .= ( substr( $xdefined[$n], $i, 1 ) . " " );
            }
            else { $out .= "  "; }
            $n += 2;
        }
        prtfmt( $out . "\n", 'y' );
    }
    $GRAPH{"area"} = \@area;
    1;
}

sub matrix {    ##S矩阵主程序E##
    print GREEN "欢迎使用矩阵!帮助请扣help\n";
    my $input = substr( <>, 0, -1 );
    my $exitinfo =
'if ( $res eq ">exit" ) {print YELLOW"已退出输入, 上面的矩阵未被录入, 请重新输入矩阵 (A=n) : \n";}else{prtmatrix(\@{$MATRIX{$input}});}';
    while ( $input ne "0" ) {
        ( $PROCESS, $input ) = ( 1, ">next1" ) if $input eq "+p";
        ( $PROCESS, $input ) = ( 0, ">next2" ) if $input eq "-p";
        if ( $input =~ /^>next[12]/ ) {
            print YELLOW "显示过程\n" if $input eq ">next1";
            print YELLOW "隐藏过程\n" if $input eq ">next2";
            $input = substr( <>, 0, -1 );
            next;
        }
        $input = quit()       if $input eq "";
        last                  if $input eq ">exit";
        $input = dsphelp('2') if $input eq "help";
        $input =~ s/ +//g;
        $input = tohalfangle($input);
        if($input =~ /^O(=\d+)?$/){
            prtmatrix( \@{ $MATRIX{'O'} } );
            print YELLOW "O为保留关键字,为默认结果存放位置,请不要修改\n" if $input =~ /O=/ ;
        }elsif($input =~ /^E=/ || $input eq 'E'){
            prtmatrix( \@{ $MATRIX{'E'} } );
            print YELLOW "E为保留关键字,为单位矩阵,可自由变换大小,请不要修改\n" if $input =~ /=/}
        elsif ( $input =~ /^[A-Z]$/ ) {
            my @keys = keys(%MATRIX);
            if ( indexof( $input, \@keys ) != -1 ) {
                prtmatrix( \@{ $MATRIX{$input} } );
                print YELLOW"覆盖请再次输入 $input ,输入其他则继续: ";
                my $r = substr( <>, 0, -1 );
                if ( $r eq $input ) {
                    my $res = mkmatrix($input);
                    eval($exitinfo);
                }
                else { $input = $r; next; }
            }
            else {
                my $res = mkmatrix($input);
                eval($exitinfo);
            }
        }
        elsif ( $input =~ /^[A-Z]=[0-9]+$/ ) {
            my @a = split( '=', $input, 2 );
            $input = $a[0];
            my $res = mkmatrix( $a[0], $a[1] );
            eval($exitinfo);
        }
        elsif ( $input =~ /^([A-Z]\=)?[0-9\-\.A-Z\(\)xtrsid\*\+\^\/]*$/ ) {
            my ( $out, $str ) =
              $input =~ /^[A-Z]\=/
              ? ( substr( $input, 0, 1 ), substr( $input, 2 ) )
              : ( 0, $input );
            my @res = calcstr($str);
            if ( $res[0] eq ">exit" ) {
                print RED "Error: 所有矩阵中未找到算式中的某个矩阵名称 或者 计算中出现错误, 请重新输入: \n";
            }
            else {
                prtmatrix( \@res );
                $out = 'O' if !$out;
                $MATRIX{$out} = \@res;
            }
        }
        else { print RED"Error: 输入有误, 请重新输入([A-Z]=n)\n"; }
        $input = substr( <>, 0, -1 );
    }
}

sub permutations {
    our $n = $_[0];
    while ( $n > 7 ) {
        print YELLOW"即将求 $n 的全排列, 将消耗较长时间, 继续1, 结束0: ";
        my $sel = substr( <>, 0, -1 );
        return ( 1 .. $n ) if $sel eq "0";
        last               if $sel eq "1";
    }
    my $target = mul( 1 .. $n );
    my $format = '%2d Elapsed: %8t %20b %4p %2d (%8c of %11m)';
    our $ctr =
      Term::Sk->new( $format, { freq => 1000, base => 0, target => $target } )
      if $TERM_SK;
    our ( @res, @row );
    our $s = '@res=(';

    sub alllist {
        if ( @row == $n ) {
            $s .= ( "[" . join( ",", @row ) . "]," );
            $ctr->up if $TERM_SK;
        }
        else {
            foreach ( 1 .. $n ) {
                next if indexof( $_, \@row ) != -1;
                push @row, $_;
                alllist();
                pop @row;
            }
        }
    }
    alllist();
    $ctr->close if $TERM_SK;
    eval( $s . ')' );
    @res;
}

sub calcstr {    ##S计算矩阵算式E##
    my $str = $_[0];
    print "=" . ( "=" x 19 ) . "\ngotten str=$str\n" if $PROCESS && $str ne '%>opt';
    if ( $str =~ /^[0-9\-\.\+\*\/\(\)]+$/ ) {
        my $out;
        eval( '$out=' . $str . ';' );
        return ( $out, );
    }
    my ( $s, @res, @y, @x ) = ( $str, (), () );

    # $s =~ s/\^t$//g;
    $s =~ s/[^A-Z]//g;
    my @n = split( '', $s );
    if ( $str eq '%>opt' ) {
        @x   = ref $_[1] eq 'ARRAY' ? @{ $_[1] } : ( $_[1] );
        @y   = ref $_[2] eq 'ARRAY' ? @{ $_[2] } : ( $_[2] );
        $str = $_[3];
        print "operation mode =$str\n" if $PROCESS;
    }
    else {
        if ( $#n < 2 ) {
            $n[0] = $n[0] ? $n[0] : "#undef";
            my @key = keys %MATRIX;
            if ( indexof( $n[0], \@key ) == -1 ) {print RED "未找到 $n[0]\n"; return ( ">exit", ); }
            @x = @{ $MATRIX{ $n[0] } };
            ##S这里有个问题，明明取出矩阵后放入了另一个变量，该变量还多次传递，为什么数乘和逆矩阵还是会改变原矩阵？[因为这里仍然是代表一个引用，并没有复制过来]最后通过新生成一个全新数组搞定E##
            if ( @n > 1 ) {
                if ( indexof( $n[1], \@key ) == -1 ) {print RED "未找到 $n[1]\n"; return ( ">exit", ); }
                @y = @{ $MATRIX{ $n[1] } };
            }
        }
    }
    $_ = $str;
    if    (/^d[A-DF-Z]$/) { @res = rowreduce( \@x, 'det' ); }
    elsif (/^r[A-DF-Z]$/) { @res = rank( \@x ) }
    elsif (/^s[A-DF-Z]$/) { @res = rowreduce( \@x ) }
    elsif (/^-?[\.0-9]+(x\*)?[A-Z]$/) {
        $str =~ s/[A-Z]//g;
        @res = nmu( tonum($str), \@x );
    }
    elsif (/^[A-Z]\+[A-Z]$/)     { @res = plus( \@x, \@y ); }
    elsif (/^[A-Z]\-[A-Z]$/)     { @res = plus( \@x, \@y, '-1' ); }
    elsif (/^[A-Z][x\*]?[A-Z]$/) { @res = mmul( \@x, \@y ); }
    elsif (/^[A-Z]\/[A-Z]$/)     { @res = divide( \@x, \@y ); }
    elsif (/^t[A-DF-Z]$/)        { @res = trsf( \@x ); }
    elsif (/^i[A-DF-Z]$/)        { @res = rowreduce( \@x, 'inv' ); }
    elsif (/^[A-Z]$/)            { @res = @x; }
    elsif ( $_ !~ /[\+\-\(\)\/]/ ) {    ##S连续乘法运算E##
        print GREEN "MixCalc\n" if $PROCESS;
        $str =~ s/([A-Z])([A-Zdrsti])/$1#$2/g;
        $str =~ s/([A-Z])([A-Zdrsti])/$1#$2/g;
        $str =~ s/([A-Z])(\d)/$1#$2/g;
        $str =~ s/([rs])/#$1/g;
        my @name = split( "#", $str );
        my $num  = 1;

        foreach ( 0 .. $#name ) {
            my $every = $name[$_];
            if ( $every =~ /^ *$/ ) {
                next;
            }
            else {
                print GREEN "step " . ( $_ + 1 ) . ": $every\n" if $PROCESS;
                my @ans = calcstr($every);
                return ( ">exit", ) if $ans[0] eq '>exit';
                if ( ref( $ans[0] ) eq "" ) {
                    $num *= $ans[0];
                    prtfmt( "Result is a num: |+|{c}$num\n", 'g' ) if $PROCESS;
                }
                else {
                    print GREEN "Result is a matrix:\n" if $PROCESS;
                    prtmatrix( \@ans )                  if $PROCESS;
                    @res = @res ? mmul( \@res, \@ans ) : @ans;
                    return ( ">exit", ) if $res[0] eq '>exit';
                }
            }
        }
        @res = @res > 0 ? nmu( $num, \@res ) : ( $num, );
        print GREEN "Final Result is \n" if $res[0] ne '>exit' && $PROCESS;
    }

    # elsif( /[^\(]/ && s/\|/\|/g <3){}
    else
    { ##S 最多使用一个括号，一个求行列式||，因为控制栈的进出我还不会【现在我会啦哈哈】,而且由于行列式分隔符相同，根本没法控制进栈与出栈所以行列式要多级包含只能加括号E##
         # if(indexof('(',$str,indexof('(',$str)+1)!= -1){return ">exit"} # 括号多余两个不干，想想还是算了，其实多组同级括号还是可以求的
        my @str = split( '', $str );
        my ( $br, @node ) = ( 0, 0 );
        foreach my $i ( 0 .. $#str ) {
            $_ = $str[$i];
            if    (/\(/) { push @node, $i if !$br; $br++; }
            elsif (/\)/) { $br--; push @node, $i if !$br; }
            elsif ( /[\+\-\/]/ && !$br ) { push @node, $i; }
        }
        print RED "括号未成对!\n" if $br;
        return (">exit") if $br;    #发现括号不匹配则退出
        push @node, length($str);
        shift @node          if $node[1] == 0;
        print "node=@node\n" if $PROCESS;
        my $start  = $str[0] eq '(' ? 1 : 0;
        my $length = $node[1] - $start;
        print GREEN "#Step1:\n" if $PROCESS;
        @res = calcstr( substr( $str, $start, $length ) );
        return ">exit" if $res[0] eq '>exit';
        prtmatrix( \@res ) if $PROCESS;
        my $flag = 0;
        foreach my $j ( 2 .. $#node ) {
            $start  = $node[ $j - 1 ] + 1;
            my $now = $node[$j];
            $length =$now - $start;
            next                    if $length < 1;
            if(defined $str[$now] && $str[$now] eq '(' && $str[$now-1] !~ /[\+\-\/]/ ){
                $node[$j]=$node[$j-1];
                $node[$j+1]+=1;
                $flag = 1;
                next;
            }
            print GREEN "#Step$j\n" if $PROCESS;
            my $tocalc =  substr( $str, $start, $length );
            next if $tocalc =~ /^[\+\-\*\/\(\)]+$/;
            my @r = calcstr( );
            return ">exit" if $r[0] eq '>exit';
            prtmatrix( \@r ) if $PROCESS;
            my $operation = $str[ $node[ $j - 1 ] ];
            if ( $operation =~ /[\(\)]/ ) { my $pre = $str[ $node[ $j - 1 ] -1];$operation = $pre !~ /[\+\-\/]/ ? '*':$pre; }
            $operation = "A" . $operation . "B";
            print GREEN "#Step Mix \n" if $PROCESS;
            @res       = calcstr( '%>opt', \@res, \@r, $operation );
            prtmatrix( \@res);
            if ($flag){$node[$j]-=1;$flag=0;}
        }
    }
    ( !defined $res[0] || $res[0] eq 'err' ) ? (">exit") : @res;
}

sub divide {
    my $a = $_[0]->[0];
    my $b = $_[1]->[0];
    if(ref $b eq 'ARRAY'){
        print RED "矩阵不能作除数,要使用逆矩阵,请用iA\n";
        return ('>exit',);
    }
    if(ref $a eq 'ARRAY'){
        my @a = @{ $_[0] };
        return map {my @r = map{my $s = $_/$b;$s;}@{$_};\@r}@{$_[0]};
    }else{
        return map{my $s = $_/$b;$s}@{$_[0]};
    }
}

sub prtmatrix {    ##SprintmatrixE##
    my @arr = @{ $_[0] };
    my $out = "[[\t";
    if ( ref $arr[0] ) {
        foreach my $i ( 0 .. $#arr ) {
            my @tmp = @{ $arr[$i] };
            foreach my $j (@tmp) {
                $out .= "$j\t";
            }
            $out = substr( $out, 0, -1 ) . "\t]\n [\t";
        }
        $out = substr( $out, 0, -4 ) . "]\n";
        print CYAN"$out";
    }
    else { print CYAN"[ @arr ]\n"; }
}

sub mkmatrix {    ##S makematrix E##
    my ( $name, $r ) = @_;
    if ( !$r ) {
        print YELLOW"请输入矩阵行数: ";
        $r = substr( <>, 0, -1 );
        until ( $r =~ /^[0-9]+$/ ) {
            print YELLOW"请输入整数: \n";
            $r = substr( <>, 0, -1 );
            $r = quit() if $r eq "";
            return ">exit" if $r eq ">exit";
        }
    }
    my @A  = ();
    my @r1 = inrow();
    return ">exit" if $r1[0] eq ">exit";
    push @A, \@r1;
    my $i = 1;
    while ( $i < $r ) {
        my @x = inrow();
        return ">exit" if $x[0] eq ">exit";
        if ( @x == @r1 ) {
            push @A, \@x;
            $i++;
        }
        else { print RED "Error: 列数不同, 重新输入该行: \n"; }
    }
    my $str = '$MATRIX{"' . $name . '"} = \@A;';
    eval($str);
}

sub size {    ##S 返回矩阵大小E##
    my @a = @{ $_[0] };
    my $r = @a;
    if ( ref $a[0] ne 'ARRAY' ) {
        return ( $r, 0 );
    }
    my @c = @{ $a[0] };
    my $l = @c;
    foreach ( 0 .. $#a ) {
        @c = @{ $a[$_] };
        print RED "矩阵中第 " . ( $_ + 1 ) . " 行与上几行的列数不一致！！\n" if $l != @c;
    }
    ( $r, $l );
}

sub plus {    ##S矩阵加法E##
    if ( ref $_[0] eq 'ARRAY' && ref $_[1] eq 'ARRAY' ) {
        my $flag = $_[2] ? -1 : 1;
        my @a    = @{ $_[0] };
        my @b    = @{ $_[1] };
        my @s1   = size( \@a );
        my @s2   = size( \@b );
        if ( !$s1[1] && !$s2[1] ) {
            return
              map { $_ = $flag ? $a[$_] - $b[$_] : $a[$_] + $b[$_]; $_; }
              0 .. min( $#a, $#b );
        }
        if ( !$s1[1] ) {
            @s1 = @s2;
            @a  = map {
                my $r = $_;
                my @r = map { $_ = $_ == $r ? $a[0] : 0; } 1 .. $s2[1];
                \@r;
            } 1 .. $s2[0];
        }
        if ( !$s2[1] ) {
            @s2 = @s1;
            @b  = map {
                my $r = $_;
                my @r = map { $_ = $_ == $r ? $b[0] : 0; } 1 .. $s1[1];
                \@r;
            } 1 .. $s1[0];
        }
        my @result;
        if ( $s1[0] == $s2[0] && $s1[1] == $s2[1] ) {
            foreach my $i ( 0 .. $s1[0] - 1 ) {
                my @tmp = ();
                foreach my $j ( 0 .. $s1[1] - 1 ) {
                    my $x = @{ $a[$i] }[$j];
                    my $y = @{ $b[$i] }[$j];
                    $flag == 1
                      ? ( push @tmp, $x + $y )
                      : ( push @tmp, $x - $y );
                }
                push @result, \@tmp;
            }
            @result;
        }
        else {
            print RED"Error: 只有同型矩阵才能相加减。\n";
            return 0;
        }
    }
    else {
        return $_[0] + $_[1];
    }
}

sub minus {    ##S 矩阵减法E##
    my @a   = @{ $_[0] };
    my @b   = @{ $_[1] };
    my @arr = plus( \@a, \@b, -1 );
    @arr;
}

sub nmu {    ##S数乘矩阵E##
    my $n = $_[0];
    my @a = @{ $_[1] };
    if ( ref $a[0] ne "ARRAY" ) {
        @a = map { my $s = $_ * $n; $s; } @a;
        return @a;
    }
    my @r = @{ $a[0] };
    my @b = ();
    foreach my $i ( 0 .. $#a ) {
        my @row = ();
        foreach my $j ( 0 .. $#r ) { my $x = $a[$i][$j]; push @row, $x * $n; }
        push @b, \@row;
    }
    @b;
}

sub trsf {    ##S矩阵转置transferE##
    my @a = @{ $_[0] };
    my @s = size( \@a );
    if ( !$s[1] ) { @a = ( [@a] ); }
    my @r   = @{ $a[0] };
    my @res = map {
        my @tmp = ();
        foreach my $j ( 0 .. $#a ) { push @tmp, @{ $a[$j] }[$_]; }
        \@tmp;
    } 0 .. $#r;
    @res;
}

sub mmul {    ##S矩阵乘法matrixmultiplyE##
    our @a  = @{ $_[0] };
    our @b  = @{ $_[1] };
    our @s1 = size( \@a );
    our @s2 = size( \@b );
    if ( ( !$s1[1] ) && ( !$s2[1] ) ) {
        return map { $_ = $a[$_] * $b[$_] } 0 .. min( $#a, $#b );
    }
    elsif ( !$s1[1] ) { return nmu( $a[0], \@b ); }
    elsif ( !$s2[1] ) { return nmu( $b[0], \@a ); }
    my @result = ();
    if ( $s1[1] == $s2[0] ) {
        foreach my $i ( 0 .. $s1[0] - 1 ) {
            my @r   = @{ $a[$i] };
            my @tmp = ();
            foreach my $j ( 0 .. $s2[1] - 1 ) {
                my $x = 0;
                foreach my $k ( 0 .. $s1[1] - 1 ) {
                    $x += $r[$k] * ( @{ $b[$k] }[$j] );
                }
                $x = abs($x) < 9 * 10**-15 ? 0 : $x;
                push @tmp, $x;
            }
            push @result, \@tmp;
        }
        @result;
    }
    else {
        print RED"Error: 前矩阵的列数不等于后矩阵的行数, 无法相乘。\n";
        return ( "err", );
    }
}

sub det {    ##Sdetermination行列式E##
    my @a    = @{ $_[0] };
    my @size = size( \@a );
    if ( $size[0] == $size[1] ) {
        my @p = permutations( $size[0] );
        my ( $res, $t, $f ) = ( 0, 1, 1 );
        foreach my $i ( 0 .. $#p ) {
            $f = ( invernum( $p[$i] ) % 2 ) == 0 ? 1 : -1;
            foreach my $j ( 0 .. $size[0] - 1 ) {
                my @r = @{ $a[$j] };
                my $y = $p[$i][$j];
                $t *= $r[ $y - 1 ];
            }
            $res += $f * $t;
            $t = $f = 1;
        }
        $res;
    }
    else {
        print RED"Error: 只有方阵才能求行列式!\n";
        return "err";
    }
}

sub inv {    ##S矩阵的逆inverseE##
    my @a    = @{ $_[0] };
    my @size = size( \@a );
    if ( $size[0] == $size[1] && $size[0] > 1 ) {
        my $det = det( \@a );
        if ($det) {
            my @tmparr = ();
            foreach my $i ( 0 .. $size[0] - 1 ) {
                my @row = ();
                foreach my $j ( 0 .. $size[0] - 1 ) {
                    my @cofactor = @a;
                    splice( @cofactor, $i, 1 );
                    @cofactor = map { my @a = @{$_}; splice( @a, $j, 1 ); \@a; }
                      @cofactor;
                    my $flag = ( $i + $j ) % 2 == 0 ? 1 : -1;
                    push @row, $flag * det( \@cofactor );
                }
                push @tmparr, \@row;
            }
            my @trsfed = trsf( \@tmparr );
            @tmparr = nmu( 1 / $det, \@trsfed );
            @tmparr;
        }
        else {
            print RED"Error: 只有行列式不为0的方阵才有逆矩阵！\n";
            return 0;
        }
    }
    elsif ( $size[0] == $size[1] && $size[0] == 1 ) {
        my $x   = 1 / ( $a[0][0] );
        my @res = ( [$x] );
    }
    else {
        print RED"Error: 只有方阵才有逆矩阵!\n";
        return ( "err", );
    }
}

sub rowreduce {    ##S行简化E##
    my @matr = @{ $_[0] };
    my $mode = $_[1] ? $_[1] : "0";
    my @size = size( \@matr );
    my $det  = 1;
    my $flag = $size[0] == $size[1] ? 1 : 0;
    my @a    = ();
    foreach my $i ( 0 .. $size[0] - 1 ) {
        my @row = @{ $matr[$i] };
        if ( $mode eq "inv" && $flag ) {
            foreach my $j ( 0 .. $size[1] - 1 ) {
                $i == $j ? ( push @row, 1 ) : ( push @row, 0 );
            }
        }
        push @a, \@row;
    }
    ##S 添加单位矩阵 E##
    if ( $mode eq "det" && !$flag ) {
        print RED"Error: 方形矩阵才能计算行列式\n";
        return "err";
    }
    elsif ( $mode eq "inv" && !$flag ) {
        print RED"Error: 方形矩阵才有逆矩阵\n";
        return "err";
    }
    foreach my $i ( 0 .. $size[0] - 1 ) {
        my ( $n, $f ) = ( $i, $i );    ##S首非零行$n，首非零元$f E##
        while ( $f < $size[1] ) {
            while ( @{ $a[$n] }[$f] == 0 ) {
                $n++;
                last if $n == $size[0];
            }
            last if $n != $size[0];
            $f++;
            $n = $i;
        }
        last if $f == $size[1];
        my @base = @{ $a[$n] };
        if ( $n != $i ) {
            $a[$n] = $a[$i];
            $a[$i] = \@base;
            $det *= -1;
            print BLUE (
                "row(" . ( $i + 1 ) . ") <-> row(" . ( $n + 1 ) . ")\n" )
              if $PROCESS;
            prtmatrix( \@a )                   if $PROCESS;
            print GREEN"交换两行，行列式变号，det=$det\n" if $PROCESS && $mode eq 'det';
        }    ##S以上：若第$i行的第$i个数为0，则向下找非零的，并两者交换位置,每换一次，det变号，如果全是0向右看下一列。E##
        my $divisor = $base[$f];
        $det *= $divisor;
        @{ $a[$i] } =
          map { abs($_) < 10**-13 ? 0 : $_ / $divisor }
          @base
          ; # 由于浮点数计算的误差，绝对值小于10^-13的值均当做0看，否则会出现一个原来为0的数，由于浮点数计算产生的误差不为0，除以它本身后放大为1，计算差之毫厘，结果谬以千里
        @base = @{ $a[$i] };
        if ( $PROCESS && $divisor != 1 ) {
            print BLUE ( "row(" . ( $i + 1 ) . ") / $divisor\n" );
            prtmatrix( \@a );
            print GREEN"某一行同乘除，行列式也同乘除，det=$det\n" if $mode eq 'det';
        }
        if ( $i < $#a ) {
            foreach my $j ( $i + 1 .. $#a ) {
                my @tmp = @{ $a[$j] };
                next if $tmp[$f] == 0;
                print BLUE "row("
                  . ( $j + 1 )
                  . ") - row("
                  . ( $i + 1 )
                  . ")*$tmp[$f]\n"
                  if $PROCESS;
                @tmp = map { $tmp[$_] - $base[$_] * $tmp[$f] } 0 .. $#tmp;
                ##S注意size[1]和每一行的长度是不一样的，如果定义了mode=inv求转置的话，后面会跟一个单位阵E##
                $a[$j] = \@tmp;
                prtmatrix( \@a ) if $PROCESS;
            }
        }
    }
    if ( $mode ne "det" ) {
        foreach my $i ( numarr( $size[0] - 1, 0 ) ) {
            my @base = @{ $a[$i] };
            my $f    = indexof( 1, \@base );
            next if $f == -1;
            ##S因为上面的步骤中已经将所有行的首非零元变为了1，所以这一行只要有非零元则第一个必是1，否则这一行全是0，不可能找到1E##
            foreach my $j ( numarr( $i - 1, -1 ) ) {
                my @tmp = @{ $a[$j] };
                next if $tmp[$f] == 0;
                print BLUE "row("
                  . ( $j + 1 )
                  . ")-row("
                  . ( $i + 1 )
                  . ")*$tmp[$f]\n"
                  if $PROCESS;
                @tmp = map { $tmp[$_] - $base[$_] * $tmp[$f] } 0 .. $#tmp;
                $a[$j] = \@tmp;
                prtmatrix( \@a ) if $PROCESS;
            }
        }
    }
    foreach ( 0 .. min( $size[0], $size[1] ) - 1 ) {
        $det *= ( $a[$_]->[$_] );
    }
    if ($mode) {
        if ( $mode eq 'inv' ) {
            if ( $det != 0 ) {
                my @res = map {
                    my @row = @{$_};
                    @row = reverse map { pop @row; } $size[1] .. $#row;
                    \@row;
                } @a;
                @res;
            }
            else { print RED "Error: 该方阵的行列式为0，逆矩阵不存在！\n"; return "err"; }
        }
        elsif ( $mode eq 'det' ) { $det; }
    }
    else { @a; }
}

sub rank {    ##S求矩阵的秩 通过调用rowreduce来simplify E##
    my @a = @{ $_[0] };
    @a = rowreduce( \@a );
    my $r = 0;
    foreach my $i ( 0 .. $#a ) {
        my @row = @{ $a[$i] };
        foreach my $j ( 0 .. $#row ) {
            if ( $row[$j] != 0 ) {
                $r++;
                last;
            }
        }
        last if $i == $#row;
    }
    $r;
}

sub invernum {    ##S逆序数E##
    my @a = @{ $_[0] };
    my $t = 0;
    foreach my $i ( 1 .. $#a ) {
        my $n = 0;
        foreach my $j ( 0 .. $i - 1 ) {
            $n = $a[$j] > $a[$i] ? $n + 1 : $n;
        }
        $t += $n;
    }
    $t;
}

sub inrow {    ##S输入矩阵中的一行E##
    my $n = $_[0];
    my $i = substr( <>, 0, -1 );
    while (1) {
        $i = quit() if $i eq "";
        last        if $i eq ">exit";
        $i =~ s/， */,/g;
        $i =~ s/ +/ /g;
        $i =~ s/ +$//;
        $i =~ s/\t/,/g;
        $i =~ s/(\d) (-?\d)/$1,$2/g;
        $i =~ s/^ *,/0,/;
        $i =~ s/(\d) (-?\d)/$1,$2/g;
        $i =~ s/, ?,/,0,/g;
        $i =~ s/, ?,/,0,/g;
        $i =~ s/,$/,0/;

        # print "i=$i\n";
        if ( $i =~ /^(([\-\.0-9 \+\-\*\/\%]+,)+)?[\-\.0-9\+\-\*\/\%]+$/ ) {
            last;
        }
        else {
            print RED"输入有误, 请重新输入\n";
            $i = substr( <>, 0, -1 );
        }
    }
    $i = quit()         if $i eq "";
    return ( ">exit", ) if $i eq ">exit";
    $i = '$arr = [' . $i . "];";
    my $arr;
    eval($i);
    @$arr;
}

sub prtfmt
{ ##S printformatted格式化输出,prtfmt("|+|{样式}内容|+|","全局样式",可选"正则表达式 样式"), 注意正则表达式将会截断原来的分隔。例如：prtfmt("{b&y}|+|head|+|{c&ol}middle|+|footer\n",'g','e r');E##
    my ( $str, $presty ) = @_;
    foreach my $i ( 2 .. $#_ ) {
        my @ss = split( ' ', $_[$i] );
        $str =~ s/($ss[0])/|+|{$ss[1]}$1|+|/g;
    }
    if ( $str !~ /\|\+\|\{/ && !$presty ) {
        print "$str";
        return 1;
    }
    $str =~ s/(\|\+\|\{[^\}]+\})/$1\|\+\|/g;
    my @arr = split( /\|\+\|/, $str );
    my $n   = 0;
    while ( $n < @arr ) {
        my ( $x, $stystr, $flag ) = ( $arr[$n], '', 1 );
        $stystr = $presty . '&' if $presty;
        if ( $x =~ /^\{[a-z\&]+\}$/ ) {
            $stystr .= $x;
            $stystr =~ s/\{|\}//g;
            $flag = 2;
        }
        my $out = $arr[ $n + $flag - 1 ];
        if ( $stystr ne '' ) {
            my @styarr = split( '&', $stystr );
            my @sty    = map {
                next if $_ =~ /^ *$/;
                my $s = $STYLE{$_};
                $s if $s;
            } @styarr;
            print colored( [@sty], $out );
        }
        else { print $out; }
        $n += $flag;
    }
}

sub numarr {    ##E生成数组E##
    my ( $s, $e, $m ) = @_;
    if ( !$m ) {
        $m = $e > $s ? 1 : -1;
    }
    my @arr = ();
    my $n   = abs( ( $e - $s ) / $m );
    foreach my $i ( 0 .. $n - 1 ) {
        $arr[$i] = $s + $i * $m;
    }
    @arr;
}

sub debugnum {
    my $n = @_ - 1;
    croak "Error: 目标参数个数 $_[0],传入参数个数 $n .\n" if $n != $_[0];
    1;
}
sub debugtype {
    my $type = type( $_[1] );
    print RED "Error: 目标参数类型 $_[0],传入参数类型 $type\n" if $type ne $_[0];
    1;
}

sub type {    ##S判断变量类型E##
    my $type = "";
    my $m    = ref( $_[0] );
    if ( $m eq "" ) {
        if    ( $_[0] =~ /^-?\d+$/ )      { $type = "INT" }
        elsif ( $_[0] =~ /^-?\d+\.\d+$/ ) { $type = "NUM" }
        elsif ( $_[0] =~ /[^0-9]/ )       { $type = "STR" }
    }
    $type eq "" ? $m : $type;
}

sub sort {    ##S数字大小和其他字符的ASCII代码大小 E##
    if ( $a =~ /^-?[0-9\.]+$/ && $b =~ /^-?[0-9\.]+$/ ) { $a <=> $b }
    else                                                { $a cmp $b; }
}

sub indexof {    ##S数组、字符串索引，注意无法区分数字和带引号的数字E##
    my $q = $_[0];
    my @a = ref( $_[1] ) eq "ARRAY" ? @{ $_[1] } : split( "", $_[1] );
    $_[2]||= '';
    $_[3]||= '';
    my $s   = ( $_[2] =~ /^-?[1-9][0-9]*$/ ) ? $_[2] : 0;
    my @arr = $s >= 0 ? ( $s .. $#a ) : numarr( $#a + $s + 1, -1 );
    foreach my $i (@arr) {
        if ( $_[2] eq "false" || $_[3] eq "false" ) {
            return $i if ( $a[$i] =~ /$q/ );
        }
        else { return $i if ( $q eq $a[$i] ); }
    }
    -1;
}

sub tonum {    ##S字符串转化为数值E##
    my @a = split( "", $_[0] );
    my $i = 0;
    while ( $i < @a ) {
        last if ( $a[$i] =~ /[^\-\.0-9]/ );
        $i++;
    }
    my $res = substr( $_[0], 0, $i );
    $res = "" ? 0 : $res;
}

sub quit {
    print YELLOW "再次Enter确认退出或重新输入上一个参数:  ";
    my $ysn = substr( <>, 0, -1 );
    $ysn eq ""
      ? return ">exit"
      : return $ysn;
}

sub max {
    my @arr = sort { $a <=> $b } (@_);
    $arr[$#arr];
}

sub min {
    my @arr = sort { $a <=> $b } (@_);
    $arr[0];
}

sub sum {
    my $sum = 0;
    foreach (@_) { $sum += $_; }
    $sum;
}

sub avr { sum(@_) / @_; }

sub mul {
    my $result = 1;
    foreach (@_) { $result *= $_; }
    $result;
}

sub round {    ##S取近似值，四舍五入E##
    my $s = shift;
    my $i = floor($s);
    $s - $i > 0.5 ? $i + 1 : $i;
}

sub decomp {
    debugnum( 1, @_ );
    debugtype( "INT", $_[0] );
    my ( $x, @times ) = ( int( $_[0] ), () );
    my $y = $x;
    # 从全局变量质数表中遍历质数
    foreach my $i ( 0 .. $#PRIME ) {
        last if $x < $PRIME[$i];
        $y = $x;
        my $t = -1;
        while ( int($y) == $y ) {
            $y = $y / $PRIME[$i];
            $t++;
        }
        $times[$i] = $t;
    }
    @times;
}

sub reduce {    ##S约分化简E##
    debugnum( 2, @_ );
    debugtype( "INT", $_[0] );
    debugtype( "INT", $_[1] );
    my ( $zi, $mu ) = @_;
    my @x = decomp($zi);
    my @y = decomp($mu);
    my ( $max, $t, $top ) = ( max( $zi, $mu ), 0, min( $#x, $#y ) );
    for my $i ( 0 .. $top ) {
        last if $max < $PRIME[$i];
        my ( $zit, $mut ) = ( $x[$i], $y[$i] );
        $t = min( $zit, $mut );
        while ( $t > 0 ) {
            ( $zi, $mu ) = ( $zi / $PRIME[$i], $mu / $PRIME[$i] );
            $t--;
        }
    }
    return ( $zi, $mu );
}

sub getprime {    ##S获取质数E##
    my $n     = $_[0];
    my @prime = (2);
    my ( $flag, $p) = ( 1, 0 );
    my $format = '%2d Elapsed: %8t %20b %4p %2d';
    my $ctr =
      Term::Sk->new( $format, { freq => 1000, base => 0, target => $n } )
      if $TERM_SK;
    foreach my $i ( 3 .. $n ) {
        $flag = 1;
        $ctr->up if $TERM_SK;
        $p = sqrt($i);
        foreach my $j ( 0 .. $#prime ) {
            if ( $i % $prime[$j] == 0 ) {
                $flag = 0;
                last;
            }elsif($prime[$j]>$p){last;}
        }
        push @prime, $i if $flag == 1;
    }
    $ctr->close if $TERM_SK;
    @prime;
}

sub tofrac {    ##S小数化分数E##
    debugnum( 1, @_ );
    my ( $x, @res ) = ( sprintf( "%.15f", $_[0] * 1 ), () );
    $x = substr( $x, 0, -1 );
    if ( int($x) == $x || abs($x) < 9 * 10**-15 ) {
        @res = abs($x) < 9 * 10**-15 ? ( 0, 1 ) : ( $_[0], 1 );
    }
    else {
        my $neg = 0;
        ( $x, $neg ) = ( -$x, 1 ) if $x < 0;
        my $dot = index( $x, "." );
        my ( $zs, $xs ) = ( substr( $x, 0, $dot ), substr( $x, $dot + 1 ) );
        $xs .= "0" x ( 15 - length($xs) );
        if ( ( $x * 10**12 - $x * 10**5 ) == 0 ) {
            my ( $zi, $mu ) = ( $x * ( 10**5 ), 10**5 );
            @res = reduce( $zi, $mu );
        }
        else {
            my ( $power, $t, $repetition ) = ( 0, 0, 0 );
            foreach my $i ( 0 .. 9 ) {
                my ( $flag, $ind ) = ( 1, $i );
                foreach my $j ( 1 .. 6 ) {
                    my ( $n, $tmp ) = ( 0, substr( $xs, $i, $j ) );
                    $flag = 1;
                    while ( $ind < 13 - $j && $flag == 1 ) {
                        $ind += $j;
                        $n++;
                        $flag = ( substr( $xs, $ind, $j ) eq $tmp ) ? 1 : 0;
                    }
                    if ( $flag == 1 ) {
                        ( $power, $t, $repetition ) = ( $i, $n, $tmp );
                        last;
                    }
                    $ind = $i;
                }
                last if ( $flag == 1 );
            }
            my $js  = $x * ( 10**$power );
            my $bjs = $js * ( 10**length($repetition) );
            my ( $zi, $mu ) = (
                floor($bjs) - floor($js),
                10**( length($repetition) + $power ) - 10**$power
            );
            @res = reduce( $zi, $mu );
        }
        $res[0] *= -1 if $neg;
        $x      *= -1 if $neg;
    }
    push @res, $res[0] / $res[1] - $x;
    @res;
}

sub gene {
    print BOLD YELLOW "欢迎使用基因,获取帮助输入help\n";
    print BOLD RED "(输入0或Enter的内容以退出)\n";
    print BOLD BLUE "1.中心法则 2.碱基频率 3.基因的相似度 4.基因的比较 5.基因的存入\n";
    my $option = 1;
    while ( $option ne "0" ) {
        print BOLD YELLOW "选择功能:";
        $option = first_array( typegene( substr( <>, 0, -1 ) ) );
        last if ( $option eq "0" );
        if    ( $option eq "help" ) { prtfmt( $HELP{3}, 'g' ); }
        elsif ( $option eq "1" )    { chain_chain(); }
        elsif ( $option eq "2" )    { chain_currenty(); }
        elsif ( $option eq "3" )    { chains_similarity(); }
        elsif ( $option eq "4" )    { chains_diffenice(); }
        elsif ( $option eq "5" )    { chains_in(); }
        else                        { print RED "请输入合理的参数\n"; }
    }
}

sub typegene {
    my @output = ( $_[0], "Error" );
    if ( $_[0] =~ m/^[AUCG]+$/ )                { $output[1] = "RNA"; }
    if ( $_[0] =~ m/^(我就知道你会看的~HAH)?[ATCG]+$/ ) { $output[1] = "DNA"; }
    if ( $_[0] =~ m/^\-?[0-9]+$/ )              { $output[1] = "data"; }
    if ( $_[0] =~ m/^[1-5]$/ )                  { $output[1] = "1_5"; }
    if ( $_[0] =~ m/^$/ ) {
        print YELLOW "确认返回(Enter)或重新输入参数: ";
        $output[0] = substr( <>, 0, -1 );
        $output[0] = "0" if ( $output[0] eq '' );
    }
    if ( $_[0] =~ m/^gene[\d]+$/ ) { $output[0] = chains_out( $_[0] ); }
    return @output;
}
sub first_array { return shift @_; }
sub last_array  { return $_[$#_]; }
our @output_chains = ();
our $i_chains;
our $x_chains;

sub chains {
    @output_chains = ();
    $i_chains      = 0;
    $x_chains      = ( $#_ + 1 ) / 2;
    chain(@_);
    return @output_chains if ( @output_chains == $x_chains );
    return "0"            if ( @output_chains != $x_chains );
}

sub chain {
    while ( @output_chains != $x_chains ) {
        print GREEN $_[$i_chains];
        my $input = first_array( typegene( substr( <>, 0, -1 ) ) );
        last if ( $input eq "0" );
        if ( my $x =
            belongs_to( last_array( typegene($input) ), $_[ $i_chains + 1 ] )
            eq "0" )
        {
            print RED "输入错误\n";
            next;
        }
        $output_chains[ $i_chains / 2 ] = $input;
        $i_chains += 2;
        chain(@_);
    }
    $i_chains -= 2;
}

sub belongs_to {
    my $i = 0;
    foreach my $type ( split( '-', $_[1] ) ) {
        $i++ if ( $type eq $_[0] );
    }
    return "0" if ( $i == 0 );
    return "1" if ( $i > 0 );
}

sub chains_in {
    my @number_chains = ('');
    while ( $number_chains[0] ne "0" ) {
        @number_chains = chains( "输入编码:", "data-1_5", "输入DNA链:", "DNA" );
        last if ( $number_chains[0] eq "0" );
        $chains{"gene$number_chains[0]"} = $number_chains[1];
        print CYAN "gene$number_chains[0]已保存\n";
    }
    print GREEN "是否需要查看已存入的基因?Enter以继续";
    if ( <> eq "\n" ) {
        foreach my $key_chains ( keys(%chains) ) {
            print CYAN "$key_chains\t";
        }
        print "\n";
        my $key = 1;
        while ( $key ne "0" ) {
            $key = first_array( chains( "输入索引:", "DNA" ) );
            last if ( $key eq "0" );
            my $value = first_array( typegene($key) );
            print CYAN "$value\n";
        }
    }
}

sub chains_out {
    my $i = 0;
    foreach my $key ( keys(%chains) ) {
        if ( $key eq $_[0] ) { $i++ }
    }
    if   ( $i == 1 ) { return $chains{ $_[0] }; }
    else             { return $_[0]; }
}

sub chain_chain {
    my @begin_chain = ( 0, 1, 0 );
    while ( $begin_chain[1] ne "0" ) {
        $begin_chain[1] = first_array(
            chains( "原始链是: 1.编码链  2.模板链  3.mRNA链  4.蛋白质链  5.密码子序列", "1_5" ) );
        last if ( $begin_chain[1] eq "0" );
        if ( $begin_chain[1] eq "4" || $begin_chain[1] eq "5" ) {
            print YELLOW "不支持此类型\n";
            next;
        }
        $begin_chain[0] = first_array(
            chains( "输入原始链:", chain_chain_transform(@begin_chain) ) );
        while ( $begin_chain[0] ne "0" ) {
            $begin_chain[2] = first_array( chains( "转化为:", "1_5" ) );
            last if ( $begin_chain[2] eq "0" );
            chain_chain_transform(@begin_chain);
        }
    }
}

sub chain_chain_transform {
    if ( $_[1] eq "1" ) {
        chain_chain_1(@_);
        return "DNA";
    }
    if ( $_[1] eq "2" ) {
        my $chain1 = dna_dna( $_[0] );
        chain_chain_1( $chain1, $_[1], $_[2] );
        return "DNA";
    }
    if ( $_[1] eq "3" ) {
        my $chain1 = rna_dna( $_[0] );
        chain_chain_1( $chain1, $_[1], $_[2] );
        return "RNA";
    }
}

sub chain_chain_1 {
    my @name_chain = ( 0, "编码链", "模板链", "mRNA链", "蛋白质链", "密码子序列" );
    my $new        = $_[0];
    if ( $_[2] eq "2" ) { $new = dna_dna( $_[0] ); }
    if ( $_[2] eq "3" ) { $new = dna_rna( $_[0] ); }
    if ( $_[2] eq "4" ) { $new = _protein( dna_( $_[0] ) ); }
    if ( $_[2] eq "5" ) { $new = dna_( $_[0] ); }
    if ( $_[2] ne "0" ) {
        print YELLOW "$name_chain[$_[1]] 转换为 $name_chain[$_[2]] 的结果:\n";
        print CYAN "$new\n";
    }
}

sub dna_dna {
    my $i = $_[0];
    $i =~ s/A/m/g;
    $i =~ s/C/n/g;
    $i =~ s/T/A/g;
    $i =~ s/G/C/g;
    $i =~ s/m/T/g;
    $i =~ s/n/G/g;
    return $i;
}

sub dna_rna {
    my $i = $_[0];
    $i =~ s/T/U/g;
    return $i;
}

sub rna_dna {
    my $i = $_[0];
    $i =~ s/U/T/g;
    return $i;
}

sub dna_ {
    my @codon = ();
    for ( my $x = 0 ; $x <= length( $_[0] ) - 3 ; $x += 3 ) {
        my $co = substr( $_[0], $x, 3 );
        push @codon, $co;
    }
    return my $i = join( ' ', @codon );
}
our %protein_mRNA = (
    "TTT", "苯丙氨酸",  "ATT", "异亮氨酸",     "CTT", " 亮氨酸 ",
    "GTT", " 缬氨酸 ", "TTC", "苯丙氨酸",     "ATC", "异亮氨酸",
    "CTC", " 亮氨酸 ", "GTC", " 缬氨酸 ",    "TTA", " 亮氨酸 ",
    "ATA", "异亮氨酸",  "CTA", " 亮氨酸 ",    "GTA", " 缬氨酸 ",
    "TTG", " 亮氨酸 ", "ATG", "甲硫氨酸",     "CTG", " 亮氨酸 ",
    "GCT", " 丙氨酸 ", "TCT", " 丝氨酸 ",    "ACT", " 苏氨酸 ",
    "CCT", " 脯氨酸 ", "GCC", " 丙氨酸 ",    "TCC", " 丝氨酸 ",
    "ACC", " 苏氨酸 ", "CCC", " 脯氨酸 ",    "GAT", "天冬氨酸",
    "TCA", " 丝氨酸 ", "ACA", " 苏氨酸 ",    "CCA", " 脯氨酸 ",
    "GAC", "天冬氨酸",  "TCG", " 丝氨酸 ",    "ACG", " 苏氨酸 ",
    "CCG", " 脯氨酸 ", "GAA", " 谷氨酸 ",    "TAT", " 酪氨酸 ",
    "AAT", "天冬酰胺",  "CAT", " 组氨酸 ",    "GGT", " 甘氨酸 ",
    "TAC", " 酪氨酸 ", "AAC", "天冬酰胺",     "CAC", " 组氨酸 ",
    "GGC", " 甘氨酸 ", "TAA", "        ", "AAA", " 赖氨酸 ",
    "CAA", "谷氨酰胺",  "GCA", " 丙氨酸 ",    "TAG", "        ",
    "AAG", " 赖氨酸 ", "CAG", "谷氨酰胺",     "GCG", " 丙氨酸 ",
    "TGT", "半胱氨酸",  "AGT", " 丝氨酸 ",    "CGT", " 精氨酸 ",
    "GTG", " 缬氨酸 ", "TGC", "半胱氨酸",     "AGC", " 丝氨酸 ",
    "CGC", " 精氨酸 ", "GAG", " 谷氨酸 ",    "TGA", "        ",
    "AGA", " 精氨酸 ", "CGA", " 精氨酸 ",    "GGG", " 甘氨酸 ",
    "TGG", " 色氨酸 ", "AGG", " 精氨酸 ",    "CGG", " 精氨酸 ",
    "GGA", " 甘氨酸 ",
);

sub _protein {
    my @protein = split( ' ', $_[0] );
    for ( my $x = 0 ; $x <= $#protein ; $x++ ) {
        $protein[$x] = $protein_mRNA{ $protein[$x] };
    }
    return my $pro = join( '-', @protein );
}

sub chain_currenty {
    my @chain_part = ( 1, 0 );
    while ( $chain_part[0] ne "0" ) {
        $chain_part[0] = first_array( chains( "基因:", "DNA" ) );
        while ( $chain_part[0] ne "0" ) {
            $chain_part[1] = last_array( chains( "核苷酸片段:", "DNA" ) );
            last if ( $chain_part[1] eq "0" );
            my $i = 0;
            for ( my $x = 0 ; $x < length( $chain_part[0] ) ; $x++ ) {
                if ( $chain_part[1] eq
                    substr( $chain_part[0], $x, length( $chain_part[1] ) ) )
                {
                    $i++;
                }
            }
            my $current =
              $i / ( length( $chain_part[0] ) - length( $chain_part[1] ) + 1 );
            print CYAN "频率是:$current\t$i\n";
        }
    }
}

sub chains_similarity {
    my @chains = ( 1, 0 );
    while ( $chains[0] ne "0" ) {
        @chains = chains( "输入两条链\n", "DNA", "", "DNA" );
        last if ( $chains[0] eq "0" );
        @chains = chains_array(@chains);
        my @similaritys = ();
        my $i           = 0;
        while ( $i < ( $chains[2] - $chains[3] ) ) {
            my $ii         = 0;
            my $similarity = 0;
            while ( $ii < $chains[3] ) {
                $similarity++
                  if (
                    substr( $chains[0], $i, 1 ) eq substr( $chains[1], $ii, 1 )
                  );
                $ii++;
                $i++;
            }
            push @similaritys, $similarity;
            $i = $i - $chains[3] + 1;
        }
        my @out    = sort sort (@similaritys);
        my $output = ( $out[$#out] / $chains[2] ) * 100;
        print CYAN "相似度: $output %\n";
    }
}

sub chains_array {
    my @chain_array = @_;
    if ( length( $_[1] ) > length( $_[0] ) ) {
        $chain_array[0] = $_[1];
        $chain_array[1] = $_[0];
    }
    $chain_array[2] = length( $chain_array[0] );
    $chain_array[3] = length( $chain_array[1] );
    return @chain_array;
}

sub chains_diffenice {
    my @chains = ( 1, 0 );
    while ( $chains[0] ne "0" ) {
        @chains = chains( "两条链\n", "DNA", "", "DNA" );
        last if ( $chains[0] eq "0" );
        @chains = chains_array(@chains);
        my $chain_1 = $chains[0];
        my $chain_2 = $chains[1] . " " x ( $chains[2] - $chains[3] );
        my $move    = -1;
        while ( $move ne ' ' ) {
            $move = chain_move( "偏移量(空格退出):", $move );
            last if ( $move eq ' ' );
            if ( $move eq "Error" ) {
                print RED "输入错误\n";
                next;
            }
            chain_print( $chain_1, $chain_2, $move );
        }
    }
}

sub chain_move {
    print GREEN $_[0];
    my $input  = <>;
    my $output = $_[1];
    if    ( $input eq "\n" )            { $output++; }
    elsif ( $input eq "\t\n" )          { $output--; }
    elsif ( $input eq " \n" )           { $output = " "; }
    elsif ( $input =~ m/^\-?[\d]+\n$/ ) { $output = $input; }
    else                                { $output = "Error"; }
    return $output;
}

sub chain_print {
    my @c1 = split( '', $_[0] );
    my @c2 = split( '', $_[1] );
    my $i  = $_[2] * 1;
    if ( $i < 0 ) {
        do { unshift @c1, ' '; push @c2, ' '; $i++ } until ( $i == 0 );
    }
    if ( $i > 0 ) {
        do { unshift @c2, ' '; push @c1, ' '; $i-- } until ( $i == 0 );
    }
    my $x = 0;
    $i = 0;
    print YELLOW "A链: ";
    while ( $i <= $#c1 ) {
        print CYAN $c1[$i] if ( $c1[$i] eq $c2[$i] );
        print $c1[$i]      if ( $c1[$i] ne $c2[$i] );
        $i++;
    }
    print "\n";
    $i = 0;
    print YELLOW "B链: ";
    while ( $i <= $#c1 ) {
        print CYAN $c2[$i] if ( $c1[$i] eq $c2[$i] );
        print $c2[$i]      if ( $c1[$i] ne $c2[$i] );
        $i++;
    }
    print "\n";
}
init() if $o_t ne "1";

sub C1 {
    my ($res,$sup,$sub) = (1,@_); # 结果，C的上标，下标
    my ($zi,$mu) = (1,1);
    foreach (1..$sup) {
        $zi*=$sub;
        $sub--;
    }
    foreach (1..$sup){
        $mu*=$sup;
        $sup--;
    }
    return reduce($zi,$mu);
}

sub B {
    my ($n,$p)=@_;
    my @P = ();
    my $fp = 1-$p;
    my ($zi,$mu)=tofrac($p);
        my $pxmu = $mu**$n;
    foreach (0..$n){
        my @c = C1($_,$n);
        my $pxzi = $c[0]*($zi**$_)*(($mu-$zi)**($n-$_));
        my @x = reduce($pxzi,$pxmu*$c[1]);
        push @P,\@x;
    }
    @P; # 返回n=0,1,2,3...对应的 ([zi,mu],[zi,mu],[zi,mu]) 概率是以分数形式保存的
}
sub prtcode {
    my ( $r, $out ) = ( ref $_[0], "" );
    if ( $r eq '' && defined $_[0] ) {
        $out = $_[0] =~ /^-?\d+(\.\d+)?$/ ? $_[0] : "'$_[0]'";
    }
    elsif ( $r eq 'ARRAY' ) {
        my @arr = @{ $_[0] };
        foreach my $i (@arr) {
            $out .= ( prtcode($i) . "," );
        }
        $out = "[" . substr( $out, 0, -1 ) . "]";
    }
    elsif ( $r eq "HASH" ) {
        my %hash = %{ $_[0] };
        foreach ( sort keys %hash ) {
            $out .= ( "'$_'," . prtcode( $hash{$_} ) . "," );
        }
        $out = "{" . substr( $out, 0, -1 ) . "}";
    }
    else {
        $out = "''";
    }
    $out;
}