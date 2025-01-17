#!/bin/bash
echo "#############################################################################"
echo "GC Calculator v0.1 march 2014 | TL | tbleroy@pierroton.inra.fr"
echo "multifasta2fastafilestab.pl & gc_n_others_content.pl required in the same dir"
echo "#############################################################################"
# lire le fichier spécifié par l'utilisateur
echo "Name of your multifastafile:"
MY_PROMPT='$ '
read file
echo "Reading file"
# créer un dossier et y inclure les fichiers fasta
# ici le fichier a un ID puis une tab puis la séquence
################### ATTENTION A REMETTRE A LA PROCHAINE UTILISATION #####################################
mkdir fasta_files
cd fasta_files/
perl ../multifasta2fastafilestab.pl ../$file
fname=$(echo $file"_GC.content_slwindows10kb_newversion.txt") #### modifié le 28/02/15
# élimine les \n entre les séquences
for i in ../fasta_files/*.fasta; do
	sed ':a;N;$!ba;s/\n//g' $i >> $i.sed
done
################### FIN A REMETTRE A LA PROCHAINE UTILISATION #####################################
# print stats
# voir ce script pour plus d'infos
echo "Starting computations"
for j in ../fasta_files/*.sed; do			
	echo -n "." # affiche un point par fichier 
	perl ../GCcontent.pl $j >> ../tempo.$fname # windows=1000 unless otherwise specified (see perl script).
done
echo "end of computations"
echo "creating R output file"
echo "start_windows\tnb_GC\tnb_ACGT\tnb_MRWSYK\tnb_N\tGCrate\tNrate\tMRWSYKrate" >> ../$fname 
cat ../tempo.$fname >> ../$fname
########## Modification du fichier pour un traitement sous R ##########
### Comme cette étape de calcul est la plus longue (= mal-codée), à n'exécuter que si nécessaire.
# Rajouter une colonne au début de chaque ligne contenant les noms des scaffolds
fname2=$(echo $file"_GC.content_slwindows10kb_newversion_pourR.txt")
fname3=$(echo $file"_GC.content_slwindows10kb_newversion_pourR_withoutNA.txt")
while read line
do
	found=$(echo $line | grep ">")
	if [ "$found" ]; then 
		temp=$(echo $line)
	else
		temp2=$(echo $line)
		echo $temp"\t"$temp2 >>../temp.$fname
	fi
done  < ../tempo.$fname
rm ../tempo.$fname
 # éliminer les lignes où les stats ne sont pas imprimées (pour R)
echo "sequence\tstart_position_windows\tnb_GC\tnb_ACGT\tnb_MRWSYK\tnb_N\tGCrate\tNrate\tMRWSYKrate" >> ../$fname2
while read line
do
	found2=$(echo $line | grep "=$" )
	if [ "$found2" ]; then
		continue
	else 
		temp3=$(echo $line)
		echo $temp3 | sed  's/= >//' | sed  's/= //' | sed -e 's/ /\t/g' >>../$fname2
	fi
done  < ../temp.$fname 
rm ../tem*.$fname
grep -v "NA" ../$fname2 > ../$fname3 # Attention le fichier généré ne contient plus les fenêtres avec trop de NA, ne pas utiliser pour étudier le Nrate.
cd ..
rm -r fasta_files
echo "job finished à" $(date '+%T')
