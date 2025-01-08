#!/usr/bin/env perl
use warnings;
use strict;
if (scalar(@ARGV) != 2) {
    die "Usage $0 SNV|indel|both nomulti|multi < headerlessvcf"
}
my $what = $ARGV[0];
my $multi = $ARGV[1];
my $nmulti = 0;
while (<STDIN>) {
    chomp;
    my @line = split("\t", $_);
    die "I expect a single sample vcf" if scalar(@line) != 10;
    my @l = split(':', $line[8]);
    #die "Wrong vcf FORMAT" if ($line[8] ne 'GT:AD:AF:DP:F1R2:F2R1:SB' && $line[8] ne 'GT:AD:DP:GQ:PL' && $line[8] ne 'GT:AD:AF:F1R2:F2R1:DP:SB:MB');
    #   TODO inefficient split only here...
    die "Wrong vcf FORMAT" if ($l[1] ne 'AD' || $l[2] ne 'AF');
    if ($line[4] =~ /,/) {
        if ($multi eq 'multi') {
            die "Sorry still to be implemented"; # probably will need to use a library for this
        }
        $nmulti++;
        next;     
    } else {
        &manage_entry($line[2], $line[3], $line[4], $line[9], $what, $line[0], $line[1]);
    }
}

sub manage_entry {
    my $id = shift;
    my $ref = shift;
    my $alt = shift;
    my $g = shift;
    my $what = shift;
    my $chr = shift;
    my $b = shift;
    $b = $b-1; #switch to zero based
    my $e = $b + length($ref); # end escluded considering length of ref, TODO FIXME for long indels
    #mutect:
    #GT:AD:AF:DP:F1R2:F2R1   0/1:14,4:0.235:18:7,2:7,2 
    ##FORMAT=<ID=AD,Number=R,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">
    ##FORMAT=<ID=AF,Number=A,Type=Float,Description="Allele fractions of alternate alleles in the tumor">
    ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Approximate read depth (reads with MQ=255 or with bad mates are filtered)">
    ##FORMAT=<ID=F1R2,Number=R,Type=Integer,Description="Count of reads in F1R2 pair orientation supporting each allele">
    ##FORMAT=<ID=F2R1,Number=R,Type=Integer,Description="Count of reads in F2R1 pair orientation supporting each allele">
    ##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
    ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
    #haplotypecaller:
    #GT:AD:DP:GQ:PL  0/1:365,53:486:99:132,0,7982
    ##FORMAT=<ID=AD,Number=R,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">
    ##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Approximate read depth (reads with MQ=255 or with bad mates are filtered)">
    ##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
    ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
    # both good
    if ($what eq 'SNV') {
        return if (length($ref) != 1 || length($alt) != 1);
    } elsif ($what eq 'indel') { 
        return if (length($ref) == 1 && length($alt) == 1);
    } # we do not check for both
    my @afs = split(':',$g);
    my @nreads = split(',',$afs[1]);
    $id = $id . ':' . $nreads[0] . ':' . $nreads[1] . ':' . $afs[2]; 
    print $chr . "\t" . $b . "\t" . $e . "\t" .  $id . "\n";
}


print STDERR "multiallelic\t$nmulti";
