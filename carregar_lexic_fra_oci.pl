#!/usr/bin/perl

# usage
# carregar_lexic.pl n|adj|adv|vblex|pr|cnjadv|top|antm|antf 0|1
# el segon argument indic si es generen paraules en català a partir dels fitxer d'en Jaume Ortolà
# (per defecte 0=no)

# En aquest programa es llegeix el fitxer amb 7 columnes separades per tabuladors amb paraules amb categories tancades
# 0. ocurrències
# 1. paraula francesa
# 2. categoria gramatical francesa
# 3. paraula occitana
# 4. categoria gramatical occitana
# 6. autor
# El programa genera 2 fitxers per carregar als 2 fitxers de diccionari

# Com hi ha força casos en què un mateix lema és antm i antf (també cog), els carrego per separat
# Això dóna certs maldecaps perquè en el fitxer d'entrada només tinc que són ant, sense especificació dels gènere

use strict;
use utf8;

my $MOT = 'cheval';	# paraula a debugar
my $MOT = 'Allemagne';	# paraula a debugar
my $MOT = 'Erik';	# paraula a debugar
my $MOT = 'Emily';	# paraula a debugar
my $MOT = '';

my $MORF_TRACT = $ARGV[0];
unless ($MORF_TRACT) {
	print "Error: $0 n|adj|adv|vblex|pr|cnjadv|top|antm|antf\n";
	exit 1;
}

#my $GEN_OCI = $ARGV[1];
my $GEN_OCI = 0;
#$GEN_OCI = 1 if $MORF_TRACT eq 'adv';
$GEN_OCI = 1 if $MORF_TRACT eq 'vblex';

my $AUTOR = 'capsot';

my ($ffra, $foci, $fbi, $flex, $fdixfra, $fdixoci, $fdixbi, $fdixfran, $fdixfraadj, $fdixfrav);

open($fdixfra, "../apertium-fra/apertium-fra.fra.metadix") || die "can't open apertium-fra.fra.metadix: $!";
open($fdixfran, "../apertium-fra/jaumeortola/fra-noun.txt") || die "can't open fra-noun.txt: $!";
open($fdixfraadj, "../apertium-fra/jaumeortola/fra-adj.txt") || die "can't open fra-adj.txt: $!";
open($fdixoci, "../apertium-oci/apertium-oci.oci.metadix") || die "can't open apertium-oci.oci.metadix: $!";
open($fdixfrav, "../apertium-fra/jaumeortola/infinitius-frances_tots.txt") || die "can't open infinitius-frances_tots.txt: $!";
open($fdixbi, "apertium-oci-fra.oci-fra.dix") || die "can't open apertium-oci-fra.oci-fra.dix: $!";

open($ffra, ">f_fra.dix.txt") || die "can't create f_fra.dix.txt: $!";
open($foci, ">f_oci.dix.txt") || die "can't create f_oci.dix.txt: $!";
open($fbi, ">f_bi.dix.txt") || die "can't create f_bi.dix.txt: $!";
open($flex, ">f_fra.lex.txt") || die "can't create f_fra.lex.dix: $!";	# llista de noves paraules fra per verificació ortogràfica

binmode(STDIN, ":encoding(UTF-8)");
binmode($fdixfra, ":encoding(UTF-8)");
binmode($fdixfran, ":encoding(UTF-8)");
binmode($fdixfraadj, ":encoding(UTF-8)");
binmode($fdixoci, ":encoding(UTF-8)");
binmode($fdixfrav, ":encoding(UTF-8)");
binmode($fdixbi, ":encoding(UTF-8)");
binmode($ffra, ":encoding(UTF-8)");
binmode($foci, ":encoding(UTF-8)");
binmode($fbi, ":encoding(UTF-8)");
binmode($flex, ":encoding(UTF-8)");
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

my %dix_fra = ();
my %dix_fra_prm = ();
my %dix_oci = ();
my %dix_oci_prm = ();
my %dix_frav = ();
my %dix_fran = ();
my %dix_fran_def = ();
my %dix_fraadj = ();
my %dix_fraadj_def = ();
my %dix_fra_oci = ();
my %dix_oci_fra = ();
my %variant_oci = ();


sub llegir_dix_ortola {
	my ($nfitx, $fitx, $r_struct, $r_struct2) = @_;
	my ($lemma, $par, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;

print "1. fitxer ortola $nfitx, $linia\n" if $MOT && $linia =~ /"$MOT"/o;
		if ($linia =~ m|<e lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} else {
print STDERR "Error en llegir_dix_ortola fitxer $nfitx, $linia\n";
			next;
		}
		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer ortola $nfitx, $linia, par=$par";
		}
print "2. fitxer ortola $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /"$MOT"/o;
		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'pr') {
			print STDERR "llegir_dix_ortola fitxer $nfitx, línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer ortola $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /"$MOT"/o;

		$r_struct->{$morf}{$lemma} = $par;
		$r_struct2->{$morf}{$lemma} = $linia;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
	}
print "4. fitxer ortola $nfitx r_struct->{$MORF_TRACT}{$MOT} = $r_struct->{$MORF_TRACT}{$MOT}\n";
}

sub llegir_verbs_dicollecte {
	my ($fitx, $r_struct) = @_;
	my ($lemma, $par, $morf);

	my $morf = 'vblex';
	while (my $linia = <$fitx>) {
		chop $linia;

print "10. llegir_verbs_dicollecte $linia\n" if $MOT && $linia =~ /$MOT/o;
		if ($linia =~ m|^([^"]*)\t([^"]*)$|o) {
			$par = $1;
			$lemma = $2;
		} else {
			print STDERR "Error en llegir_verbs_ortola l. $.: $linia\n";
			next;
		}
		$r_struct->{$morf}{$lemma} = $par;
print "10. r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
	}
}

# llegeixo el fitxer fra: n, adj, adv, pr, cnjadv, top, antm, antf
sub llegir_dix {
	my ($nfitx, $fitx, $r_struct, $r_struct_prm) = @_;
	my ($lemma, $par, $prm, $morf);

	while (my $linia = <$fitx>) {
		chop $linia;
		next if $linia =~ /r="LR"/o;
		next if $linia =~ /<!-- .*<e/o;

print "0. fitxer $nfitx, $linia\n" if $MOT && $linia =~ /"$MOT"/o;
next if $linia !~ /$MORF_TRACT/o && $MORF_TRACT ne 'top' && $MORF_TRACT ne 'antm' && $MORF_TRACT ne 'antf';
next if $linia !~ /np/o && ($MORF_TRACT eq 'top' || $MORF_TRACT eq 'antm'  || $MORF_TRACT eq 'antf');
next if $linia =~ /alt="oci.gascon"/o;
next if $linia =~ /alt="oci.aran"/o;

#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
#     <e lm="intégrer"><i>int</i><par n="accél/é[R]er__vblex" prm="gr"/></e>
#     <e lm="emprunt" a="joan"><i>emprunt</i><par n="livre__n"/></e>

print "1. fitxer $nfitx, $linia\n" if $MOT && $linia =~ /"$MOT"/o;
		$prm = '';
		if ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="([^"]*)" prm="([^"]*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
			$prm = $3;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<i>.*</i>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/></e>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)".*<p><l>.*</l>.*<par n="(.*)"/><p>|o) {
			$lemma = $1;
			$par = $2;
		} elsif ($linia =~ m|<e .*lm="([^"]*)">[^<]*<par n="(.*)"/></e>|o) {
#<e lm="ampli">           <par n="/ampli__adj"/></e>
			$lemma = $1;
			$par = $2;
		} else {
			next;
		}

		if ($par =~ /__(.*)$/o) {
			$morf = $1;
		} else {
			die "fitxer $nfitx, $linia, par=$par";
		}

		if ($morf eq 'np') {
			if ($nfitx eq 'fra') {
				if ($par eq 'Andorre__np' 
				|| $par eq 'Bulgarie__np' 
				|| $par eq 'Iran__np' 
				|| $par eq 'Bahamas__np' 
				|| $par eq 'États-Unis__np') {
					$morf = 'top'
				} elsif ($par eq 'Abraham__np' 
				|| $par eq 'Antoine__np') { 
					$morf = 'antm'
				} elsif ($par eq 'Abraham__np' 
				|| $par eq 'Marie__np') {
					$morf = 'antf'
				}
			} elsif ($nfitx eq 'oci') {
				if ($par eq 'Aran__np' 
				|| $par eq 'Bulgaria__np' 
				|| $par eq 'Iran__np' 
				|| $par eq 'Bahamas__np' 
				|| $par eq 'Estats_Units__np') {
					$morf = 'top'
				} elsif ($par eq 'Abad__np' 
				|| $par eq 'Antòni__np') {
					$morf = 'antm'
				} elsif ($par eq 'Abad__np' 
				|| $par eq 'Aitana__np') {
					$morf = 'antf'
				}
			}
		}

print "2.5. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /"$MOT"/o;
		if ($linia !~ m|r="LR"|o && $linia =~ m|alt="([^"]*)"|o) {
			my $variant = $1;
			$variant_oci{$morf}{$lemma}{$variant} = 1;
print "fitxer $nfitx, $linia, variant_oci{$morf}{$lemma}{$variant} = 1\n" if $MOT && $linia =~ /$MOT/o;
		} else {
print "fitxer $nfitx, $linia, variant_oci{$morf}{$lemma}{xxx} = 0\n" if $MOT && $linia =~ /$MOT/o;
print $linia, "\n" if $MOT && $linia =~ /$MOT/o;
		}

		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'pr' && $morf ne 
'cnjadv' && $morf ne 'top' && $morf ne 'antm' && $morf ne 'antf') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
print "3. fitxer $nfitx, $linia, par=$par, morf=$morf\n" if $MOT && $linia =~ /"$MOT"/o;
next if $morf ne $MORF_TRACT;

		if ($r_struct->{$morf}{$lemma} && $morf ne 'vblex') {
			print STDERR "Error llegir_dix $nfitx: lemma $lemma (morf = $morf, par = $par) ja definit com a morf = $morf, par = $r_struct->{$morf}{$lemma}\n"
				if $r_struct->{$morf}{$lemma} ne $par;
		} else {
			$r_struct->{$morf}{$lemma} = $par;
			$r_struct_prm->{$morf}{$lemma} = $prm if $prm;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $par =~ /vblex/o;
print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
print "r_struct_prm->{$morf}{$lemma} = $r_struct_prm->{$morf}{$lemma}\n" if $MOT && $lemma =~ /$MOT/o;
#print "r_struct->{$morf}{$lemma} = $r_struct->{$morf}{$lemma}\n";
		}
	}
print "4. fitxer $nfitx r_struct->{$MORF_TRACT}{$MOT} = $r_struct->{$MORF_TRACT}{$MOT}\n";
}

# llegeixo el fitxer bilingüe: n, adj, adv, cnjadv, pr, top, antm, antf
sub llegir_bidix {
	my ($fitx, $r_struct_rl, $r_struct_lr) = @_;
	my ($lemma_oci, $lemma_fra, $morf, $morf2, $dir);

#       <e><p><l>derrota<s n="n"/><s n="f"/></l><r>derrota<s n="n"/><s n="f"/></r></p></e>
#      <e><p><l>proper<s n="adj"/></l><r>imbeniente<s n="adj"/></r></p><par n="GD_mf"/></e>
#      <e r="LR"><p><l>aqueix<s n="prn"/><s n="tn"/></l><r>custu<s n="prn"/><s n="tn"/></r></p></e>
#      <e><p><l>pacient<s n="n"/></l><r>malàidu<s n="n"/></r></p><par n="mf_GD"/></e>
#      <e><p><l>arribar<g><b/>a</g><s n="vblex"/></l><r>arribare<g><b/>a</g><s n="vblex"/></r></p></e>
	while (my $linia = <$fitx>) {
next if $linia !~ /$MORF_TRACT/o;
next if $linia =~ /alt="oci.gascon"/o;
next if $linia =~ /alt="oci.aran"/o;
		next if $linia =~ / i="yes"/o;
		chop $linia;
		$linia =~ s|<b/>| |og;
		$linia =~ s|<g>|#|og;
		$linia =~ s|</g>||og;
print "1. fitxer bidix, $linia\n" if $MOT && $linia =~ />$MOT</o;

		if ($linia =~ m|<e> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e vr="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e alt="[^"]*".*> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_oci = $1;
			$morf = $2;
			$lemma_fra = $3;
			$dir = 'bi';
		} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" alt="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="LR"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e alt="[^"]*" r="LR".*> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="LR" alt="[^"]*".*> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_oci = $1;
			$morf = $2;
			$lemma_fra = $3;
			$dir = 'lr';
		} elsif ($linia =~ m|<e r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" c="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" a="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" alt="[^"]*"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e a="[^"]*" r="RL"> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e alt="[^"]*" r="RL".*> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o
			|| $linia =~ m|<e r="RL" alt="[^"]*".*> *<p><l>([^<]*)<s n="([^"]*)".*<r>([^<]*)<s|o) {
			$lemma_oci = $1;
			$morf = $2;
			$lemma_fra = $2;
			$dir = 'rl';
		} elsif ($linia =~ m|<e> *<p><l>([^<]*)</l> *<r>([^<]*)</r></p><par n="l-u-adj_l|o
			|| $linia =~ m|<e a=".*"> *<p><l>([^<]*)</l>.*<r>([^<]*)</r></p><par n="l-u-adj_l|o) {
			# <e><p><l>norma</l><r>normal</r></p><par n="l-u-adj_l"/></e>
			# <e a="wiktionnaire"><p><l>ventra</l><r>ventral</r></p><par n="l-u-adj_l"/></e>
			$lemma_oci = $1 . 'l';
			$morf = 'adj';
			$lemma_oci = $2;
			$dir = 'bi';
		} elsif ($linia =~ m|<e r="LR".*<p><l>([^<]*)</l> *<r>([^<]*)</r></p><par n="l-u-adj_l|o) {
			$lemma_oci = $1 . 'l';
			$morf = 'adj';
			$lemma_oci = $2;
			$dir = 'lr';
		} elsif ($linia =~ m|<e r="RL".*<p><l>([^<]*)</l> *<r>([^<]*)</r></p><par n="l-u-adj_l|o) {
			$lemma_oci = $1 . 'l';
			$morf = 'adj';
			$lemma_oci = $2;
			$dir = 'rl';
		} elsif ($linia =~ m|<e> *<p><l>([^<]*)</l> *<r>([^<]*)</r></p><par n="l-u-n_l|o
			|| $linia =~ m|<e a=".*"> *<p><l>([^<]*)</l>.*<r>([^<]*)</r></p><par n="l-u-n_l|o) {
			$lemma_oci = $1 . 'l';
			$morf = 'n';
			$lemma_oci = $2;
			$dir = 'bi';
		} elsif ($linia =~ m|<e r="LR".*<p><l>([^<]*)</l> *<r>([^<]*)</r></p><par n="l-u-n_l|o) {
			$lemma_oci = $1 . 'l';
			$morf = 'n';
			$lemma_oci = $2;
			$dir = 'lr';
		} elsif ($linia =~ m|<e r="RL".*<p><l>([^<]*)</l> *<r>([^<]*)</r></p><par n="l-u-n_l|o) {
			$lemma_oci = $1 . 'l';
			$morf = 'n';
			$lemma_oci = $2;
			$dir = 'rl';
		} elsif ($linia =~ m|<e|o && $. > 140) {
			print STDERR "Error lectura bidix en l. $.: $linia\n";
		} else {
			next;
		}

		if ($morf eq 'np') {
		if ($morf eq 'antm' || $morf eq 'antf') {
			if ($linia =~ m|<e> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e vr="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e alt="[^"]*".*> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e a="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o) {
				$lemma_oci = $1;
				$morf = 'ant' . $2;
				$lemma_fra = $3;
				$dir = 'bi';
			} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" c="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" a="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" alt="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e a="[^"]*" r="LR"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e alt="[^"]*" r="LR".*> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" alt="[^"]*".*> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o) {
				$lemma_oci = $1;
				$morf = 'ant' . $2;
				$lemma_fra = $3;
				$dir = 'lr';
			} elsif ($linia =~ m|<e r="RL"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" c="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" a="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" alt="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e a="[^"]*" r="RL"> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e alt="[^"]*" r="RL".*> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" alt="[^"]*".*> *<p><l>([^<]*)<s n="np"/><s n="ant"/><s n="([^"]*)".*<r>([^<]*)<s|o) {
				$lemma_oci = $1;
				$morf = 'ant' . $2;
				$lemma_fra = $2;
				$dir = 'rl';
			} elsif ($linia =~ m|<e|o && $. > 140) {
				print STDERR "Error lectura np bidix en l. $.: $linia\n";
			} else {
				next;
			}
		} else {
			if ($linia =~ m|<e> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e vr="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e alt="[^"]*".*> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e a="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o) {
				$lemma_oci = $1;
				$morf = $2;
				$lemma_fra = $3;
				$dir = 'bi';
			} elsif ($linia =~ m|<e r="LR"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" c="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" a="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" alt="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e a="[^"]*" r="LR"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e alt="[^"]*" r="LR".*> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="LR" alt="[^"]*".*> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o) {
				$lemma_oci = $1;
				$morf = $2;
				$lemma_fra = $3;
				$dir = 'lr';
			} elsif ($linia =~ m|<e r="RL"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" c="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" a="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" alt="[^"]*"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e a="[^"]*" r="RL"> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e alt="[^"]*" r="RL".*> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o
				|| $linia =~ m|<e r="RL" alt="[^"]*".*> *<p><l>([^<]*)<s n="np"/><s n="([^"]*)".*<r>([^<]*)<s|o) {
				$lemma_oci = $1;
				$morf = $2;
				$lemma_fra = $2;
				$dir = 'rl';
			} elsif ($linia =~ m|<e|o && $. > 140) {
				print STDERR "Error lectura np bidix en l. $.: $linia\n";
			} else {
				next;
			}
		}
		}

		if ($morf ne 'n' && $morf ne 'adj' && $morf ne 'adv' && $morf ne 'vblex' && $morf ne 'pr' && $morf ne 'cnjadv' && $morf ne 'top' && $morf ne 'antm' && $morf ne 'antf') {
#			print STDERR "línia $.: $linia - morf $morf\n";
			next;
		}
print "2.5. fitxer bidix, $linia, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;
next if $morf ne $MORF_TRACT;

print "3. fitxer bidix, $linia, morf=$morf\n" if $MOT && $linia =~ /$MOT/o;

		push @{$r_struct_rl->{$morf}{$lemma_fra}}, $lemma_oci if $dir eq 'bi' || $dir eq 'rl';
		push @{$r_struct_lr->{$morf}{$lemma_oci}}, $lemma_fra if $dir eq 'bi' || $dir eq 'lr';
#print "r_struct_rl->{$morf}{$lemma_fra}[$#{$r_struct_rl->{$morf}{$lemma_fra}}] = $r_struct_rl->{$morf}{$lemma_fra}[$#{$r_struct_rl->{$morf}{$lemma_fra}}]\n" if $MOT && $lemma_fra =~ /$MOT/o; si es decomenta, ha de ser nomës per a proves, sense carregar res (els 'exists' posteriors peten per culpa d'això)
#print "r_struct_lr->{$morf}{$lemma_oci}[$#{$r_struct_lr->{$morf}{$lemma_oci}}] = $r_struct_lr->{$morf}{$lemma_oci}[$#{$r_struct_lr->{$morf}{$lemma_oci}}]\n" if $MOT && $lemma_oci =~ /$MOT/o; si es decomenta, ha de ser nomës per a proves, sense carregar res (els 'exists' posteriors peten per culpa d'això)
	}
}

sub crear_g {
	my ($lemma_fra, $gram_fra) = @_;
#print "crear_g($lemma_fra, $gram_fra)\n";
	my ($cap, $cua);
#	couper# en morceux <vblex>
#     <e lm="crever les yeux"><p><l>cr</l><r>cr</r></p><par n="ach/e[T]er__vblex" prm="v"/><p><l><b/>les<b/>yeux</l><r><g><b/>les<b/>yeux</g></r></p></e>
	if ($lemma_fra =~ /#/o) {
		$cap = $`;
		$cua = $';
	} else {
		print STDERR "Error en crear_g($lemma_fra, $gram_fra)\n";
	}
	unless ($dix_fra{$gram_fra}{$cap}) {
		print STDERR "1. Falta fra $cap <$gram_fra> (0)\n";
		return 1;
	}
	$lemma_fra =~ s/#//o;
	$cua = " $cua";
	$cua =~ s/ +/ /og;
	$cua =~ s/ $//o;
	$cua =~ s/ /<b\/>/og;
	my $cua_par = $dix_fra{$gram_fra}{$cap};
	if ($cua_par =~ m|/|o) {
		$cua_par =~ s/__vblex$//o;
		$cua_par =~ s/__n$//o;
		$cua_par =~ s/^.*\///o;
		$cua_par =~ s/\[.*\]//o;
	} else {
		$cua_par = '';
	}
	my $lcua_par = length($cua_par) + length($dix_fra_prm{$gram_fra}{$cap});
	my $arrel = substr($cap, 0, length($cap)-$lcua_par);
#printf "$arrel, $cua_par, $lcua_par\n";
	if ($dix_fra_prm{$gram_fra}{$cap}) {
		printf $ffra "    <e lm=\"%s\"><p><l>%s</l><r>%s</r></p><par n=\"%s\" prm=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
			$lemma_fra, $arrel, $arrel, $dix_fra{$gram_fra}{$cap}, $dix_fra_prm{$gram_fra}{$cap}, $cua, $cua;
	} else {
		if ($lemma_fra =~ / à$/o) {
#    <e lm="consister à" r="LR"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/>à</l><r><g><b/>à</g></r></p></e>
#    <e lm="consister à" r="RL"><i>consist</i><par n="abaiss/er__vblex"/><p><l><b/><a/>à</l><r><g><b/>à</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/à$/<a\/>à/o;
			printf $ffra "    <e lm=\"%s\" r=\"LR\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua, $cua;
			printf $ffra "    <e lm=\"%s\" r=\"RL\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua2, $cua;
		} elsif ($lemma_fra =~ / de$/o) {
#    <e lm="convenir verbalement de" r="LR"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
#    <e lm="convenir verbalement de" r="RL"><i>conv</i><par n="appart/enir__vblex"/><p><l><b/>verbalement<b/><a/>de</l><r><g><b/>verbalement<b/>de</g></r></p></e>
			my $cua2 = $cua;
			$cua2 =~ s/de$/<a\/>de/o;
			printf $ffra "    <e lm=\"%s\" r=\"LR\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua, $cua;
			printf $ffra "    <e lm=\"%s\" r=\"RL\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua2, $cua;
		} else {
			printf $ffra "    <e lm=\"%s\"><i>%s</i><par n=\"%s\"/><p><l>%s</l><r><g>%s</g></r></p></e>\n",
				$lemma_fra, $arrel, $dix_fra{$gram_fra}{$cap}, $cua, $cua;
		}
	}
	return 0;
}

# retorna 0 ssi la cadena no és a la llista
sub is_in {
	my ($r_list, $string) = @_;

	foreach my $r (@$r_list) {
		return 1 if $r eq $string;
	}
	return 0;
}


sub escriure_mono_vblex {
	my ($lemma_fra) = @_;
	my $a = " a=\"automatique\"";

	if ($lemma_fra =~ /ger$/o) {
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'allong/er__vblex';
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /ayer$/o) {
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/yer$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'bala/yer__vblex';
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /oyer$/o) {
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/yer$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'côto/yer__vblex';
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /cer$/o) {
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/cer$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'annon/cer__vblex';
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /e(.)er$/o) {
		my $cons = $1;
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/e.er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /é(.)er$/o) {
		my $cons = $1;
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/é.er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'accél/é[R]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /echer$/o) {
		my $cons = 'ch';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/e..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /écher$/o) {
		my $cons = 'ch';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/é..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'accél/é[R]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /équer$/o) {
		#<e lm="hypothéquer"><i>hypoth</i><par n="accél/é[R]er__vblex" prm="qu"/></e>
		my $cons = 'qu';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/e..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /éguer$/o) {
		my $cons = 'gu';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/e..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /equer$/o) {
		my $cons = 'qu';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/e..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /equer$/o) {
		my $cons = 'qu';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/e..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'ach/e[T]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /écrer$/o) {
		my $cons = 'cr';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/é..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'accél/é[R]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /étrer$/o) {
		my $cons = 'tr';
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/é..er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\" prm=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'accél/é[R]er__vblex', $cons;
		printf $flex "$lemma_fra\n";
		return 1;
	} elsif ($lemma_fra =~ /[aiouyâêîôûï][bcdfghjklmnpqrstvwxz][bcdfghjklmnpqrstvwxz]*[i]*er$/o
		|| $lemma_fra =~ /[aiouyâêîôûï][gq]uer$/o
		|| $lemma_fra =~ /ouer$/o
		|| $lemma_fra =~ /[éiu]er$/o
		|| $lemma_fra =~ /er[lns]er$/o
		|| $lemma_fra =~ /eller$/o
		|| $lemma_fra =~ /effer$/o
		|| $lemma_fra =~ /errer$/o
		|| $lemma_fra =~ /enfler$/o
		|| $lemma_fra =~ /estrer$/o
		|| $lemma_fra =~ /e[cn]ter$/o
		|| $lemma_fra =~ /n[gq]uer$/o
		) {
		my $stem_fra = $lemma_fra;
		$stem_fra =~ s/er$//o;
		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'abaiss/er__vblex';
		printf $flex "$lemma_fra\n";
		return 1;
# No es pot posar "ir" automàticament perquè no sabem si és incoatiu (salir) o no (dormir)
#	} elsif ($lemma_fra =~ /ir$/o) {
#		my $stem_fra = $lemma_fra;
#		$stem_fra =~ s/er$//o;
#		printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'about/[]ir__vblex';
#		printf $flex "$lemma_fra\n";
#		return 1;
	} else {
		return 0;
	}
}


sub escriure_bidix_n {
	my ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran) = @_;
my $par_oci;

print "escriure_bidix_n ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran)\n" if $lemma_oci eq $MOT || $lemma_fra eq $MOT;
#print "escriure_bidix_n ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n" if $lemma_oci eq $MOT || $lemma_fra =~ /musique/o;
#print "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	my $par_fra = $dix_fra{$morf_fra}{$lemma_fra};
	if ($lemma_fra =~ /#/o) {
		my $x = $lemma_fra;
		$x =~ s/#//;
		$par_fra = $dix_fra{$morf_fra}{$x};
	}
	my $par_oci = $dix_oci{$morf_oci}{$lemma_oci};
	if ($lemma_oci =~ /#/o) {
		my $x = $lemma_oci;
		$x =~ s/#//;
		$par_oci = $dix_oci{$morf_oci}{$x};
	}
	my $a = " a=\"$autor\"" if $autor;
	my $alt = '';
	if ($var_oci) {
		$alt = " alt=\"oci\"";
	} elsif ($var_gascon) {
		$alt = " alt=\"oci\@gascon\"";
	} elsif ($var_aran) {
		$alt = " alt=\"oci\@aran\"";
	}
	if (($par_fra eq 'abeille__n' || $par_fra eq 'eau__n')
			&& ($par_oci eq 'jornad/a__n'
			|| $par_oci eq 'aig/ua__n'
			|| $par_oci eq 'aubèr/ja__n'
			|| $par_oci eq 'cro/tz__n'
			|| $par_oci eq 'hormig/a__n'
			|| $par_oci eq 'leng/ua__n'
			|| $par_oci eq 'mè/l__n'
			|| $par_oci eq 'parapluè/ja__n'
			|| $par_oci eq 'part__n'
			|| $par_oci eq 'seden/ça__n'
			|| $par_oci eq 'va/ca__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'abeille__n' || $par_fra eq 'eau__n')
			&& ($par_oci eq 'conselh__n'
			|| $par_oci eq 'autob/ús__n'
			|| $par_oci eq 'castè/l__n'
			|| $par_oci eq 'cè/l__n'
			|| $par_oci eq 'congr/és__n'
			|| $par_oci eq 'contrast__n'
			|| $par_oci eq 'dec/ès__n'
			|| $par_oci eq 'di/a__n'
			|| $par_oci eq 'env/às__n'
			|| $par_oci eq 'esb/òs__n'
			|| $par_oci eq 'mes__n'
			|| $par_oci eq 'pa/ís__n'
			|| $par_oci eq 'pas__n'
			|| $par_oci eq 'paragraf__n'
			|| $par_oci eq 'pè/l__n'
			|| $par_oci eq 'perm/ís__n'
			|| $par_oci eq 'persona/l__n'
			|| $par_oci eq 'prè/tz__n'
			|| $par_oci eq 'ris/c__n'
			|| $par_oci eq 'tap/ís__n'
			|| $par_oci eq 'tra/ç__n'
			|| $par_oci eq 'trasp/às__n'
			|| $par_oci eq 'succ/ès__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abeille__n' && $par_oci eq 'deluns__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abeille__n' && $par_oci eq 'vacances__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"pl_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abeille__n' && $par_oci eq 'epatiti__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abeille__n'
			&& ($par_oci eq 'personau__n' || $par_oci eq 'persona/l__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'livre__n'
			&& ($par_oci eq 'personau__n' || $par_oci eq 'persona/l__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abeille__n' && $par_oci eq 'deluns__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'admis__n' || $par_fra eq 'épou/x__n')
		&& ($par_oci eq 'conselhèr__n'
			|| $par_oci eq 'afilia/t__n'
			|| $par_oci eq 'alcalde__n'
			|| $par_oci eq 'ami/c__n'
			|| $par_oci eq 'ar/abi__n'
			|| $par_oci eq 'baron__n'
			|| $par_oci eq 'bas/c__n'
			|| $par_oci eq 'bau/g__n'
			|| $par_oci eq 'camparò/l__n'
			|| $par_oci eq 'can__n'
			|| $par_oci eq 'capitan/i__n'
			|| $par_oci eq 'compli/ce__n'
			|| $par_oci eq 'c/ònsol__n'
			|| $par_oci eq 'cosi/n__n'
			|| $par_oci eq 'dictat/or__n'
			|| $par_oci eq 'directi/u__n'
			|| $par_oci eq 'dramaturg__n'
			|| $par_oci eq 'emperair/e__n'
			|| $par_oci eq 'er/òi__n'
#			|| $par_oci eq 'espanhò/l__n'
			|| $par_oci eq 'esp/ós__n'
			|| $par_oci eq 'europè/u__n'
			|| $par_oci eq 'filosòf__n'
			|| $par_oci eq 'frai/r__n'
			|| $par_oci eq 'indiv/idu__n'
			|| $par_oci eq 'joen__n'
			|| $par_oci eq 'lo/p__n'
			|| $par_oci eq 'mandad/ís__n'
			|| $par_oci eq 'm/ètge__n'
			|| $par_oci eq 'ministr/e__n'
			|| $par_oci eq 'mon/ge__n'
			|| $par_oci eq 'Moss/o__n'
			|| $par_oci eq 'operado/r__n'
			|| $par_oci eq 'ors__n'
			|| $par_oci eq 'os__n'
			|| $par_oci eq 'pag/és__n'
			|| $par_oci eq 'po/èta__n'
			|| $par_oci eq 'presoniè/r__n'
			|| $par_oci eq 'propriet/ari__n'
			|| $par_oci eq 'rei__n'
			|| $par_oci eq 'sindi/c__n'
			|| $par_oci eq 'so/ís__n'
			|| $par_oci eq 'troba/dor__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"anglés_anglais\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'admis__n' || $par_fra eq 'épou/x__n')
			&& ($par_oci eq 'agent__n'
			|| $par_oci eq 'collèg/a__n'
			|| $par_oci eq 'guardi/a__n'
			|| $par_oci eq 'monar/ca__n'
			|| $par_oci eq 'pòrtavo/tz__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"anglais_esquimalXXXX\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'affecté__n'
			|| $par_fra eq 'administrat/eur__n'
			|| $par_fra eq 'aïeu/l__n'
			|| $par_fra eq 'ancien__n'
			|| $par_fra eq 'andalou__n'
			|| $par_fra eq 'bouch/er__n'
			|| $par_fra eq 'buffle__n'
			|| $par_fra eq 'causeu/r__n'
			|| $par_fra eq 'chat__n'
			|| $par_fra eq 'clown__n'
			|| $par_fra eq 'colonel__n'
			|| $par_fra eq 'commercia/l__n'
			|| $par_fra eq 'débit/eur__n'
			|| $par_fra eq 'jui/f__n'
			|| $par_fra eq 'maire__n'
			|| $par_fra eq 'po/ète__n'
			|| $par_fra eq 'support/er__n'
			|| $par_fra eq 'tur/c__n'
			|| $par_fra eq 'vende/ur__n')
		&& ($par_oci eq 'conselhèr__n'
			|| $par_oci eq 'afilia/t__n'
			|| $par_oci eq 'alcalde__n'
			|| $par_oci eq 'ami/c__n'
			|| $par_oci eq 'ar/abi__n'
			|| $par_oci eq 'baron__n'
			|| $par_oci eq 'bas/c__n'
			|| $par_oci eq 'bau/g__n'
			|| $par_oci eq 'camparò/l__n'
			|| $par_oci eq 'can__n'
			|| $par_oci eq 'capitan/i__n'
			|| $par_oci eq 'compli/ce__n'
			|| $par_oci eq 'c/ònsol__n'
			|| $par_oci eq 'cosi/n__n'
			|| $par_oci eq 'dictat/or__n'
			|| $par_oci eq 'directi/u__n'
			|| $par_oci eq 'dramaturg__n'
			|| $par_oci eq 'emperair/e__n'
			|| $par_oci eq 'er/òi__n'
#			|| $par_oci eq 'espanhò/l__n'
			|| $par_oci eq 'esp/ós__n'
			|| $par_oci eq 'europè/u__n'
			|| $par_oci eq 'filosòf__n'
			|| $par_oci eq 'frai/r__n'
			|| $par_oci eq 'indiv/idu__n'
			|| $par_oci eq 'joen__n'
			|| $par_oci eq 'lo/p__n'
			|| $par_oci eq 'mandad/ís__n'
			|| $par_oci eq 'm/ètge__n'
			|| $par_oci eq 'ministr/e__n'
			|| $par_oci eq 'mon/ge__n'
			|| $par_oci eq 'Moss/o__n'
			|| $par_oci eq 'operado/r__n'
			|| $par_oci eq 'ors__n'
			|| $par_oci eq 'os__n'
			|| $par_oci eq 'pag/és__n'
			|| $par_oci eq 'po/èta__n'
			|| $par_oci eq 'presoniè/r__n'
			|| $par_oci eq 'propriet/ari__n'
			|| $par_oci eq 'rei__n'
			|| $par_oci eq 'sindi/c__n'
			|| $par_oci eq 'so/ís__n'
			|| $par_oci eq 'troba/dor__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'affecté__n'
			|| $par_fra eq 'administrat/eur__n'
			|| $par_fra eq 'aïeu/l__n'
			|| $par_fra eq 'ancien__n'
			|| $par_fra eq 'andalou__n'
			|| $par_fra eq 'bouch/er__n'
			|| $par_fra eq 'buffle__n'
			|| $par_fra eq 'causeu/r__n'
			|| $par_fra eq 'chat__n'
			|| $par_fra eq 'clown__n'
			|| $par_fra eq 'colonel__n'
			|| $par_fra eq 'commercia/l__n'
			|| $par_fra eq 'débit/eur__n'
			|| $par_fra eq 'jui/f__n'
			|| $par_fra eq 'maire__n'
			|| $par_fra eq 'po/ète__n'
			|| $par_fra eq 'support/er__n'
			|| $par_fra eq 'tur/c__n'
			|| $par_fra eq 'vende/ur__n')
		&& $par_oci eq 'espanhò/l__n') {
		$stem_oci =~ s/l$//o;
		printf $fbi "<e$lr_rl$alt$a><p><l>%s</l><r>%s</r></p><par n=\"l-u-n_l\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'artiste__n' || $par_fra eq 'hébreu__n')
		&& $par_oci eq 'espanhò/l__n') {
		$stem_oci =~ s/l$//o;
		printf $fbi "<e$lr_rl$alt$a><p><l>%s</l><r>%s</r></p><par n=\"l-u-n_l2\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'affecté__n'
			|| $par_fra eq 'administrat/eur__n'
			|| $par_fra eq 'aïeu/l__n'
			|| $par_fra eq 'ancien__n'
			|| $par_fra eq 'andalou__n'
			|| $par_fra eq 'bouch/er__n'
			|| $par_fra eq 'buffle__n'
			|| $par_fra eq 'causeu/r__n'
			|| $par_fra eq 'chat__n'
			|| $par_fra eq 'clown__n'
			|| $par_fra eq 'colonel__n'
			|| $par_fra eq 'commercia/l__n'
			|| $par_fra eq 'débit/eur__n'
			|| $par_fra eq 'jui/f__n'
			|| $par_fra eq 'maire__n'
			|| $par_fra eq 'po/ète__n'
			|| $par_fra eq 'support/er__n'
			|| $par_fra eq 'tur/c__n'
			|| $par_fra eq 'vende/ur__n')
		&& ($par_oci eq 'agent__n'
			|| $par_oci eq 'collèg/a__n'
			|| $par_oci eq 'guardi/a__n'
			|| $par_oci eq 'monar/ca__n'
			|| $par_oci eq 'pòrtavo/tz__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'artiste__n' || $par_fra eq 'hébreu__n')
		&& ($par_oci eq 'agent__n'
			|| $par_oci eq 'collèg/a__n'
			|| $par_oci eq 'guardi/a__n'
			|| $par_oci eq 'monar/ca__n'
			|| $par_oci eq 'pòrtavo/tz__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'artiste__n' && $par_oci eq 'minjamosques__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'ex__n' && $par_oci eq 'minjamosques__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"mf\"/><s n=\"sp\"/></l><r>%s<s n=\"n\"/><s n=\"mf\"/><s n=\"sp\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'artiste__n' || $par_fra eq 'hébreu__n')
		&& ($par_oci eq 'conselhèr__n'
			|| $par_oci eq 'afilia/t__n'
			|| $par_oci eq 'alcalde__n'
			|| $par_oci eq 'ami/c__n'
			|| $par_oci eq 'ar/abi__n'
			|| $par_oci eq 'baron__n'
			|| $par_oci eq 'bas/c__n'
			|| $par_oci eq 'bau/g__n'
			|| $par_oci eq 'camparò/l__n'
			|| $par_oci eq 'can__n'
			|| $par_oci eq 'capitan/i__n'
			|| $par_oci eq 'compli/ce__n'
			|| $par_oci eq 'c/ònsol__n'
			|| $par_oci eq 'cosi/n__n'
			|| $par_oci eq 'dictat/or__n'
			|| $par_oci eq 'directi/u__n'
			|| $par_oci eq 'dramaturg__n'
			|| $par_oci eq 'emperair/e__n'
			|| $par_oci eq 'er/òi__n'
#			|| $par_oci eq 'espanhò/l__n'
			|| $par_oci eq 'esp/ós__n'
			|| $par_oci eq 'europè/u__n'
			|| $par_oci eq 'filosòf__n'
			|| $par_oci eq 'frai/r__n'
			|| $par_oci eq 'indiv/idu__n'
			|| $par_oci eq 'joen__n'
			|| $par_oci eq 'lo/p__n'
			|| $par_oci eq 'mandad/ís__n'
			|| $par_oci eq 'm/ètge__n'
			|| $par_oci eq 'ministr/e__n'
			|| $par_oci eq 'mon/ge__n'
			|| $par_oci eq 'Moss/o__n'
			|| $par_oci eq 'operado/r__n'
			|| $par_oci eq 'ors__n'
			|| $par_oci eq 'os__n'
			|| $par_oci eq 'pag/és__n'
			|| $par_oci eq 'po/èta__n'
			|| $par_oci eq 'presoniè/r__n'
			|| $par_oci eq 'propriet/ari__n'
			|| $par_oci eq 'rei__n'
			|| $par_oci eq 'sindi/c__n'
			|| $par_oci eq 'so/ís__n'
			|| $par_oci eq 'troba/dor__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/></l><r>%s<s n=\"n\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'livre__n'
		|| $par_fra eq 'brand/y__n'
		|| $par_fra eq 'cie/l__n'
		|| $par_fra eq 'latifundi/um__n'
		|| $par_fra eq 'lieu__n'
		|| $par_fra eq 'match__n'
		|| $par_fra eq 'trava/il__n'
		|| $par_fra eq 'vitra/il__n'
		|| $par_fra eq 'administrat/eur__n'	# molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'causeu/r__n' 		# molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'anima/l__n')
			&& ($par_oci eq 'conselh__n'
			|| $par_oci eq 'conselhèr__n'	# típicament per a llengües
			|| $par_oci eq 'presoniè/r__n'	# típicament per a aparells
			|| $par_oci eq 'autob/ús__n'
			|| $par_oci eq 'castè/l__n'
			|| $par_oci eq 'cè/l__n'
			|| $par_oci eq 'congr/és__n'
			|| $par_oci eq 'contrast__n'
			|| $par_oci eq 'dec/ès__n'
			|| $par_oci eq 'di/a__n'
			|| $par_oci eq 'env/às__n'
			|| $par_oci eq 'esb/òs__n'
			|| $par_oci eq 'mes__n'
			|| $par_oci eq 'pa/ís__n'
			|| $par_oci eq 'pas__n'
			|| $par_oci eq 'paragraf__n'
			|| $par_oci eq 'pè/l__n'
			|| $par_oci eq 'perm/ís__n'
			|| $par_oci eq 'persona/l__n'
			|| $par_oci eq 'prè/tz__n'
			|| $par_oci eq 'ris/c__n'
			|| $par_oci eq 'tap/ís__n'
			|| $par_oci eq 'tra/ç__n'
			|| $par_oci eq 'trasp/às__n'
			|| $par_oci eq 'succ/ès__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'livre__n'
		|| $par_fra eq 'brand/y__n'
		|| $par_fra eq 'cie/l__n'
		|| $par_fra eq 'latifundi/um__n'
		|| $par_fra eq 'lieu__n'
		|| $par_fra eq 'match__n'
		|| $par_fra eq 'trava/il__n'
		|| $par_fra eq 'vitra/il__n'
		|| $par_fra eq 'administrat/eur__n' # molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'anima/l__n')
			&& ($par_oci eq 'jornad/a__n'
			|| $par_oci eq 'aig/ua__n'
			|| $par_oci eq 'aubèr/ja__n'
			|| $par_oci eq 'cro/tz__n'
			|| $par_oci eq 'hormig/a__n'
			|| $par_oci eq 'leng/ua__n'
			|| $par_oci eq 'mè/l__n'
			|| $par_oci eq 'parapluè/ja__n'
			|| $par_oci eq 'part__n'
			|| $par_oci eq 'seden/ça__n'
			|| $par_oci eq 'va/ca__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'livre__n'
		|| $par_fra eq 'brand/y__n'
		|| $par_fra eq 'cie/l__n'
		|| $par_fra eq 'latifundi/um__n'
		|| $par_fra eq 'lieu__n'
		|| $par_fra eq 'match__n'
		|| $par_fra eq 'trava/il__n'
		|| $par_fra eq 'vitra/il__n'
		|| $par_fra eq 'administrat/eur__n'	# molts casos d'ús d'administrat/eur__n per a aparells
#		|| $par_fra eq 'causeu/r__n' 		# molts casos d'ús d'administrat/eur__n per a aparells
		|| $par_fra eq 'anima/l__n')
			&& $par_oci eq 'deluns__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'livre__n' && $par_oci eq 'epatiti__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"sp_ND\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'mois__n' && $par_oci eq 'deluns__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'argent__n' || $par_fra eq 'personnel__n')
			&& ($par_oci eq 'personau__n' || $par_oci eq 'persona/l__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'argent__n' || $par_fra eq 'personnel__n')
			&& $par_oci eq 'set__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'soif__n'
			&& $par_oci eq 'set__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'mois__n'
			&& ($par_oci eq 'conselh__n'
			|| $par_oci eq 'autob/ús__n'
			|| $par_oci eq 'castè/l__n'
			|| $par_oci eq 'cè/l__n'
			|| $par_oci eq 'congr/és__n'
			|| $par_oci eq 'contrast__n'
			|| $par_oci eq 'dec/ès__n'
			|| $par_oci eq 'di/a__n'
			|| $par_oci eq 'env/às__n'
			|| $par_oci eq 'esb/òs__n'
			|| $par_oci eq 'mes__n'
			|| $par_oci eq 'pa/ís__n'
			|| $par_oci eq 'pas__n'
			|| $par_oci eq 'paragraf__n'
			|| $par_oci eq 'pè/l__n'
			|| $par_oci eq 'perm/ís__n'
			|| $par_oci eq 'persona/l__n'
			|| $par_oci eq 'prè/tz__n'
			|| $par_oci eq 'ris/c__n'
			|| $par_oci eq 'tap/ís__n'
			|| $par_oci eq 'tra/ç__n'
			|| $par_oci eq 'trasp/às__n'
			|| $par_oci eq 'succ/ès__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'mois__n'
			&& ($par_oci eq 'jornad/a__n'
			|| $par_oci eq 'aig/ua__n'
			|| $par_oci eq 'aubèr/ja__n'
			|| $par_oci eq 'cro/tz__n'
			|| $par_oci eq 'hormig/a__n'
			|| $par_oci eq 'leng/ua__n'
			|| $par_oci eq 'mè/l__n'
			|| $par_oci eq 'parapluè/ja__n'
			|| $par_oci eq 'part__n'
			|| $par_oci eq 'seden/ça__n'
			|| $par_oci eq 'va/ca__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'fois__n' && $par_oci eq 'epatiti__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'fois__n'
			&& ($par_oci eq 'jornad/a__n'
			|| $par_oci eq 'aig/ua__n'
			|| $par_oci eq 'aubèr/ja__n'
			|| $par_oci eq 'cro/tz__n'
			|| $par_oci eq 'hormig/a__n'
			|| $par_oci eq 'leng/ua__n'
			|| $par_oci eq 'mè/l__n'
			|| $par_oci eq 'parapluè/ja__n'
			|| $par_oci eq 'part__n'
			|| $par_oci eq 'seden/ça__n'
			|| $par_oci eq 'va/ca__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'fois__n'
			&& ($par_oci eq 'conselh__n'
			|| $par_oci eq 'autob/ús__n'
			|| $par_oci eq 'castè/l__n'
			|| $par_oci eq 'cè/l__n'
			|| $par_oci eq 'congr/és__n'
			|| $par_oci eq 'contrast__n'
			|| $par_oci eq 'dec/ès__n'
			|| $par_oci eq 'di/a__n'
			|| $par_oci eq 'env/às__n'
			|| $par_oci eq 'esb/òs__n'
			|| $par_oci eq 'mes__n'
			|| $par_oci eq 'pa/ís__n'
			|| $par_oci eq 'pas__n'
			|| $par_oci eq 'paragraf__n'
			|| $par_oci eq 'pè/l__n'
			|| $par_oci eq 'perm/ís__n'
			|| $par_oci eq 'persona/l__n'
			|| $par_oci eq 'prè/tz__n'
			|| $par_oci eq 'ris/c__n'
			|| $par_oci eq 'tap/ís__n'
			|| $par_oci eq 'tra/ç__n'
			|| $par_oci eq 'trasp/às__n'
			|| $par_oci eq 'succ/ès__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/></r></p><par n=\"ND_sp\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'personnel_n'
			&& ($par_oci eq 'personau__n' || $par_oci eq 'persona/l__n')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abords__n' && $par_oci eq 'entorns__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'abords__n'&& $par_oci eq 'vacances__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'vacances__n' && $par_oci eq 'entorns__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'vacances__n'&& $par_oci eq 'vacances__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"n\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'BBVA__n' && $par_oci eq 'BBVA__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'BBVA__n' && $par_oci eq 'IRPF__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'IRPF__n' && $par_oci eq 'IRPF__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'IRPF__n' && $par_oci eq 'BBVA__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"m\"/><s n=\"sp\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'BBC__n' && $par_oci eq 'BBC__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"f\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'ATS__n' && $par_oci eq 'ATS__n') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"mf\"/></l><r>%s<s n=\"n\"/><s n=\"acr\"/><s n=\"mf\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_n: par_fra = $par_fra ($lemma_fra) par_oci = $par_oci ($lemma_oci)\n";
#print STDERR "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	}
}

sub escriure_bidix_adj {
	my ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran) = @_;

print "escriure_bidix_adj ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran)\n" if $lemma_oci eq $MOT || $lemma_fra eq $MOT;
#print "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	my $par_fra = $dix_fra{$morf_fra}{$lemma_fra};
	my $par_oci = $dix_oci{$morf_oci}{$lemma_oci};
	my $alt = '';
	if ($var_oci) {
		$alt = " alt=\"oci\"";
	} elsif ($var_gascon) {
		$alt = " alt=\"oci\@gascon\"";
	} elsif ($var_aran) {
		$alt = " alt=\"oci\@aran\"";
	}
	my $a = " a=\"$autor\"" if $autor;
	if (($par_fra eq 'abaissant__adj'
		|| $par_fra eq 'affirmati/f__adj'
		|| $par_fra eq 'amica/l__adj'
		|| $par_fra eq 'ancien__adj'
		|| $par_fra eq 'andalou__adj'
		|| $par_fra eq 'annuel__adj'
		|| $par_fra eq 'be/au__adj'
		|| $par_fra eq 'aig/u__adj'
		|| $par_fra eq 'br/ef__adj'
		|| $par_fra eq 'causeu/r__adj'
		|| $par_fra eq 'ch/er__adj'
		|| $par_fra eq 'conduct/eur__adj'
		|| $par_fra eq 'favori__adj'
		|| $par_fra eq 'grec__adj'
		|| $par_fra eq 'long__adj'
		|| $par_fra eq 'maître__adj'
		|| $par_fra eq 'mali/n__adj'
		|| $par_fra eq 'fo/u__adj'
		|| $par_fra eq 'fran/c__adj'
		|| $par_fra eq 'mo/u__adj'
		|| $par_fra eq 'm/ûr__adj'
		|| $par_fra eq 'nouve/au__adj'
		|| $par_fra eq 'publi/c__adj'
		|| $par_fra eq 's/ec__adj'
		|| $par_fra eq 'secr/et__adj')
		&& ($par_oci eq 'apropria/t__adj'
		|| $par_oci eq 'trabalhador__adj'
		|| $par_oci eq 'ampl/e__adj'
		|| $par_oci eq 'anti/c__adj'
		|| $par_oci eq 'ar/abi__adj'
		|| $par_oci eq 'aran/és__adj'
		|| $par_oci eq 'bas/c__adj'
		|| $par_oci eq 'biling/üe__adj'
		|| $par_oci eq 'blan/c__adj'
		|| $par_oci eq 'compli/ce__adj'
		|| $par_oci eq 'conf/ús__adj'
		|| $par_oci eq 'content__adj'
		|| $par_oci eq 'cont/inu__adj'
		|| $par_oci eq 'divèrs__adj'
		|| $par_oci eq 'do/ç__adj'
		|| $par_oci eq '/ebri__adj'
		|| $par_oci eq 'esc/às__adj'
		|| $par_oci eq 'espanhò/u__adj'
		|| $par_oci eq 'esp/és__adj'
		|| $par_oci eq 'esqu/èr__adj'
		|| $par_oci eq 'estima/t__adj'
		|| $par_oci eq 'europè/u__adj'
		|| $par_oci eq 'faus__adj'
		|| $par_oci eq 'guair/e__adj'
		|| $par_oci eq 'jusi/eu__adj'
		|| $par_oci eq 'lè/g__adj'
		|| $par_oci eq 'long__adj'
		|| $par_oci eq 'mie/i__adj'
		|| $par_oci eq 'nauè/th__adj'
		|| $par_oci eq 'perilh/ós__adj'
		|| $par_oci eq 'pl/en__adj'
		|| $par_oci eq 'pò/c__adj'
		|| $par_oci eq 'prec/ís__adj'
		|| $par_oci eq 'primiè/r__adj'
		|| $par_oci eq 'priorit/ari__adj'
		|| $par_oci eq 'prop/ici__adj'
		|| $par_oci eq 'prumèr__adj'
		|| $par_oci eq 'r/anci__adj'
		|| $par_oci eq 'representati/u__adj'
		|| $par_oci eq 'reproduct/or__adj'
		|| $par_oci eq 's/avi__adj'
		|| $par_oci eq 'sauvat/ge__adj'
		|| $par_oci eq 'so/ís__adj'
		|| $par_oci eq 'tecni/c__adj'
		|| $par_oci eq 'tranquil__adj'
		|| $par_oci eq 'vag/ue__adj'
		|| $par_oci eq 'vesedo/r__adj')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'abaissant__adj'
		|| $par_fra eq 'affirmati/f__adj'
		|| $par_fra eq 'amica/l__adj'
		|| $par_fra eq 'ancien__adj'
		|| $par_fra eq 'andalou__adj'
		|| $par_fra eq 'annuel__adj'
		|| $par_fra eq 'be/au__adj'
		|| $par_fra eq 'aig/u__adj'
		|| $par_fra eq 'br/ef__adj'
		|| $par_fra eq 'causeu/r__adj'
		|| $par_fra eq 'ch/er__adj'
		|| $par_fra eq 'conduct/eur__adj'
		|| $par_fra eq 'favori__adj'
		|| $par_fra eq 'grec__adj'
		|| $par_fra eq 'long__adj'
		|| $par_fra eq 'maître__adj'
		|| $par_fra eq 'mali/n__adj'
		|| $par_fra eq 'fo/u__adj'
		|| $par_fra eq 'fran/c__adj'
		|| $par_fra eq 'mo/u__adj'
		|| $par_fra eq 'm/ûr__adj'
		|| $par_fra eq 'nouve/au__adj'
		|| $par_fra eq 'publi/c__adj'
		|| $par_fra eq 's/ec__adj'
		|| $par_fra eq 'secr/et__adj')
		&& ($par_oci eq 'agricòl/a__adj'
		|| $par_oci eq 'bèlg/a__adj'
		|| $par_oci eq 'barlò/ca__adj'
		|| $par_oci eq 'generau__adj')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"mf_GD\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'abaissant__adj'
		|| $par_fra eq 'affirmati/f__adj'
		|| $par_fra eq 'amica/l__adj'
		|| $par_fra eq 'ancien__adj'
		|| $par_fra eq 'andalou__adj'
		|| $par_fra eq 'annuel__adj'
		|| $par_fra eq 'be/au__adj'
		|| $par_fra eq 'aig/u__adj'
		|| $par_fra eq 'br/ef__adj'
		|| $par_fra eq 'causeu/r__adj'
		|| $par_fra eq 'ch/er__adj'
		|| $par_fra eq 'conduct/eur__adj'
		|| $par_fra eq 'favori__adj'
		|| $par_fra eq 'grec__adj'
		|| $par_fra eq 'long__adj'
		|| $par_fra eq 'maître__adj'
		|| $par_fra eq 'mali/n__adj'
		|| $par_fra eq 'fo/u__adj'
		|| $par_fra eq 'fran/c__adj'
		|| $par_fra eq 'mo/u__adj'
		|| $par_fra eq 'm/ûr__adj'
		|| $par_fra eq 'nouve/au__adj'
		|| $par_fra eq 'publi/c__adj'
		|| $par_fra eq 's/ec__adj'
		|| $par_fra eq 'secr/et__adj')
		&& $par_oci eq 'addiciona/l_u__adj') {
		$stem_oci =~ s/l$//o;
		printf $fbi "<e$lr_rl$alt$a><p><l>%s</l><r>%s</r></p><par n=\"l-u-adj_l\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'académique__adj'
		|| $par_fra eq 'hébreu__adj')
		&& ($par_oci eq 'apropria/t__adj'
		|| $par_oci eq 'trabalhador__adj'
		|| $par_oci eq 'ampl/e__adj'
		|| $par_oci eq 'anti/c__adj'
		|| $par_oci eq 'ar/abi__adj'
		|| $par_oci eq 'aran/és__adj'
		|| $par_oci eq 'bas/c__adj'
		|| $par_oci eq 'biling/üe__adj'
		|| $par_oci eq 'blan/c__adj'
		|| $par_oci eq 'compli/ce__adj'
		|| $par_oci eq 'conf/ús__adj'
		|| $par_oci eq 'content__adj'
		|| $par_oci eq 'cont/inu__adj'
		|| $par_oci eq 'divèrs__adj'
		|| $par_oci eq 'do/ç__adj'
		|| $par_oci eq '/ebri__adj'
		|| $par_oci eq 'esc/às__adj'
		|| $par_oci eq 'espanhò/u__adj'
		|| $par_oci eq 'esp/és__adj'
		|| $par_oci eq 'esqu/èr__adj'
		|| $par_oci eq 'estima/t__adj'
		|| $par_oci eq 'europè/u__adj'
		|| $par_oci eq 'faus__adj'
		|| $par_oci eq 'guair/e__adj'
		|| $par_oci eq 'jusi/eu__adj'
		|| $par_oci eq 'lè/g__adj'
		|| $par_oci eq 'long__adj'
		|| $par_oci eq 'mie/i__adj'
		|| $par_oci eq 'nauè/th__adj'
		|| $par_oci eq 'perilh/ós__adj'
		|| $par_oci eq 'pl/en__adj'
		|| $par_oci eq 'pò/c__adj'
		|| $par_oci eq 'prec/ís__adj'
		|| $par_oci eq 'primiè/r__adj'
		|| $par_oci eq 'priorit/ari__adj'
		|| $par_oci eq 'prop/ici__adj'
		|| $par_oci eq 'prumèr__adj'
		|| $par_oci eq 'r/anci__adj'
		|| $par_oci eq 'representati/u__adj'
		|| $par_oci eq 'reproduct/or__adj'
		|| $par_oci eq 's/avi__adj'
		|| $par_oci eq 'sauvat/ge__adj'
		|| $par_oci eq 'so/ís__adj'
		|| $par_oci eq 'tecni/c__adj'
		|| $par_oci eq 'tranquil__adj'
		|| $par_oci eq 'vag/ue__adj'
		|| $par_oci eq 'vesedo/r__adj')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"GD_mf\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'académique__adj'
		|| $par_fra eq 'hébreu__adj')
		&& ($par_oci eq 'agricòl/a__adj'
		|| $par_oci eq 'bèlg/a__adj'
		|| $par_oci eq 'barlò/ca__adj'
		|| $par_oci eq 'generau__adj')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'académique__adj'
		|| $par_fra eq 'hébreu__adj')
		&& $par_oci eq 'addiciona/l_u__adj') {
		$stem_oci =~ s/l$//o;
		printf $fbi "<e$lr_rl$alt$a><p><l>%s</l><r>%s</r></p><par n=\"l-u-adj_l2\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'affectueu/x__adj' || $par_fra eq 'dou/x__adj' || $par_fra eq 'vie/ux__n' || $par_fra eq 'fra/is__adj' || $par_fra eq 'anglais__adj' || $par_fra eq 'bas__adj')
		&& ($par_oci eq 'agricòl/a__adj'
		|| $par_oci eq 'bèlg/a__adj'
		|| $par_oci eq 'barlò/ca__adj'
		|| $par_oci eq 'generau__adj')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"XXXanglais_esquimal\"/></e>\n", $stem_oci, $stem_fra;
	} elsif (($par_fra eq 'affectueu/x__adj' || $par_fra eq 'dou/x__adj' || $par_fra eq 'vie/ux__n' || $par_fra eq 'fra/is__adj' || $par_fra eq 'anglais__adj' || $par_fra eq 'bas__adj')
		&& ($par_oci eq 'apropria/t__adj'
		|| $par_oci eq 'trabalhador__adj'
		|| $par_oci eq 'ampl/e__adj'
		|| $par_oci eq 'anti/c__adj'
		|| $par_oci eq 'ar/abi__adj'
		|| $par_oci eq 'aran/és__adj'
		|| $par_oci eq 'bas/c__adj'
		|| $par_oci eq 'biling/üe__adj'
		|| $par_oci eq 'blan/c__adj'
		|| $par_oci eq 'compli/ce__adj'
		|| $par_oci eq 'conf/ús__adj'
		|| $par_oci eq 'content__adj'
		|| $par_oci eq 'cont/inu__adj'
		|| $par_oci eq 'divèrs__adj'
		|| $par_oci eq 'do/ç__adj'
		|| $par_oci eq '/ebri__adj'
		|| $par_oci eq 'esc/às__adj'
		|| $par_oci eq 'espanhò/u__adj'
		|| $par_oci eq 'esp/és__adj'
		|| $par_oci eq 'esqu/èr__adj'
		|| $par_oci eq 'estima/t__adj'
		|| $par_oci eq 'europè/u__adj'
		|| $par_oci eq 'faus__adj'
		|| $par_oci eq 'guair/e__adj'
		|| $par_oci eq 'jusi/eu__adj'
		|| $par_oci eq 'lè/g__adj'
		|| $par_oci eq 'long__adj'
		|| $par_oci eq 'mie/i__adj'
		|| $par_oci eq 'nauè/th__adj'
		|| $par_oci eq 'perilh/ós__adj'
		|| $par_oci eq 'pl/en__adj'
		|| $par_oci eq 'pò/c__adj'
		|| $par_oci eq 'prec/ís__adj'
		|| $par_oci eq 'primiè/r__adj'
		|| $par_oci eq 'priorit/ari__adj'
		|| $par_oci eq 'prop/ici__adj'
		|| $par_oci eq 'prumèr__adj'
		|| $par_oci eq 'r/anci__adj'
		|| $par_oci eq 'representati/u__adj'
		|| $par_oci eq 'reproduct/or__adj'
		|| $par_oci eq 's/avi__adj'
		|| $par_oci eq 'sauvat/ge__adj'
		|| $par_oci eq 'so/ís__adj'
		|| $par_oci eq 'tecni/c__adj'
		|| $par_oci eq 'tranquil__adj'
		|| $par_oci eq 'vag/ue__adj'
		|| $par_oci eq 'vesedo/r__adj')) {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/></l><r>%s<s n=\"adj\"/></r></p><par n=\"anglés_anglais\"/></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'arrière__adj' && $par_oci eq 'post__adj') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/><s n=\"mf\"/><s n=\"sp\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'arrière__adj' && $par_oci eq 'post__adj') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"adj\"/><s n=\"mf\"/><s n=\"sp\"/></l><r>%s<s n=\"adj\"/><s n=\"mf\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_adj: par_fra = $par_fra ($lemma_fra) par_oci = $par_oci ($lemma_oci)\n";
#print STDERR "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	}
}

sub escriure_bidix_ant {
	my ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran) = @_;
my $par_oci;

print "escriure_bidix_ant ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran)\n" if $lemma_oci eq $MOT || $lemma_fra eq $MOT;
#print "escriure_bidix_n ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n" if $lemma_oci eq $MOT || $lemma_fra =~ /musique/o;
#print "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	my $par_fra = $dix_fra{$morf_fra}{$lemma_fra};
	if ($lemma_fra =~ /#/o) {
		my $x = $lemma_fra;
		$x =~ s/#//;
		$par_fra = $dix_fra{$morf_fra}{$x};
	}
	my $par_oci = $dix_oci{$morf_oci}{$lemma_oci};
	if ($lemma_oci =~ /#/o) {
		my $x = $lemma_oci;
		$x =~ s/#//;
		$par_oci = $dix_oci{$morf_oci}{$x};
	}
	my $a = " a=\"$autor\"" if $autor;
	my $alt = '';
	if ($var_oci) {
		$alt = " alt=\"oci\"";
	} elsif ($var_gascon) {
		$alt = " alt=\"oci\@gascon\"";
	} elsif ($var_aran) {
		$alt = " alt=\"oci\@aran\"";
	}
	if ($par_fra eq 'Marie__np' && $par_oci eq 'Aitana__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'Antoine__np' && $par_oci eq 'Antòni__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"ant\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_ant: par_fra = $par_fra ($lemma_fra) par_oci = $par_oci ($lemma_oci)\n";
	}
}

sub escriure_bidix_top {
	my ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran) = @_;
my $par_oci;

print "escriure_bidix_top ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran)\n" if $lemma_oci eq $MOT || $lemma_fra eq $MOT;
#print "escriure_bidix_n ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n" if $lemma_oci eq $MOT || $lemma_fra =~ /musique/o;
#print "dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	my $par_fra = $dix_fra{$morf_fra}{$lemma_fra};
	if ($lemma_fra =~ /#/o) {
		my $x = $lemma_fra;
		$x =~ s/#//;
		$par_fra = $dix_fra{$morf_fra}{$x};
	}
	my $par_oci = $dix_oci{$morf_oci}{$lemma_oci};
	if ($lemma_oci =~ /#/o) {
		my $x = $lemma_oci;
		$x =~ s/#//;
		$par_oci = $dix_oci{$morf_oci}{$x};
	}
	my $a = " a=\"$autor\"" if $autor;
	my $alt = '';
	if ($var_oci) {
		$alt = " alt=\"oci\"";
	} elsif ($var_gascon) {
		$alt = " alt=\"oci\@gascon\"";
	} elsif ($var_aran) {
		$alt = " alt=\"oci\@aran\"";
	}
	if ($par_fra eq 'Bulgarie__np' && $par_oci eq 'Bulgaria__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'Iran__np' && $par_oci eq 'Iran__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'Bahamas__np' && $par_oci eq 'Bahamas__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'États-Unis__np' && $par_oci eq 'Estats_Units__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'Bulgarie__np' && $par_oci eq 'Iran__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'Iran__np' && $par_oci eq 'Bulgaria__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"sg\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"sg\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'Bahamas__np' && $par_oci eq 'Estats_Units__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} elsif ($par_fra eq 'États-Unis__np' && $par_oci eq 'Bahamas__np') {
		printf $fbi "<e$lr_rl$alt$a><p><l>%s<s n=\"np\"/><s n=\"top\"/><s n=\"f\"/><s n=\"pl\"/></l><r>%s<s n=\"np\"/><s n=\"top\"/><s n=\"m\"/><s n=\"pl\"/></r></p></e>\n", $stem_oci, $stem_fra;
	} else {
		print STDERR "No hi ha regla per a escriure_bidix_top: par_fra = $par_fra ($lemma_fra) par_oci = $par_oci ($lemma_oci)\n";
	}
}

sub escriure_bidix {
	my ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor) = @_;
	$lr_rl = " $lr_rl" if $lr_rl;
	my $a = " a=\"$autor\"" if $autor;
	my $var_oci = 1 if $variant_oci{$morf_oci}{$lemma_oci}{oci};
	my $var_gascon = 1 if $variant_oci{$morf_oci}{$lemma_oci}{gascon};
	my $var_aran = 1 if $variant_oci{$morf_oci}{$lemma_oci}{aran};
print "variant_oci{$morf_oci}{$lemma_oci}{gascon} = $variant_oci{$morf_oci}{$lemma_oci}{gascon}, var_gascon=$var_gascon\n" if $lemma_oci eq $MOT || $lemma_fra eq $MOT;
	if ($morf_oci eq 'vblex' && $morf_fra eq 'vblex') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_oci, $morf_oci, $stem_fra, $morf_fra;
	} elsif ($morf_oci eq 'adv' && $morf_fra eq 'adv') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_oci, $morf_oci, $stem_fra, $morf_fra;
	} elsif ($morf_oci eq 'pr' && $morf_fra eq 'pr') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_oci, $morf_oci, $stem_fra, $morf_fra;
	} elsif ($morf_oci eq 'cnjadv' && $morf_fra eq 'cnjadv') {
		printf $fbi "<e$lr_rl$a><p><l>%s<s n=\"%s\"/></l><r>%s<s n=\"%s\"/></r></p></e>\n", $stem_oci, $morf_oci, $stem_fra, $morf_fra;
	} elsif ($morf_oci eq 'n' && $morf_fra eq 'n') {
		escriure_bidix_n ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran);
	} elsif ($morf_oci eq 'adj' && $morf_fra eq 'adj') {
		escriure_bidix_adj ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran);
	} elsif ($morf_oci eq 'top' && $morf_fra eq 'top') {
		escriure_bidix_top ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran);
	} elsif ($morf_oci eq 'antm' && $morf_fra eq 'antm') {
		escriure_bidix_ant ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran);
	} elsif ($morf_oci eq 'antf' && $morf_fra eq 'antf') {
		escriure_bidix_ant ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor, $var_oci, $var_gascon, $var_aran);
	} else {
		print STDERR "No hi ha regla per a escriure_bidix($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $lr_rl, $autor)\n";
	}
}

sub lema_fra_existeix_o_es_pot_crear {
	my ($lemma_fra, $morf_fra, $autor) = @_;
print "0. lema_fra_existeix_o_es_pot_crear: dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n"
	if $MOT && ($lemma_fra =~ /$MOT/o);
#print STDERR "lema_fra_existeix_o_es_pot_crear: dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n";
	return 1 if $dix_fra{$morf_fra}{$lemma_fra};

	# no existeix
	# potser es pot crear si és un verb amb <g> i tenim la capçalera
	return 0 if $lemma_fra =~ /^se /o;
	return 0 if $lemma_fra =~ /^s'/o;
print "3. lema_fra_existeix_o_es_pot_crear: dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n"
	if $MOT && ($lemma_fra =~ /$MOT/o);
	if ($lemma_fra =~ /#/o) {
		return ! crear_g($lemma_fra, $morf_fra);
	} else {
print "4. lema_fra_existeix_o_es_pot_crear: dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n"
	if $MOT && ($lemma_fra =~ /$MOT/o);
		if ($morf_fra eq 'vblex') {
print "5. lema_fra_existeix_o_es_pot_crear: dix_fra{$morf_fra}{$lemma_fra} = $dix_fra{$morf_fra}{$lemma_fra}\n"
	if $MOT && ($lemma_fra =~ /$MOT/o);
			if ($dix_frav{vblex}{$lemma_fra}) { # de moment, verificació ortogràfica i prou
#				my $morf_fra_prov = $dix_frav{vblex}{$lemma_fra};
				return escriure_mono_vblex($lemma_fra);
			} else {
				print STDERR "Error ortogràfic: verb $lemma_fra no és en dicollecte\n";
				return 0;
			}
		} elsif ($morf_fra eq 'adv') {
				my $stem_fra = $lemma_fra;
				$stem_fra =~ s| |<b/>|og;
				printf $ffra "    <e lm=\"%s\"$a>        <i>%s</i><par n=\"%s\"/></e>\n", $lemma_fra, $stem_fra, 'hier__adv';
				printf $flex "$lemma_fra\n";
				return 1;
		} elsif ($morf_fra eq 'pr') {
				return 0;
		} elsif ($morf_fra eq 'cnjadv') {
				return 0;
		} elsif ($morf_fra eq 'adj') {
			my $tmp = $dix_fraadj_def{$morf_fra}{$lemma_fra};
			if ($tmp) {
				$tmp =~ s/><i/ a="jaumeortola"><i/o;
				print $ffra $tmp, "\n";
				$dix_fra{$morf_fra}{$lemma_fra} = $dix_fraadj{$morf_fra}{$lemma_fra};
				return 1;
			} else {
				return 0;
			}
		} elsif ($morf_fra eq 'n') {
			my $tmp = $dix_fran_def{$morf_fra}{$lemma_fra};
			if ($tmp) {
				$tmp =~ s/><i/ a="jaumeortola"><i/o;
				print $ffra $tmp, "\n";
				$dix_fra{$morf_fra}{$lemma_fra} = $dix_fran{$morf_fra}{$lemma_fra};
				return 1;
			} else {
				return 0;
			}
		}
		return 0;
	}
}

# aquesta funció fa el tractament d'una parella neta (1 lema oci - 1 lema fra), introduint el que calgui en els diccionaris
# no verifica que el lema oci és en el diccionari
sub tractar_parella {
	my ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $autor, $primer, $n_linia) = @_;

#print "tractar_parella ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $autor, $primer)\n";
print "1. tractar_parella ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $autor, $primer)\n" if $lemma_oci eq $MOT || $lemma_fra eq $MOT;
#print "5. fra dix_fra{$MORF_TRACT}{$MOT} = $dix_fra{$MORF_TRACT}{$MOT}\n";

	# si està activada la generació de paraulaes catalanes, busco i carrego la paraula si no hi és en el monodix
if ($morf_oci eq 'vblex' && $lemma_oci =~ /#/o) {
	$lemma_oci =~ s/#//o;
}
	if ($GEN_OCI && !$dix_oci{$morf_oci}{$lemma_oci}) {
		if ($morf_oci eq 'adj') {
			return 0;
		} elsif ($morf_oci eq 'n') {
			return 0;
		} elsif ($morf_oci eq 'top') {
			return 0;
		} elsif ($morf_oci eq 'antm') {
			return 0;
		} elsif ($morf_oci eq 'antf') {
			return 0;
		} elsif ($morf_oci eq 'pr') {
			return 0;
		} elsif ($morf_oci eq 'cnjadv') {
			return 0;
		} elsif ($morf_oci eq 'adv') {
			my $stem_oci = $lemma_oci;
			$stem_oci =~ s| |<b/>|og;
			my $a = " a=\"$autor\"" if $autor;
			printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"%s\"/></e>\n", $lemma_oci, $stem_oci, 'ager__adv';
			$dix_oci{$morf_oci}{$lemma_oci} = 'ager__adv';
		} elsif ($morf_oci eq 'vblex') {
			my $a = ' a="capsot"';
			my $stem_oci = $lemma_oci;
			if ($lemma_oci =~ /izar$/o) {
				$stem_oci =~ s/izar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"ab/i[T]ar__vblex\" prm=\"z\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /icar$/o) {
				$stem_oci =~ s/icar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"revl/i[N]car__vblex\" prm=\"\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /ejar$/o) {
				$stem_oci =~ s/ejar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"p/e[N]jar__vblex\" prm=\"\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /atjar$/o) {
				$stem_oci =~ s/atjar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"encor/a[T]jar__vblex\" prm=\"t\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /iciar$/o) {
				$stem_oci =~ s/iciar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"conc/i[L]iar__vblex\" prm=\"c\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /enciar$/o) {
				$stem_oci =~ s/enciar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"s/e[MI]ar__vblex\" prm=\"nci\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /orar$/o) {
				$stem_oci =~ s/orar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"aband/o[N]ar__vblex\" prm=\"r\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /onar$/o) {
				$stem_oci =~ s/onar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"aband/o[N]ar__vblex\" prm=\"n\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /elar$/o) {
				$stem_oci =~ s/elar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"cap/e[R]ar__vblex\" prm=\"l\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /ular$/o) {
				$stem_oci =~ s/ular$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"ab/u[S]ar__vblex\" prm=\"l\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /ausar$/o) {
				$stem_oci =~ s/ausar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"c/a[NT]ar__vblex\" prm=\"us\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /enar$/o) {
				$stem_oci =~ s/enar$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"lid/e[R]ar__vblex\" prm=\"n\"/></e>\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} elsif ($lemma_oci =~ /ir$/o) {
				$stem_oci =~ s/ir$//o;
				printf $foci "<e lm=\"%s\"$a><i>%s</i><par n=\"magr/èrem__vblex\"/></e> <!-- VERIFICAR -->\n",  $lemma_oci, $stem_oci;
				$dix_oci{$morf_oci}{$lemma_oci} = 1;
			} else {
				print STDERR "0. Falta oci $lemma_oci <$morf_oci> ($lemma_fra: $dix_fra{$morf_fra}{$lemma_fra}: (1), l. $n_linia\n";
				return 0;
			}
		}
	}

	if (!$GEN_OCI && !$dix_oci{$morf_oci}{$lemma_oci}) {
		print STDERR "0. Falta oci $lemma_oci <$morf_oci> ($lemma_fra: $dix_fra{$morf_fra}{$lemma_fra}: (1), l. $n_linia\n";
		return 0;
	}

	if (exists $dix_fra_oci{$morf_fra}{$lemma_fra}) {
		# ja existeix una traducció per al lema fra
print "1.0.\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
		if (is_in($dix_fra_oci{$morf_fra}{$lemma_fra}, $lemma_oci)) {
			# ja existeix aquesta traducció per al lema fra
			# no fem res
			return;
		} else {
			# no existeix encara aquesta traducció per al lema fra
			if (exists $dix_oci_fra{$morf_oci}{$lemma_oci}) {
				# ja existeix una traducció per al lema oci
				if (is_in($dix_oci_fra{$morf_oci}{$lemma_oci}, $lemma_fra)) {
					# ja existeix aquesta traducció per al lema oci
					# no fem res
					return;
				} else {
					# introduïm la parella perquè en quedi constància (algun dia es pot activar), però fem que s'ignori
print "1. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'i=\"yes\"', $autor)\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
#print STDERR "1. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'i=\"yes\"', $autor)\n" if $lemma_fra eq 'rifle';
					escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'i="yes"', $autor);
					return;
				}
			} else {
				# no existeix encara una traducció per al lema oci
				# recordatori: ja existeix una traducció per al lema fra (ergo: està en el monodix fra)
				# traducció en la direcció oci > fra
				my $direccio = ($primer) ? 'r="LR"' : 'i="yes"';
print "2. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $direccio, $autor)\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
#print STDERR "2. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'r=\"LR\"', $autor)\n" if $lemma_fra eq 'rifle';
				escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $direccio, $autor);
				return;
			}
		}

	} else {
		# no existeix una traducció per al lema fra
print "3.0.\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
		if (exists $dix_oci_fra{$morf_oci}{$lemma_oci}) {
			# ja existeix una traducció per al lema oci
			if (is_in($dix_oci_fra{$morf_oci}{$lemma_oci}, $lemma_fra)) {
				# ja existeix aquesta traducció per al lema oci
				# no fem res
				return;
			} elsif (lema_fra_existeix_o_es_pot_crear ($lemma_fra, $morf_fra, $autor)) {
				# $primer no afecta aquí perquè suma LR a LR: queda igual
print "3. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'r=\"RL\"', $autor)\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
#print STDERR "3. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'r=\"RL\"', $autor)\n" if $lemma_fra eq 'rifle';
				escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, 'r="RL"', $autor);
				return;
			} else {
				print STDERR "2. Falta fra $lemma_fra <$morf_fra> (1), l. $n_linia\n";
				return;
			}
		} else {
print "4.0.\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra =~ /$MOT/o);
			if (lema_fra_existeix_o_es_pot_crear ($lemma_fra, $morf_fra, $autor)) {
print "4. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, '', $autor)\n" if $lemma_fra eq 'rifle';
#print STDERR "4. escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, '', $autor)\n" if $lemma_fra eq 'rifle';
				my $direccio = ($primer) ? '' : 'r="LR"';
				escriure_bidix ($lemma_oci, $stem_oci, $morf_oci, $lemma_fra, $stem_fra, $morf_fra, $direccio, $autor);
				return;
			} else {
				print STDERR "3. Falta fra $lemma_fra <$morf_fra> (2), l. $n_linia\n";
print "dix_fra_oci{$morf_fra}{$lemma_fra} =  $dix_fra_oci{$morf_fra}{$lemma_fra}\n" if $lemma_fra eq $MOT;
				return;
			}
		}
	}
}

llegir_dix('fra', $fdixfra, \%dix_fra, \%dix_fra_prm);
print "1. nfitx = fra dix_fra{$MORF_TRACT}{$MOT} = $dix_fra{$MORF_TRACT}{$MOT}\n";
llegir_dix('oci', $fdixoci, \%dix_oci, \%dix_oci_prm);
print "2. nfitx = oci dix_oci{$MORF_TRACT}{$MOT} = $dix_oci{$MORF_TRACT}{$MOT}\n";
llegir_dix_ortola('fra', $fdixfran, \%dix_fran, \%dix_fran_def) if $MORF_TRACT eq 'n';
print "3. nfitx = fra dix_fran{$MORF_TRACT}{$MOT} = $dix_fran{$MORF_TRACT}{$MOT}\n";
llegir_dix_ortola('fra', $fdixfraadj, \%dix_fraadj, \%dix_fraadj_def) if $MORF_TRACT eq 'adj';
print "4. nfitx = fra dix_fraadj{$MORF_TRACT}{$MOT} = $dix_fraadj{$MORF_TRACT}{$MOT}\n";
if ($MORF_TRACT eq 'vblex') {
	llegir_verbs_dicollecte($fdixfrav, \%dix_frav);
	print "4. nfitx = fra dix_frav{$MORF_TRACT}{$MOT} = $dix_frav{$MORF_TRACT}{$MOT}\n";
}
llegir_bidix($fdixbi, \%dix_fra_oci, \%dix_oci_fra);
#print "5. dix_oci_fra{$MORF_TRACT}{$MOT}[0] = $dix_oci_fra{$MORF_TRACT}{$MOT}[0]\n"; COMPTE! No descomentar pqè crea l'entrada i crear pbs amb els exists posteriors
#print "5. dix_fra_oci{$MORF_TRACT}{$MOT}[0] = $dix_fra_oci{$MORF_TRACT}{$MOT}[0]\n"; # COMPTE! No descomentar pqè crea l'entrada i crear pbs amb els exists posteriors
#print "6. dix_fra_oci{$MORF_TRACT}{$MOT} = $dix_fra_oci{$MORF_TRACT}{$MOT}\n";

<STDIN>;	# saltem la primera línia
my ($stem_oci, $stem_fra, $gen_oci, $gen_fra, $num_oci, $num_fra, $lemma_oci, $lemma_fra, $lemma_oci_ini, $lemma_fra_ini);
while (my $linia = <STDIN>) {
#print "0. l. $.: $linia\n";
next if $linia !~ /$MORF_TRACT/o && $MORF_TRACT !~ /^ant/o;
next if $linia !~ /<ant>/o && $MORF_TRACT =~ /^ant/o;
#print "1. l. $.: $linia\n";
	next if $linia =~ /xxx/io;
#print "2. l. $.: $linia\n";
	next if $linia =~ /---/o;
#print "3. l. $.: $linia\n";
	chop $linia;

	if ($linia =~ /\(/o) {
		print STDERR "Error en l. $.: $linia\n";
		next;
	}
#print "4. l. $.: $linia\n";

	$linia =~ s/[^a-zàèéíòóúçA-ZÀÈÉíÒÓÚÇ\t]+$//o;
	$linia =~ s|\r| |og;
	$linia =~ s|#|# |og;	# per evitar errors com "faire#pression sur"
	$linia =~ s|' |'|og;	# coup d' État
	$linia =~ s| +| |og;
	$linia =~ s|’|'|og;

	# arreglem majúscules
	# passo tot a minúscules, excepte si hi ha noms propis o acrònims
	if ($linia !~ /<np>/o && $linia !~ /<acr>/o) {
		$linia =~ tr/[A-ZÀÈÉíÒÓÚÇ]/[a-zàèéíòóúç/;
	}

	my @dades = split /\t/, $linia;
	for (my $i=0; $i<=$#dades; $i++) { 
		$dades[$i] =~ s/^ +//o;
		$dades[$i] =~ s/ +$//o;
	}

	next unless $dades[3];			# línia buida
	next if $dades[5] =~ /\?/o;		# dubtes
	next if length $dades[1] == 1;		# una sola lletra
#print "99. $. dades[1] = $dades[1]\n" if length $dades[1] == 1;	# una sola lletra

	$stem_fra = $dades[1];
	$stem_fra =~ s| +| |og;
	$stem_fra =~ s|^ ||o;
	$stem_fra =~ s| $||o;
	$stem_fra =~ s|#$||o;
	$lemma_fra_ini = $lemma_fra = $stem_fra;
	if ($stem_fra =~ m/\#/o) {
		$stem_fra = $` . '<g>' . $' . '</g>';
	}
	$stem_fra =~ s| |<b/>|og;

	my $gram_fra = $dades[2];
print "gram_fra = $gram_fra, $linia\n" if $MOT && ($lemma_oci eq $MOT || $lemma_fra eq $MOT);
next if $gram_fra !~ /<$MORF_TRACT>/o && $MORF_TRACT !~ /^ant/o;
next if $gram_fra !~ /<ant>/o && $MORF_TRACT =~ /^ant/o;
#next if $linia !~ /$MORF_TRACT/o && $MORF_TRACT ne 'top';
#next if $linia !~ /np/o && $MORF_TRACT eq 'top';
	$gram_fra =~ s/^ *<//og;
	$gram_fra =~ s/> *$//og;
	$gram_fra =~ s/><//og;

	$dades[3] =~ s|,|;|og;
	$dades[3] =~ s|:|;|og;

	my $autor = $dades[6];
	$autor =~ s| +| |og;
	$autor =~ s|^ ||o;
	$autor =~ s| $||o;
	$autor =~ s|^jl$|joan|o;
print "$linia\n" if $MOT && ($lemma_oci eq $MOT || $lemma_fra eq $MOT);
print "autor = $autor\n" if $MOT && ($lemma_oci eq $MOT || $lemma_fra eq $MOT);
	$autor = $AUTOR unless $autor;

print "11. $linia - stem_fra=$stem_fra, lemma_fra=$lemma_fra, gram_fra = $gram_fra, dades[3]=$dades[3]\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra eq $MOT);
	my @stem_oci = split /;/o, $dades[3];
	my $primer = 1;
	my $n = 0; 	# index en @stem_oci
	foreach my $stem_oci (@stem_oci) {
#print STDERR "stem_oci = #$stem_oci#\n";
		$stem_oci =~ s| +| |og;
		$stem_oci =~ s|^ ||o;
		$stem_oci =~ s| $||o;
		$stem_oci =~ s| $||o;	# no és un espai en blanc (no sé què és però apareix en el fitxer: ho posa l'Open Office davant de ; en francès)
		next unless $stem_oci;
#print STDERR "stem_oci = #$stem_oci#\n";
		$lemma_oci_ini = $lemma_oci = $stem_oci;
		if ($stem_oci =~ m/\#/o) {
			$stem_oci = $` . '<g>' . $' . '</g>';
#			$lemma_oci =~ s/#//o;
		}
print "$linia\n" if $MOT && ($lemma_oci eq $MOT || $lemma_fra eq $MOT);
		$stem_oci =~ s| |<b/>|og;

		my $gram_fra = $dades[2];
		$gram_fra =~ s/ //og;
		$gram_fra =~ s/^ *<//og;
		$gram_fra =~ s/> *$//og;
		if ($gram_fra =~ /></o) {
			my @gram_fra = split /;/o, $gram_fra;
			$gram_fra = $gram_fra[$n];
			$gram_fra = $gram_fra[0] unless $gram_fra;	# potser hi ha només una definició per a totes les possibilitats
#print "12a. $linia - stem_fra=$stem_fra, lemma_fra=$lemma_fra, gram_fra = $gram_fra\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra eq $MOT);
			$gram_fra = 'n' if $gram_fra =~ /^n>/o;
			$gram_fra = 'top' if $gram_fra =~ /^np><top/o;
			$gram_fra = 'ant' if $gram_fra =~ /^np><ant/o;
			$gram_fra = 'np' if $gram_fra =~ /^np>/o;
		}

		my $gram_oci = $dades[4];
		$gram_oci =~ s/ //og;
		if ($gram_oci) {
			$gram_oci =~ s/^ *<//og;
			$gram_oci =~ s/> *$//og;
			if ($gram_oci =~ /></o) {
				my @gram_oci = split /;/o, $gram_oci;
				$gram_oci = $gram_oci[$n];
				$gram_oci = $gram_oci[0] unless $gram_oci;	# potser hi ha només una definició per a totes les possibilitats
				$gram_oci = 'n' if $gram_oci =~ /^n>/o;
				$gram_oci = 'top' if $gram_fra =~ /^np><top/o;
				$gram_oci = 'ant' if $gram_fra =~ /^np><ant/o;
				$gram_oci = 'np' if $gram_oci =~ /^np>/o;
			}
		} else {
			$gram_oci = $gram_fra;
		}
print "12. $linia - stem_fra=$stem_fra, lemma_fra=$lemma_fra, gram_oci = $gram_oci, gram_fra = $gram_fra\n" if $MOT && ($lemma_oci =~ /$MOT/o || $lemma_fra eq $MOT);
#print "12. $linia - stem_fra=$stem_fra, lemma_fra=$lemma_fra, gram_oci = $gram_oci, gram_fra = $gram_fra\n";

		# cas especial: assigno a mà antm o antf
		if ($MORF_TRACT eq 'antm') {
			unless ($dix_fra{antm}{$lemma_fra}) {
				# No és antm
				unless ($dix_fra{antf}{$lemma_fra}) {
					# Hi ha algun error perquè no és tampoc antf
#					print STDERR "4. Falta fra $lemma_fra <$gram_fra> (2), l. $.\n";
				}
				next;
			}
			$gram_fra = $gram_oci = 'antm';
		} elsif ($MORF_TRACT eq 'antf') {
			unless ($dix_fra{antf}{$lemma_fra}) {
				# No és antm
				unless ($dix_fra{antm}{$lemma_fra}) {
					# Hi ha algun error perquè no és tampoc antm
#					print STDERR "5. Falta fra $lemma_fra <$gram_fra> (2), l. $.\n";
				}
				next;
			}
			$gram_fra = $gram_oci = 'antf';
		}

		tractar_parella ($lemma_oci, $stem_oci, $gram_oci, $lemma_fra, $stem_fra, $gram_fra, $autor, $primer, $.);
		$primer = 0;
	}

}
