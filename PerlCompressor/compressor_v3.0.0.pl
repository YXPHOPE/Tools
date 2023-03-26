# This is a simple code compressor for perl.
# Module (.pm) is supported from version v2.0.0.
# Usage: perl compressor.pl "target.pl"
use strict;
use warnings;
use utf8;
our ( $DEBUG, $FORCE, $VERSION ) = ( 0, 0, '3.0.0', );    # 调试开关DEBUG=0,1,2; $FORCE=0,1
print "## Perl script compressor v$VERSION powered by YXP. ##\n";
# 符号匹配（需要转义，因为差不多是原句放入模式匹配中）;  _ 未被当做符号，因为其可以与英文连接构成变量名
our $SP  = '[`~!@#\$%^&\*\(\)\-=\+\[\{\]\}\\\|;:",<\.>\/\? \n\t]'; # 单引号未包括因为function'something'总是出错
our $SPM = '[ ~=\+\-\*\/\.>,\?;\&\|\^%\!]';
our %CODE = (
    'code' => 1,
    'commrnt' => 1,
    'pod' => 1,
);
# 为防止在查错模拟运行时重新定义函数，故特意将函数名特殊化，但变量不需要，因为不会真的执行
sub Ma_iN {
    # 参数设置
    my $filename = '';
    for(@ARGV){
        if(m/^-\?$/ || m/^-h$/ || m/^\-\-help$/){
            print("Used for compressing perl script file.\nOptions(All optional):\n    -f|F|--force   # force compressing\n    -?|-h|--help   # help info\n    \"filenameORfilepath.pl\"  # .pl/.pm file \n    code|comment|pod    # choose which content should be compressed\n    -d|D|--debug   # enable debug");
            return;
        }
        elsif(/^--?debug$/ || /^-?d$/ || /^D$/){$DEBUG = 1; }
        elsif(/^--?force$/||/^-?f$/||/^F$/){$FORCE = 1; }
        elsif(/^.*\.[pP][lmLM]$/){$filename=$_;}
        elsif(/^code$/ || /^comment$/ || /^pod$/){
            $CODE{'code'} = $CODE{'comment'} = $CODE{'pod'} = 0;
            $CODE{$_} = 1;
        }
    }

    print "## Debug is enabled. ##\n" if $DEBUG;
    print "## Force is enabled. ##\n" if $FORCE;
    # 检查给定文件
    if($filename && !-e $filename){print("## $filename does't exist!\n");}
    if ( !$filename || !-e $filename) {
        my @files = glob("*.pl");
        push @files,glob("*.pm");
        if ( @files == 0 ) {
            print "## This floder doesn't contain any .pl/.pm file.\n## Please 1. change to the proper directory\n          2. attach a filename or path argv at the command line.\n";
            return;
        }
        else {
            print "## Please choose a file you wanna compress (number only):\n";
            use POSIX;
            my ( $dec, $out ) = int( log10( $#files + 1 ) ) + 2;
            foreach ( 1 .. @files ) {
                $out .= sprintf( "%-" . $dec . "d", $_ ) . " $files[$_-1]\n";
            }
            print $out;    # 下面的输入只能用标准输入STDIN防止从参数里读取数据
            my $n = substr( <STDIN>, 0, -1 );
            if ( $n =~ /^\d+$/ && $n > 0 && $n <= @files ) {
                $filename = $files[ $n - 1 ];
                print "## $filename choosed. ##\n";
            }
            else {
                print "## Exit!\n";
                return 0;
            }
        }
    }
    open( my $in, "<$filename" )
      or do { print "Can't open $filename: $!"; return 0; };
    my $DAT = join( "", <$in> );
    close($in);
    my $length_ori = length($DAT);

    # 检测代码块是否有语法错误，放在新函数中（防执行），只检查语法错误
    print "## Checking syntax error ...\n";
    my $res = eval( "sub FuNc {\n" . $DAT . "\n};return '>0<';" ); # \n换行防止开门杀（尽管没有），结尾杀（末尾行注释、pod文档）
    print "## Done. ##\n";
    if ( !defined $res || $res ne ">0<" || $@ ne "" ) {
        $@ =~ s/\(eval \d+\)/$filename/g;
        print
          "## $filename has these sytax error below, please fix them first:\n$@"
          . "## Fix them and try again. ##\n";
        print "## Maybe just a bracket or a quotation is left out. ##\n"
          if $@ =~ /too many errors/;
        if ( !$FORCE ) {
            print "## Still wanna try to compress $filename?(1|0)  ";
            my $y = substr( <STDIN>, 0, -1 ); # 设置参数后就必须用具体的STDIN
            if ( $y ne '1' ) {
                print "## Exit!";
                return 0;
            }
        }
    }
    $filename =~ s/\.p([lm])$/.min.p$1/;
    open( my $out, ">$filename" );
    print "## Compressing file ...\n";
    my $min = Com_Pre_ssoR( Com_Pre_ssoR($DAT) ); # 压缩两遍，以防止漏网之鱼
    print "## Done. ##\n";
    my $length_fin = length($min);
    print $out $min;
    close($out);
    my $diff = $length_ori - $length_fin;
    print
"## $length_ori -> $length_fin , $diff char are reduced, compression ratio is "
      . sprintf( "%.2f%%", $length_fin * 100 / $length_ori ) . " ##\n";
    print "## File has been minified, please check in $filename. ##\n";
}

sub Com_Pre_ssoR {
    my $DAT = shift;

    # 预删除行首注释代码, 目前仅支持#类注释，包括后面(v1.0.0)(v2以后支持了pod)
    $DAT =~ s/^[ \n\t]+//;            # 删去开头的空白
    $DAT =~ s/\n[ \t\n]*#.*\n/\n/g;   # 注意此处的预删除会使第一遍中的字符顺序对不上

    # q{} qq{} qx{} qw{} m{} qr{} s{}{} tr{}{} y{}{}
    my @DA = split( "", $DAT );
    push @DA,' ';

    my ( $quote, $backslash, $blank, $level ) =
      ( 0, 0, 0, 0 );    # 单引1 双引2 /3 (4 {5 反引3
    my $status = 1;

# c1 代码块 cm2注释块 str3 单引纯文本 inqu4 双引插值块 double5 二分符q//这种 three6三分符s///这种 p7 poddocu
    my @statusCom =
      qw[0 code comment singlequote' doublequote" twoquote// threequote/// poddoc];
    my $pre = 0;         # 前一个输出内容，比较以去重复
    my $x;
    foreach my $i ( 0 .. $#DA-1 ) {
        $x = $DA[$i];
        # 判断反斜杠转义
        if ($backslash) { $backslash = 0, next; }
        else {
            # 判断当前块模式
            $pre = $status;
            if ( $status == 1 ) {    # 代码块
                if    ( $x eq "" ) { next; }
                elsif ( $x =~ /[ \t\n]/ ) {    # 删除代码块中的空字符
                    if ( $DA[ $i - 1 ] =~ /$SP/ || $DA[ $i + 1 ] =~ /$SP/ ) {
                        $DA[$i] = "";          # 如果前后有一个为符号，则这个空格可以删去
                        if ( $x eq "\n" && $DA[ $i + 1 ] eq '=' ) {
                            $status       = 7;
                            $DA[$i]       = "";
                            $DA[ $i + 1 ] = "";
                        }
                    }
                    elsif ( $x eq "\n" ) {
                        $DA[$i] = " ";
                    }
                }
                elsif ( $x eq "#" && $DA[ $i - 1 ] ne '$' ) {
                    $DA[$i] = "";
                    $status = 2;
                }
                elsif ( $x =~ /['`]/ ) { $status = 3; $quote = $x; }
                elsif ( $x eq '"' )    { $status = 4; $quote = $x; }
                elsif ( $x =~ /[qxwmrsy]/ ) {
                    my $s = $DA[ $i - 2 ] . $DA[ $i - 1 ] . $x . $DA[ $i + 1 ];
                    if ( $s =~ /^$SPM?([qm]|(qq)|(qx)|(qw)|(qr))$SP/ ) {
                        $status = 5;    # 此处可能会产生小bug，因为上面的模式匹配
                    }    # 简单二分符
                    elsif ($s =~ /$SPM[sy]$SP/
                        || $s =~ /^$SPM?(tr)$SP/ )
                    {    # 单个的s或y，前面有两个字符（也可能是空格被替换后的无），所以只要保证它前一个字符不是字母数字下划线即可
                        $status = 6;
                    }    # 三分符
                }
                elsif ( $x eq "/" ) {    # 可能省略m的匹配，二分符，也可能是除号
                    my $n = $i - 1;
                    while (1) {
                        if ( $DA[$n] =~ /[=~\(]/ )
                        {                # 作为匹配的斜杠前面只能是=~或者(//)或者=（使用$_）
                            $status = 5;
                            $quote  = $x;
                            last;
                        }
                        elsif ( $DA[$n] =~ /^ ?$/ ) { $n-- }     # 空格或者被去的空字符
                        else                        { last; }    # 遇到其他则表示除法，退出
                    }
                }

                # 转义只在 引号内、模式内失效，在代码块表示地址引用，不能跳过
            }
            elsif ( $status == 2 ) {    # 注释块
                $DA[$i] = '';
                if ( $x eq "\n" ) {
                    $status = 1;
                    $status = 7 if $DA[ $i + 1 ] eq '=';
                }                       # 遇到换行注释块结束，恢复代码块
            }
            elsif ( $status == 3 ) {
                if    ( $x eq "\\" ) { $backslash = 1 }
                elsif ( $x eq $quote ) {
                    $status = 1;
                    $quote  = undef;
                }                       # 在非反斜杠的该引号下，单引结束，恢复代码块
            }
            elsif ( $status == 4 ) {
                if    ( $x eq "\\" ) { $backslash = 1 }
                elsif ( $x eq $quote ) {
                    $status = 1;
                    $quote  = undef;
                }    # 在非反斜杠的双引号下，双引结束，恢复代码块【和上面不同的是这里以后可能做变量名替换】
            }
            elsif ( $status == 5 ) {    # 二分符
                if    ( $x eq "\\" ) { $backslash = 1 }
                elsif ( defined $quote ) {
                    if ($level) {
                        if    ( $x eq $quote ) { $level++; }
                        elsif ( $x eq Mat_Ch($quote) ) {
                            $level--;
                            if ( !$level ) { $status = 1; $quote = undef; }
                        }
                    }
                    elsif ( $x eq $quote ) { $status = 1; $quote = undef; }
                }
                else {
                    if ( $x =~ /[ \t]/ ) {
                        $DA[$i] = "" if ( $DA[ $i + 1 ] =~ /$SP/ );
                        $blank = 1;
                    }
                    elsif ( $x =~ /[\(\{<\[]/ ) { $quote = $x; $level = 1; }
                    elsif ( $x =~ /[a-zA-Z0-9]/ && $blank )     { $quote = $x; }
                    elsif ( $x =~ /[`~!@\$%^&*-_+=|;'",\.\?]/ ) { $quote = $x; }
                }
            }
            elsif ( $status == 6 ) {    # 三分段找到结尾就跳出，其他一律不更改
                if    ( $x eq "\\" ) { $backslash = 1 }
                elsif ( defined $quote ) {
                    if ( $level > 0 ) {
                        if ( $x eq Mat_Ch($quote) ) {
                            $level--;
                            if ( !$level ) { $status = 1; $quote = undef; }
                        }
                    }
                    elsif ( $x eq $quote ) {
                        $level++;
                        if ( !$level ) { $status = 1; $quote = undef; }
                    }
                }
                else {
                    if ( $x =~ /[ \t]/ ) {
                        $DA[$i] = "" if ( $DA[ $i + 1 ] =~ /$SP/ );
                    }    # 下一步中直接换成与之匹配的右括号
                    elsif ( $x =~ /[\(\{<\[]/ ) { $quote = $x; $level = 2; }
                    elsif ( $x =~ /[a-zA-Z0-9`~!@\$%^&*-_+=|;'",\.\?\/]/ )
                    {    # 在设为6时已验证空格存在
                        $quote = $x;    # 只要有空格，字母数字均可当分割
                        $level = -2;
                    }
                }
            }
            elsif ( $status == 7 ) {
                if ( $x eq "\n" && $DA[ $i + 1 ] eq '=' ) {
                    if (
                        (
                               $DA[ $i + 2 ] eq 'e'
                            && $DA[ $i + 3 ] eq 'n'
                            && $DA[ $i + 4 ] eq 'd'
                        )               #end由于encodeing需要3位全匹配
                        || ( $DA[ $i + 2 ] eq 'c' )    # cut 只需一位c就能确定是cut
                      )
                    {
                        $status = 2;
                    }
                }
                $DA[$i] = '';
            }
        }
        if ($DEBUG) {
            if ( $status != $pre ) {
                if    ( $x eq "\n" ) { $x = '\n'; }
                elsif ( $x eq " " )  { $x = 'space'; }
                elsif ( $x eq "\t" ) { $x = '\t' }
                print "#$i-$x-$status$statusCom[$status]\n";
            }
            print "#$i='$x'->'$DA[$i]','$DA[$i-1]','$DA[$i+1]'\n"
              if $DEBUG == 2 && $x ne $DA[$i];
        }
    }
    pop @DA; # 删除开始时往后面添加的空格
    my $res = join( "", @DA );

    # 善后工作
    $res =~
      s/print\$([^\$]+)\$/print\$$1 \$/g;  # print $filehandle $content 中间必须要有空格
    # $res =~ s/(use [^'";]+)'/$1 '/g; # use Module ''; Module与单引号'之间必须要有空格（双引号可以不用）
    # $res =~ s/(no [^'";]+)'/$1 '/g;  # 同上
    print $res if $DEBUG == 2;
    return $res;
}

sub Mat_Ch {
    my $x = shift;
    if    ( $x eq "(" ) { $x = ")" }
    elsif ( $x eq "[" ) { $x = "]" }
    elsif ( $x eq "{" ) { $x = "}" }
    elsif ( $x eq "<" ) { $x = ">" }
    return $x;
}

Ma_iN();