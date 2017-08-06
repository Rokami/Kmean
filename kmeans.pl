#!/usr/bin/perl
use Getopt::Std;
use vars qw($opt_k $opt_f $opt_n $opt_c $opt_h);
getopts('k:f:n:c:h');
$help="Usage:perl kmean.pl -k <num> -f <prefix.file> -n [num] -c [centroids.txt]
\t-k[int]:k-means number
\t-f<file>:data filename
\t-n[default:100]:maximun iteration number
\t-c[filename]:[optional] intital centroids filename
\t-h:this page\n";
if($opt_h||!$opt_f)
{
    print $help;
    exit 1;
}
open IN,$opt_f or die $!;
our @data=<IN>;
chomp @data;
$count=split(/\s+/,$data[0])-1;
close IN;
our @cluster;
if($opt_c)
{
    open IN,$opt_c or die $!;
    @cluster=<IN>;
    close IN;
}
elsif($opt_k)
{
    for $i(1..$opt_k)
    {
        push @cluster,$data[int rand($#data+1)];
    }
}
else
{
    print $help;
    exit 1;
}
chomp @cluster;
for $i(1..$#cluster+1)
{
    $list{$i}="";
}
$old_var=-1;
if(!$opt_n)
{
    $opt_n=100;
}
for $now(0..$opt_m-1)
{
    $label=&clusterOfelement($data[$now]);
    $list{$label}.=",$now";
    for $i(1..$#cluster+1)
    {
        @temp=split(/,/,$list{$i});
        shift @temp;
        $cluster[$i-1]=&getCluster(@temp,$i-1);
    }
    $new_var=&getVar(%list);
    $var=$new_var-$old_var;
    if($var eq 0)
    {
        $d=$now;
        last;
    }
    else
    {
        $old_var=$new_var;
    }
}
for $i($d..$#data)
{
    $label=&clusterOfelement($data[$i]);
    $list{$label}.=",$i";
}
for $i(1..$#cluster+1)
{
    @temp=split /,/,$list{$i};
    shift @temp;
    %hash=(%hash,(map{$_=>$i} @temp));

}
open OUT,">kmeans.out" or die $!;
foreach $key(sort{$a<=>$b} keys %hash)
{
    print OUT "$key\t$hash{$key}\n";
}
close OUT;
sub getDis
{
    $sum=0;
    @da=split(/\s+/,$_[0]);
    @db=split(/\s+/,$_[1]);
    while(@da)
    {
        $a=(shift @da)+0;
        $b=(shift @db)+0;
        $sum+=(($a)-($b))**2;
    }
    return sqrt($sum);
}
sub clusterOfelement
{
    $ele=shift;
    $lab=1;
    $dis=&getDis($cluster[0],$ele);
    for $i(1..$#cluster)
    {
        $temp=&getDis($cluster[$i],$ele);
        if($temp<$dis)
        {
            $lab=$i+1;
            $dis=$temp;
        }
    }
    return $lab;
}
sub getVar
{
    $var=0;
    %lab=@_;
    for $i(0..$#cluster)
    {
        @pos=split(/,/,$lab{$i+1});
        shift @pos;
        while(@pos)
        {
            $p=shift @pos;
            $var+=&getDis($cluster[$i],$data[$p]);
        }
    }
    return $var;
}
sub getCluster
{
    (@pos,$k)=@_;
    if(@pos)
    {
    for $i(0..$count)
    {
        $cent[$i]=0;
        for $j(0..$#pos)
        {
            $here=$pos[$j];
            @temp=split /\s/,$data[$here];
            $cent[$i]+=$temp[$i];
        }
    }
    for $i(0..$count)
    {
        $cent[$i]=$cent[$i]/($#pos+1);
    }
    $centroid=join "\t",@cent;
    return $centroid;
    }
    else
    {
        return $cluster[$k];
    }
}
