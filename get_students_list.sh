#!/bin/bash
#Getting registration list
#Prerequisite: install pdftotext

glists='K1_final_list.pdf K2_final_list.pdf'	#Name list for groups, download them from MyNemo (Akademik->Modul Pensyarah->Senarai Pendaftaran)

#-----------------------------------------

for g in ${glists}; do

	pdftotext -layout ${g}
	cat ${g%.pdf}.txt | tail -n +10 | cut -c 7-60 | sed 's/^ //g' | grep ^S > ${g%.pdf}.raw.txt

	echo "Matrix_Number,Name"  > ${g%.pdf}.csv
	cat ${g%.pdf}.raw.txt | while read -r matrix name; do
			echo ${matrix},${name} >> ${g%.pdf}.csv
	done
	rm ${g%.pdf}.raw.txt

done

echo "Job completed!"
